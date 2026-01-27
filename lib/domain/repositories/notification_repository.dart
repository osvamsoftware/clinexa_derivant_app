import 'dart:async';
import 'dart:developer';
import 'package:clinexa_derivant_app/core/api/api.dart';
import 'package:clinexa_derivant_app/core/api/api_services.dart';
import 'package:clinexa_derivant_app/core/services/shared_prefs_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

abstract interface class NotificationRepository {
  Future<void> requestPermission();
  Future<String?> getToken();
  Stream<String> get onTokenRefresh;
  Future<void> saveToken(String token);
  Future<void> deleteToken();
}

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final ApiService _apiService = ApiService();
  final Api api;

  NotificationRepositoryImpl({required this.api});

  @override
  Future<void> requestPermission() async {
    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        log('[NotificationRepositoryImpl] El usuario otorgó permiso');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        log(
          '[NotificationRepositoryImpl] El usuario otorgó permiso provisional',
        );
      } else {
        log('[NotificationRepositoryImpl] El usuario rechazó el permiso');
      }
    } catch (e) {
      log('[NotificationRepositoryImpl.requestPermission] Error: $e');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      String? token = await _fcm.getToken();
      log('[NotificationRepositoryImpl] Token FCM: $token');
      return token;
    } catch (e) {
      log('[NotificationRepositoryImpl.getToken] Error: $e');
      return null;
    }
  }

  @override
  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;

  @override
  Future<void> saveToken(String token) async {
    try {
      final prefs = SharedPrefsService.instance;
      final savedToken = prefs.getString('fcm_token');

      // Si el token ya existe localmente y es igual al actual, no lo enviamos de nuevo
      if (savedToken == token) {
        log(
          '[NotificationRepositoryImpl] El token ya existe y no ha cambiado. Se omite el envio.',
        );
        return;
      }

      log('[NotificationRepositoryImpl] Enviando nuevo token al backend...');
      await _apiService.request(
        path: api.deviceToken,
        method: HttpMethod.post,
        body: {'device_token': token},
        fromJson: (json) => json,
        withAuth: true,
      );

      // Guardamos el token enviado exitosamente en local
      await prefs.setString('fcm_token', token);
      log(
        '[NotificationRepositoryImpl] Token guardado correctamente en backend y local',
      );
    } catch (e) {
      log('[NotificationRepositoryImpl.saveToken] Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      log('[NotificationRepositoryImpl] Eliminando token...');

      // 1. Eliminar de Firebase
      await _fcm.deleteToken();

      // 2. Eliminar de local storage
      await SharedPrefsService.instance.remove('fcm_token');

      log('[NotificationRepositoryImpl] Token eliminado correctamente');
    } catch (e) {
      log('[NotificationRepositoryImpl.deleteToken] Error: $e');
      // No relanzamos error crítico aquí para no romper el flujo de logout
    }
  }
}
