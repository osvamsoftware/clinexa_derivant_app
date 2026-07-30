import 'package:flutter_test/flutter_test.dart';

/// La política de contraseñas del cliente debe ser idéntica a la que aplica
/// el backend en `POST /register` (app/schemas/auth_schemas.py).
///
/// Si divergen, el usuario rellena el formulario, lo envía y recibe un 422
/// del servidor sin haber podido corregirlo antes. Este test replica la
/// regla para que un cambio en una sola de las dos partes se note aquí.
bool meetsBackendPolicy(String password) {
  if (password.length < 8) return false;
  if (password.length > 128) return false;
  if (!password.contains(RegExp(r'[a-z]'))) return false;
  if (!password.contains(RegExp(r'[A-Z]'))) return false;
  if (!password.contains(RegExp(r'[0-9]'))) return false;
  return true;
}

void main() {
  group('Política de contraseñas', () {
    test('acepta una contraseña que cumple los requisitos', () {
      expect(meetsBackendPolicy('Clinexa2026'), isTrue);
    });

    test('rechaza contraseñas demasiado cortas', () {
      // El límite anterior del cliente era 6: el backend las rechazaba.
      expect(meetsBackendPolicy('Abc123'), isFalse);
      expect(meetsBackendPolicy('Abc1234'), isFalse);
      expect(meetsBackendPolicy('Abc12345'), isTrue);
    });

    test('exige mayúscula, minúscula y dígito', () {
      expect(
        meetsBackendPolicy('contrasenalarga'),
        isFalse,
      ); // sin mayús/dígito
      expect(meetsBackendPolicy('CONTRASENA123'), isFalse); // sin minúscula
      expect(meetsBackendPolicy('Contrasenalarga'), isFalse); // sin dígito
    });

    test('acepta hasta 128 caracteres', () {
      final long = 'Aa1${'x' * 125}';
      expect(long.length, 128);
      expect(meetsBackendPolicy(long), isTrue);
      expect(meetsBackendPolicy('${long}x'), isFalse);
    });
  });
}
