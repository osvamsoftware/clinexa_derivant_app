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

  /// Imprime la configuración cargada, para confirmar que el `.env` llegó.
  ///
  /// **Solo en debug.** En release no se ejecuta, así que las claves nunca
  /// aparecen en los registros del dispositivo de un usuario.
  ///
  /// Se imprime línea a línea: `debugPrint` trunca los mensajes largos y
  /// podría comerse justo lo que se quiere ver.
  static void debugPrintConfig() {
    if (!kDebugMode) return;

    const separador =
        '=================================================================';

    debugPrint('');
    debugPrint(separador);
    debugPrint('  CONFIGURACION RECIBIDA (.env)');
    debugPrint(separador);
    debugPrint(_describe('API_BASE_URL          ', apiBaseUrl));
    debugPrint(_describe('GOOGLE_MAPS_API_KEY   ', googleMapsApiKey));
    debugPrint(separador);

    final faltantes = <String>[
      if (apiBaseUrl.isEmpty) 'API_BASE_URL',
      if (googleMapsApiKey.isEmpty) 'GOOGLE_MAPS_API_KEY',
    ];

    if (faltantes.isEmpty) {
      debugPrint('  OK: la app esta usando el .env');
    } else {
      debugPrint('  FALTA: ${faltantes.join(', ')}');
      debugPrint('');
      debugPrint('  La app NO recibio el .env. Arrancala con:');
      debugPrint('    ./run_dev.sh');
      debugPrint('  o con la configuracion del IDE (boton Run).');
      debugPrint('');
      debugPrint('  Un hot reload no basta: el .env se lee al compilar.');
    }
    debugPrint(separador);
    debugPrint('');
  }

  static String _describe(String nombre, String valor) {
    if (valor.isEmpty) return '  $nombre = (VACIA)';
    return '  $nombre = $valor   [${valor.length} caracteres]';
  }

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
