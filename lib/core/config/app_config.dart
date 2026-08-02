import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración de la aplicación, leída del archivo `.env`.
///
/// Un único sitio para todo: desarrollo y producción se configuran igual,
/// editando el `.env` de la raíz del proyecto. No hay que pasar argumentos al
/// compilar ni al arrancar.
///
/// ```
/// cp .env.example .env    # la primera vez
/// flutter run             # desarrollo
/// flutter build ipa       # producción, con los valores de producción en el .env
/// ```
///
/// El `.env` está declarado como asset en `pubspec.yaml`, así que se empaqueta
/// dentro del APK y del IPA y se puede extraer con `unzip`. La clave de Google
/// Maps que va ahí es pública por diseño —viaja en cada petición que hace la
/// app—: lo que la protege es la restricción por bundle ID / SHA-1 en Google
/// Cloud Console, no esconderla.
///
/// **Nunca pongas aquí credenciales de servidor.**
class AppConfig {
  const AppConfig._();

  /// Carga el `.env`. Se llama al arrancar, antes de leer ningún valor.
  ///
  /// Si el archivo no existe, los valores quedan vacíos y [assertValid] lo
  /// detecta: en release corta el arranque, y en desarrollo lo avisa por
  /// consola [debugPrintConfig].
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Sin .env se arranca con los valores vacíos; assertValid decide.
    }
  }

  static String _leer(String clave, {String fallback = ''}) {
    if (!dotenv.isInitialized) return fallback;
    final valor = dotenv.maybeGet(clave);
    return (valor == null || valor.isEmpty) ? fallback : valor;
  }

  static String get apiBaseUrl =>
      _leer('API_BASE_URL', fallback: 'http://10.0.2.2:8000');

  /// Restringida por bundle ID / SHA-1 en Google Cloud Console.
  static String get googleMapsApiKey => _leer('GOOGLE_MAPS_API_KEY');

  static bool get isProduction =>
      kReleaseMode && apiBaseUrl.startsWith('https://');

  /// Imprime en consola la configuración que se cargó.
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
    debugPrint('  CONFIGURACION CARGADA');
    debugPrint('  .env: ${dotenv.isInitialized ? "cargado" : "NO cargado"}');
    debugPrint(separador);
    debugPrint(_describe('API_BASE_URL          ', apiBaseUrl));
    debugPrint(_describe('GOOGLE_MAPS_API_KEY   ', googleMapsApiKey));
    debugPrint(separador);

    final faltantes = <String>[
      if (apiBaseUrl.isEmpty) 'API_BASE_URL',
      if (googleMapsApiKey.isEmpty) 'GOOGLE_MAPS_API_KEY',
    ];

    if (faltantes.isEmpty) {
      debugPrint('  OK: configuracion completa');
    } else {
      debugPrint('  FALTA: ${faltantes.join(', ')}');
      debugPrint('');
      debugPrint('  Comprueba que exista el archivo .env en la raiz del');
      debugPrint('  proyecto con esas claves. Si acabas de crearlo:');
      debugPrint('    flutter clean && flutter pub get');
    }
    debugPrint(separador);
    debugPrint('');
  }

  static String _describe(String nombre, String valor) {
    if (valor.isEmpty) return '  $nombre = (VACIA)';
    return '  $nombre = $valor   [${valor.length} caracteres]';
  }

  /// Comprueba que el `.env` está completo antes de seguir.
  ///
  /// En release es estricto: un build mal configurado no debe publicarse, así
  /// que es preferible que falle en tu Mac a que llegue roto a la tienda.
  /// En desarrollo no bloquea; el aviso lo da [debugPrintConfig].
  static void assertValid() {
    if (!kReleaseMode) return;

    final missing = <String>[];
    if (!apiBaseUrl.startsWith('https://')) {
      missing.add(
        'API_BASE_URL debe ser https en release (ahora: '
        '"$apiBaseUrl")',
      );
    }
    if (googleMapsApiKey.isEmpty) missing.add('GOOGLE_MAPS_API_KEY');

    if (missing.isNotEmpty) {
      throw StateError(
        'El .env no está listo para un build de release. '
        'Revisa: ${missing.join(", ")}',
      );
    }
  }
}
