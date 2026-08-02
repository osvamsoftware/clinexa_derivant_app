import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración de la aplicación.
///
/// Los valores se resuelven en este orden:
///
/// 1. **`--dart-define`**, si se pasó al compilar. Es lo que se usa en los
///    builds de producción.
/// 2. **`.env`**, que se carga al arrancar. Es lo que permite lanzar la app
///    con `flutter run` sin argumentos durante el desarrollo.
///
/// ⚠️ **El `.env` está declarado como asset en `pubspec.yaml`.** Eso significa
/// que el archivo —y las claves que contenga— viaja **dentro del APK y del
/// IPA**, y se puede extraer con `unzip`. Es una decisión consciente, a
/// cambio de poder arrancar sin argumentos.
///
/// La clave de Google Maps es pública por diseño; lo que la protege es la
/// restricción por bundle ID / SHA-1 en Google Cloud Console, no el
/// esconderla. **Nunca pongas aquí credenciales de servidor.**
///
/// Para producción, lo más seguro es compilar con `--dart-define` y dejar el
/// `.env` vacío, de modo que el paquete no lleve nada dentro:
///
/// ```
/// flutter build appbundle --release \
///   --dart-define=API_BASE_URL=https://api.clinexapp.com \
///   --dart-define=GOOGLE_MAPS_API_KEY=...
/// ```
class AppConfig {
  const AppConfig._();

  // --- Valores de compilación (tienen prioridad) ---------------------
  static const String _apiBaseUrlDefine = String.fromEnvironment(
    'API_BASE_URL',
  );
  static const String _mapsKeyDefine = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
  );

  /// Carga el `.env`. Debe llamarse antes de leer cualquier valor.
  ///
  /// No falla si el archivo no existe: un build de producción hecho con
  /// `--dart-define` puede llevar el `.env` vacío.
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Sin .env se usan los valores de compilación.
    }
  }

  /// Lee una variable: primero de `--dart-define`, luego del `.env`.
  static String _read(
    String clave,
    String desdeDefine, {
    String fallback = '',
  }) {
    if (desdeDefine.isNotEmpty) return desdeDefine;
    if (dotenv.isInitialized) {
      final valor = dotenv.maybeGet(clave);
      if (valor != null && valor.isNotEmpty) return valor;
    }
    return fallback;
  }

  static String get apiBaseUrl => _read(
    'API_BASE_URL',
    _apiBaseUrlDefine,
    fallback: 'http://10.0.2.2:8000',
  );

  /// Restringida por bundle ID / SHA-1 en Google Cloud Console.
  static String get googleMapsApiKey =>
      _read('GOOGLE_MAPS_API_KEY', _mapsKeyDefine);

  static bool get isProduction =>
      kReleaseMode && apiBaseUrl.startsWith('https://');

  /// Imprime la configuración cargada, para confirmar de dónde salió.
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
        'Build de release mal configurado. Faltan: ${missing.join(", ")}',
      );
    }
  }
}
