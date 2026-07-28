import 'package:clinexa_derivant_app/core/config/app_config.dart';

/// Acceso a la configuración de entorno.
///
/// Antes leía un `.env` empaquetado como asset: un archivo plano dentro del
/// APK/IPA, extraíble con `unzip`. Ahora los valores se inyectan en tiempo de
/// compilación con `--dart-define` (ver AppConfig).
class Env {
  const Env._();

  static String get googleMapsKey => AppConfig.googleMapsApiKey;
}
