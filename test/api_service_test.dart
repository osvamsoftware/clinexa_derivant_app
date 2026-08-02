import 'package:clinexa_derivant_app/core/api/api_services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiException', () {
    test('conserva el código de estado y el mensaje', () {
      final exception = ApiException('Sin permisos', 403);

      expect(exception.statusCode, 403);
      expect(exception.message, 'Sin permisos');
      expect(exception.toString(), contains('403'));
    });
  });

  group('ApiService', () {
    test('es un singleton', () {
      expect(identical(ApiService(), ApiService()), isTrue);
    });

    test('usa la URL configurada en el .env', () {
      expect(ApiService().baseUrl, isNotEmpty);
    });
  });
}
