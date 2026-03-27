import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:clinexa_derivant_app/data/models/notification_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/repositories/notification_repository.dart';

class NotificationService {
  final NotificationRepository _repository;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<RemoteMessage>? _msgSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'high_importance_channel',
        'Notificaciones Importantes',
        description:
            'Canal usado para notificaciones importantes en primer plano.',
        importance: Importance.max,
      );

  NotificationService({required NotificationRepository repository})
    : _repository = repository;

  Future<void> initListeners() async {
    log(
      'Inicializando servicio de notificaciones...',
      name: 'NotificationService',
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        log(
          'Notificacion local tocada: ${details.payload}',
          name: 'NotificationService',
        );
      },
    );

    if (Platform.isAndroid) {
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_androidChannel);
    }

    await _repository.requestPermission();

    _setupFCMListeners();
    _handleInitialMessage();

    _tokenRefreshSubscription = _repository.onTokenRefresh.listen((newToken) {
      log('Token de FCM refrescado', name: 'NotificationService');
      _repository.saveToken(newToken);
    });
  }

  void _setupFCMListeners() {
    _msgSubscription?.cancel();
    _openedAppSubscription?.cancel();

    _msgSubscription = FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) {
      log(
        'Mensaje recibido en foreground: ${message.messageId}',
        name: 'NotificationService',
      );

      final notification = NotificationModel.fromRemoteMessage(message);

      if (Platform.isAndroid) {
        _showLocalNotification(notification);
      }
    });

    _openedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen((
      RemoteMessage message,
    ) {
      log(
        'Notificacion abrio la app desde background: ${message.messageId}',
        name: 'NotificationService',
      );
    });
  }

  Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();

    if (initialMessage != null) {
      log(
        'App abierta desde estado cerrada: ${initialMessage.notification?.title}',
        name: 'NotificationService',
      );
    }
  }

  Future<void> _showLocalNotification(NotificationModel notification) async {
    if (notification.title.isEmpty && notification.body.isEmpty) return;

    await _localNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: notification.data.toString(),
    );
  }

  Future<void> registerDevice() async {
    log(
      'Iniciando proceso registerDevice() (User Autenticado)...',
      name: 'NotificationService',
    );
    try {
      log('Llamando a _repository.getToken()...', name: 'NotificationService');
      final token = await _repository.getToken();
      
      if (token != null) {
        log('Token obtenido correctamente del repositorio. Llamando a _repository.saveToken(token)...', name: 'NotificationService');
        await _repository.saveToken(token);
        log('Flujo de registro completado en NotificationService', name: 'NotificationService');
      } else {
        log(
          '⚠️ ERROR: _repository.getToken() retornó NULL. No se puede proceder con el registro.',
          name: 'NotificationService',
        );
      }
    } catch (e) {
      log('❌ ERROR EXCEPCION en registerDevice: $e', name: 'NotificationService');
    }
  }

  Future<void> unsubscribe() async {
    log(
      'Desuscribiendo notificaciones (Logout)...',
      name: 'NotificationService',
    );
    try {
      await _repository.deleteToken();

      await _msgSubscription?.cancel();
      _msgSubscription = null;

      await _openedAppSubscription?.cancel();
      _openedAppSubscription = null;

      await _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = null;

      log('Desuscripcion completada', name: 'NotificationService');
    } catch (e) {
      log('Error en unsubscribe: $e', name: 'NotificationService');
    }
  }
}
