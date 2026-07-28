import 'package:flutter/foundation.dart';

/// Configuración por entorno, inyectada en tiempo de compilación.
///
/// Antes las URLs se cambiaban comentando y descomentando líneas, y la clave
/// de Google Maps viajaba dentro de un `.env` empaquetado como asset — es
/// decir, dentro del APK, extraíble con `unzip`.
///
/// Build de producción:
/// ```
/// flutter build appbundle --release \
///   --dart-define=API_BASE_URL=https://api.clinexapp.com \
///   --dart-define=GOOGLE_MAPS_API_KEY=...
/// ```
class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  /// Restringida por bundle ID / SHA-1 en Google Cloud Console.
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
  );

  static bool get isProduction =>
      kReleaseMode && apiBaseUrl.startsWith('https://');

  /// Falla al arrancar si un build de release sale sin configurar, en vez de
  /// romper más tarde con un error confuso.
  static void assertValid() {
    if (!kReleaseMode) return;

    final missing = <String>[];
    if (!apiBaseUrl.startsWith('https://')) {
      missing.add('API_BASE_URL debe ser https en release');
    }
    if (googleMapsApiKey.isEmpty) missing.add('GOOGLE_MAPS_API_KEY');

    if (missing.isNotEmpty) {
      throw StateError(
        'Build de release mal configurado. Faltan --dart-define: '
        '${missing.join(", ")}',
      );
    }
  }
}
