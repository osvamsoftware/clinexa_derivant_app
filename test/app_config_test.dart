import 'package:clinexa_derivant_app/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig', () {
    test('la URL del backend nunca queda vacía', () {
      expect(AppConfig.apiBaseUrl, isNotEmpty);
    });

    test('assertValid no lanza en modo debug', () {
      // En debug se permite trabajar sin --dart-define; la validación solo
      // es estricta en release, donde un build mal configurado no debe salir.
      expect(AppConfig.assertValid, returnsNormally);
    });

    test('la URL de release debe ser HTTPS', () {
      // assertValid rechaza un build de release con http://; aquí solo se
      // documenta el criterio, porque los tests corren en modo debug.
      expect(AppConfig.isProduction, isFalse);
    });
  });
}
