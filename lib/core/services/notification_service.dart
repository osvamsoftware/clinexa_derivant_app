import 'dart:async';
import 'dart:developer';
import 'package:clinexa_derivant_app/data/models/notification_model.dart';
import 'package:clinexa_derivant_app/domain/repositories/notification_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final NotificationRepository _repository;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  NotificationService(this._repository);

  Future<void> initListeners() async {
    // 1. Solicitar permisos
    await _repository.requestPermission();

    // 2. Configurar notificaciones locales para Android (Foreground)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: DarwinInitializationSettings(),
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        log(
          '[NotificationService] Click en notificación local: ${details.payload}',
        );
      },
    );

    // 3. Configurar listeners de mensajes
    _setupMessageListeners();

    // 4. Manejar mensaje inicial (App estaba cerrada)
    _handleInitialMessage();
  }

  Future<void> registerDevice() async {
    // 1. Manejar el token inicial (y guardarlo si hay auth)
    final token = await _repository.getToken();
    if (token != null) {
      await _repository.saveToken(token);
    }

    // 2. Escuchar refresco del token
    _tokenRefreshSubscription?.cancel(); // Cancel search prev subscription
    _tokenRefreshSubscription = _repository.onTokenRefresh.listen((
      newToken,
    ) async {
      log('[NotificationService] Token refrescado');
      await _repository.saveToken(newToken);
    });
  }

  void _setupMessageListeners() {
    // FOREGROUND: Cuando la app está abierta
    _messageSubscription = FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) {
      log(
        '[NotificationService] Mensaje en primer plano: ${message.notification?.title}',
      );

      final notification = NotificationModel.fromMap({
        'notification': {
          'title': message.notification?.title,
          'body': message.notification?.body,
        },
        'data': message.data,
      });

      _showLocalNotification(notification);
    });

    // BACKGROUND: Cuando la app está en segundo plano y el usuario toca la notificación
    _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen((
      RemoteMessage message,
    ) {
      log(
        '[NotificationService] App abierta desde segundo plano: ${message.notification?.title}',
      );

      // Aquí se podría navegar a una pantalla específica usando el payload
    });
  }

  Future<void> _handleInitialMessage() async {
    // TERMINATED: Cuando la app estaba cerrada y se abre desde una notificación
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      log(
        '[NotificationService] App abierta desde estado cerrada: ${initialMessage.notification?.title}',
      );
      // Manejar navegación inicial si es necesario
    }
  }

  Future<void> _showLocalNotification(NotificationModel notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'clinexa_channel_id',
          'Clinexa Notifications',
          channelDescription: 'Canal principal para notificaciones de Clinexa',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformChannelSpecifics,
      payload: notification.data.toString(),
    );
  }

  Future<void> unsubscribe() async {
    log('[NotificationService] Desuscribiendo notificaciones...');
    await _repository.deleteToken();
    await _messageSubscription?.cancel();
    await _messageOpenedSubscription?.cancel();
    await _tokenRefreshSubscription?.cancel();
    _messageSubscription = null;
    _messageOpenedSubscription = null;
    _tokenRefreshSubscription = null;
    log('[NotificationService] Desuscrito correctamente');
  }
}
