import 'package:clinexa_derivant_app/core/config/app_config.dart';

/// Atajo a los valores de configuración que usa la capa de datos.
///
/// La fuente es siempre [AppConfig], que los lee del archivo `.env`. Esta
/// clase existe solo para no acoplar los repositorios a AppConfig.
class Env {
  const Env._();

  static String get googleMapsKey => AppConfig.googleMapsApiKey;
}
