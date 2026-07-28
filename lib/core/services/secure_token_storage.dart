import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Almacenamiento de tokens de sesión respaldado por el Keychain (iOS) y el
/// Keystore/EncryptedSharedPreferences (Android).
///
/// Antes los tokens vivían en `SharedPreferences`, que en móvil es un XML o
/// plist **sin cifrar**: legible en un dispositivo rooteado o desde un backup.
/// El refresh token de Firebase es de larga duración, así que quien lo
/// obtuviera mantenía la sesión indefinidamente.
///
/// Al arrancar se migran una sola vez los tokens que hubiera en el
/// almacenamiento antiguo y se borran de allí.
class SecureTokenStorage {
  static final SecureTokenStorage _instance = SecureTokenStorage._internal();
  factory SecureTokenStorage() => _instance;
  SecureTokenStorage._internal();

  static const _accessTokenKey = 'derivant_access_token';
  static const _refreshTokenKey = 'derivant_refresh_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  bool _migrated = false;

  /// Traslada los tokens del almacenamiento inseguro anterior, si existen.
  Future<void> _migrateLegacyTokensOnce() async {
    if (_migrated) return;
    _migrated = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final legacyAccess = prefs.getString(_accessTokenKey);
      final legacyRefresh = prefs.getString(_refreshTokenKey);

      if (legacyAccess != null || legacyRefresh != null) {
        if (legacyAccess != null) {
          await _storage.write(key: _accessTokenKey, value: legacyAccess);
        }
        if (legacyRefresh != null) {
          await _storage.write(key: _refreshTokenKey, value: legacyRefresh);
        }
        // Los valores en claro no deben sobrevivir a la migración.
        await prefs.remove(_accessTokenKey);
        await prefs.remove(_refreshTokenKey);
      }
    } catch (_) {
      // Un fallo migrando no debe impedir iniciar sesión de nuevo.
    }
  }

  Future<String?> readAccessToken() async {
    await _migrateLegacyTokensOnce();
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> readRefreshToken() async {
    await _migrateLegacyTokensOnce();
    return _storage.read(key: _refreshTokenKey);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
    } catch (_) {}
  }
}
