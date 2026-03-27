import 'dart:developer';
import 'dart:io';

import 'package:clinexa_derivant_app/core/api/api.dart';
import 'package:clinexa_derivant_app/core/api/api_services.dart';
import 'package:clinexa_derivant_app/core/services/shared_prefs_service.dart';
import 'package:clinexa_derivant_app/data/models/api_response_model.dart';
import 'package:clinexa_derivant_app/data/models/notification_model.dart';
import 'package:clinexa_derivant_app/domain/repositories/notification_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
    log('[NotificationRepositoryImpl] Iniciando getToken()...', name: 'NotificationRepo');
    try {
      if (Platform.isIOS) {
        log('[NotificationRepositoryImpl] Detectado plataforma iOS. Intentando obtener APNs token...', name: 'NotificationRepo');
        final apnsToken = await _fcm.getAPNSToken();
        log('[NotificationRepositoryImpl] APNs token crudo respondido: $apnsToken', name: 'NotificationRepo');
        if (apnsToken == null) {
          log('[NotificationRepositoryImpl] APNs token es null. Esperando 3 segundos...', name: 'NotificationRepo');
          await Future.delayed(const Duration(seconds: 3));
          final apnsRetry = await _fcm.getAPNSToken();
          log('[NotificationRepositoryImpl] APNs token tras delay: $apnsRetry', name: 'NotificationRepo');
          if (apnsRetry != null) {
            log('[NotificationRepositoryImpl] ÉXITO: Usando APNs token nativo: $apnsRetry', name: 'NotificationRepo');
            return apnsRetry;
          }
        } else {
          log('[NotificationRepositoryImpl] ÉXITO: Usando APNs token nativo: $apnsToken', name: 'NotificationRepo');
          return apnsToken;
        }
      }
      log('[NotificationRepositoryImpl] Intentando obtener FCM token standar...', name: 'NotificationRepo');
      String? token = await _fcm.getToken();
      log('[NotificationRepositoryImpl] Token FCM generado: $token', name: 'NotificationRepo');
      if (token != null) {
        log('[NotificationRepositoryImpl] Longitud del token: ${token.length} | Es iOS: ${Platform.isIOS}', name: 'NotificationRepo');
      } else {
        log('[NotificationRepositoryImpl] ERROR: Token FCM retornado null. Verifica google-services.json / GoogleService-Info.plist y permisos.', name: 'NotificationRepo');
      }
      return token;
    } catch (e) {
      log('[NotificationRepositoryImpl.getToken] EXCEPCION: $e', name: 'NotificationRepo');
      return null;
    }
  }

  @override
  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;

  @override
  Future<void> saveToken(String token) async {
    log('[NotificationRepositoryImpl] saveToken() llamado con token de longitud: ${token.length}', name: 'NotificationRepo');
    try {
      final prefs = SharedPrefsService.instance;
      // final savedToken = prefs.getString('derivant_fcm_token');
 
      // Si el token ya existe localmente y es igual al actual, no lo enviamos de nuevo
      // COMENTADO TEMPORALMENTE: Forzar registro en cada inicio para asegurar sincronización con backend
      /* if (savedToken == token) {
        log(
          '[NotificationRepositoryImpl] El token ya existe y no ha cambiado. Se omite el envio.',
          name: 'NotificationRepo'
        );
        return;
      } */
 
      log('[NotificationRepositoryImpl] Preparando request POST al backend...', name: 'NotificationRepo');
 
      final platform = Platform.isAndroid
          ? 'android'
          : (Platform.isIOS ? 'ios' : 'unknown');
 
      final bundleId = Platform.isIOS ? 'com.clinexapp.conecta' : 'com.clinexapp.derivante';
      
      log('[NotificationRepositoryImpl] Endpoint: ${api.deviceToken}', name: 'NotificationRepo');
      log('[NotificationRepositoryImpl] Payload: token: $token, platform: $platform, bundle_id: $bundleId', name: 'NotificationRepo');

      final response = await _apiService.request(
        path: api.deviceToken,
        method: HttpMethod.post,
        body: {
          'device_token': token, 
          'platform': platform,
          'bundle_id': bundleId,
        },
        fromJson: (json) => json,
        withAuth: true,
      );
 
      log('[NotificationRepositoryImpl] ÉXITO: Respuesta del backend: $response', name: 'NotificationRepo');

      // Guardamos el token enviado exitosamente en local
      await prefs.setString('derivant_fcm_token', token);
      log('[NotificationRepositoryImpl] Token persistido localmente en SharedPrefs', name: 'NotificationRepo');
    } catch (e) {
      log('[NotificationRepositoryImpl.saveToken] ERROR/EXCEPCION: $e', name: 'NotificationRepo');
      // Comentado para no romper flujos si falla el registro silencioso
      // rethrow;
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      log('[NotificationRepositoryImpl] Eliminando token...');

      // 1. Eliminar de Firebase
      await _fcm.deleteToken();

      // 2. Eliminar de local storage
      await SharedPrefsService.instance.remove('derivant_fcm_token');

      log('[NotificationRepositoryImpl] Token eliminado correctamente');
    } catch (e) {
      log('[NotificationRepositoryImpl.deleteToken] Error: $e');
      // No relanzamos error crítico aquí para no romper el flujo de logout
    }
  }

  @override
  Future<ApiResponseModel<NotificationModel>> getNotifications(
    String userId, {
    int limit = 50,
    int skip = 0,
  }) async {
    try {
      final response = await _apiService.request<NotificationModel>(
        path: api.getUserNotifications(userId),
        method: HttpMethod.get,
        query: {'limit': limit.toString(), 'skip': skip.toString()},
        fromJson: (json) => NotificationModel.fromMap(json),
        withAuth: true,
      );
      return response;
    } catch (e) {
      log('[NotificationRepositoryImpl.getNotifications] Error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _apiService.request(
        path: api.markNotificationRead(notificationId),
        method: HttpMethod.put,
        fromJson: (json) => json,
        withAuth: true,
      );
      return true;
    } catch (e) {
      log('[NotificationRepositoryImpl.markAsRead] Error: $e');
      return false;
    }
  }
}
