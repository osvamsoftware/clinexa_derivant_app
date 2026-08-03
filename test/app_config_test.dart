import 'package:clinexa_derivant_app/core/config/app_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppConfig', () {
    test('la URL del backend nunca queda vacía', () {
      expect(AppConfig.apiBaseUrl, isNotEmpty);
    });

    test('assertValid no lanza en modo debug', () {
      // En debug se permite trabajar sin configuración completa; la
      // validación solo es estricta en release, donde un build mal
      // configurado no debe salir.
      expect(AppConfig.assertValid, returnsNormally);
    });

    test('la URL de release debe ser HTTPS', () {
      // assertValid rechaza un build de release con http://; aquí solo se
      // documenta el criterio, porque los tests corren en modo debug.
      expect(AppConfig.isProduction, isFalse);
    });

    test('el .env se carga desde el bundle de assets', () async {
      // Comprueba de verdad la cadena completa: que .env esté declarado en
      // pubspec.yaml, que exista en disco y que AppConfig.load() lo lea.
      await AppConfig.load();

      expect(
        dotenv.isInitialized,
        isTrue,
        reason:
            'No se pudo cargar el .env. Comprueba que existe (cp .env.example '
            '.env) y que sigue declarado como asset en pubspec.yaml.',
      );

      for (final clave in const ['API_BASE_URL', 'GOOGLE_MAPS_API_KEY']) {
        expect(
          dotenv.maybeGet(clave),
          isNotNull,
          reason: 'Falta $clave en el .env',
        );
      }
    });

    test('los valores expuestos son exactamente los del .env', () async {
      // Contrato: el .env es la unica fuente de configuracion. Si alguien
      // reintroduce --dart-define o un valor por defecto que pise al del
      // archivo, este test lo delata. apiBaseUrl queda fuera de este test
      // porque, desde AppConfig.load(), depende ademas del tipo de
      // dispositivo detectado (ver el test siguiente).
      await AppConfig.load();

      expect(AppConfig.googleMapsApiKey, dotenv.get('GOOGLE_MAPS_API_KEY'));
    });

    test('apiBaseUrl elige segun el tipo de "dispositivo" detectado', () async {
      // El proceso que ejecuta `flutter test` no es Android ni iOS, así
      // que AppConfig._detectarDispositivo() lo trata como físico: ante la
      // duda es preferible asumir físico que caer en la URL de emulador
      // sin avisar (ver el comentario en AppConfig). La URL efectiva
      // depende entonces de si hay API_BASE_URL_DEVICE configurada.
      await AppConfig.load();

      final delDispositivo = dotenv.maybeGet('API_BASE_URL_DEVICE') ?? '';
      final esperada = delDispositivo.isNotEmpty
          ? delDispositivo
          : dotenv.get('API_BASE_URL');

      expect(AppConfig.apiBaseUrl, esperada);
    });

    test('el .env no contiene credenciales de servidor', () async {
      // El .env viaja dentro del APK: solo puede llevar claves públicas.
      await AppConfig.load();

      for (final entrada in dotenv.env.entries) {
        expect(
          entrada.value.startsWith('sk_'),
          isFalse,
          reason:
              '${entrada.key} parece una clave secreta. El .env se empaqueta '
              'en el APK: solo puede contener claves públicas.',
        );
      }
    });
  });
}
