import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
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

  static bool? _esDispositivoFisico;

  /// Carga el `.env` y detecta si se está corriendo en un dispositivo físico
  /// o en un emulador/simulador. Se llama al arrancar, antes de leer ningún
  /// valor.
  ///
  /// Si el `.env` no existe, los valores quedan vacíos y [assertValid] lo
  /// detecta: en release corta el arranque, y en desarrollo lo avisa por
  /// consola [debugPrintConfig].
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Sin .env se arranca con los valores vacíos; assertValid decide.
    }
    await _detectarDispositivo();
  }

  /// Determina si el proceso corre en un dispositivo físico.
  ///
  /// Solo importa para elegir la URL en desarrollo (ver [apiBaseUrl]): en
  /// release siempre se usa `API_BASE_URL` tal cual, sin este chequeo.
  ///
  /// Ante cualquier fallo de la plataforma se asume dispositivo físico: es la
  /// opción más conservadora, porque de lo contrario un iPhone real caería
  /// silenciosamente en la URL de emulador y ninguna petición llegaría a
  /// destino.
  static Future<void> _detectarDispositivo() async {
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        _esDispositivoFisico = (await info.androidInfo).isPhysicalDevice;
      } else if (Platform.isIOS) {
        _esDispositivoFisico = (await info.iosInfo).isPhysicalDevice;
      } else {
        _esDispositivoFisico = true;
      }
    } catch (_) {
      _esDispositivoFisico = true;
    }
  }

  static String _leer(String clave, {String fallback = ''}) {
    if (!dotenv.isInitialized) return fallback;
    final valor = dotenv.maybeGet(clave);
    return (valor == null || valor.isEmpty) ? fallback : valor;
  }

  static const String _apiBaseUrlFallback = 'http://10.0.2.2:8000';

  /// URL del backend para builds de producción, y valor por defecto en
  /// desarrollo cuando no aplica ninguna ruta específica por dispositivo.
  static String get _apiBaseUrlGeneral =>
      _leer('API_BASE_URL', fallback: _apiBaseUrlFallback);

  /// URL para depuración manual en un dispositivo físico (el iPhone o el
  /// Android reales conectados por USB o WiFi), normalmente la IP local de
  /// la Mac. Solo se usa fuera de release.
  static String get _apiBaseUrlDispositivo => _leer('API_BASE_URL_DEVICE');

  /// URL del backend.
  ///
  /// En release es siempre `API_BASE_URL` (debe ser https,
  /// [assertValid] lo exige).
  ///
  /// En desarrollo se elige sola según en qué se esté corriendo la app:
  /// - **Dispositivo físico** → `API_BASE_URL_DEVICE`, si está configurada.
  ///   Sin ella, cae en `API_BASE_URL` de todos modos (y [debugPrintConfig]
  ///   lo avisa), porque es mejor seguir con una URL que probablemente no
  ///   funcione que no arrancar.
  /// - **Emulador o simulador** → `API_BASE_URL`, como siempre.
  ///
  /// Antes había que editar el `.env` a mano cada vez que se cambiaba entre
  /// probar en el emulador y en un teléfono real.
  static String get apiBaseUrl {
    if (kReleaseMode) return _apiBaseUrlGeneral;

    if (_esDispositivoFisico == true) {
      final delDispositivo = _apiBaseUrlDispositivo;
      if (delDispositivo.isNotEmpty) return delDispositivo;
    }

    return _apiBaseUrlGeneral;
  }

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
    debugPrint(
      '  dispositivo: ${_esDispositivoFisico == true ? "fisico" : "emulador/simulador"}',
    );
    debugPrint(separador);
    debugPrint(_describe('API_BASE_URL          ', _apiBaseUrlGeneral));
    if (_esDispositivoFisico == true) {
      debugPrint(_describe('API_BASE_URL_DEVICE   ', _apiBaseUrlDispositivo));
    }
    debugPrint('  -> URL en uso: $apiBaseUrl');
    debugPrint(_describe('GOOGLE_MAPS_API_KEY   ', googleMapsApiKey));
    debugPrint(separador);

    final faltantes = <String>[
      if (googleMapsApiKey.isEmpty) 'GOOGLE_MAPS_API_KEY',
    ];
    if (_esDispositivoFisico == true && _apiBaseUrlDispositivo.isEmpty) {
      debugPrint(
        '  AVISO: estás en un dispositivo físico y falta '
        'API_BASE_URL_DEVICE en el .env. Usando API_BASE_URL, que '
        'probablemente no es alcanzable desde este dispositivo.',
      );
    }

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
    if (!_apiBaseUrlGeneral.startsWith('https://')) {
      missing.add(
        'API_BASE_URL debe ser https en release (ahora: '
        '"$_apiBaseUrlGeneral")',
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
