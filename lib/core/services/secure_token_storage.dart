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

  /// Lee del almacenamiento seguro tolerando un fallo del backend nativo.
  ///
  /// El Keystore de Android puede dejar los datos ilegibles tras ciertas
  /// actualizaciones del sistema o restauraciones. Si eso ocurre, `read()`
  /// lanza; propagarlo dejaría la app inutilizable, sin poder ni siquiera
  /// iniciar sesión de nuevo. Ante un fallo se limpia y se trata como
  /// "no hay sesión": el usuario vuelve a entrar y sigue trabajando.
  Future<String?> _readOrRecover(String key) async {
    try {
      await _migrateLegacyTokensOnce();
      return await _storage.read(key: key);
    } catch (_) {
      try {
        await _storage.deleteAll();
      } catch (_) {}
      return null;
    }
  }

  Future<String?> readAccessToken() => _readOrRecover(_accessTokenKey);

  Future<String?> readRefreshToken() => _readOrRecover(_refreshTokenKey);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clear() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
    } catch (_) {
      // Cerrar sesión nunca debe fallar por un problema del almacenamiento.
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
    } catch (_) {}
  }
}
