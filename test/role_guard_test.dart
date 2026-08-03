import 'package:clinexa_derivant_app/core/services/role_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isWrongApp', () {
    test('bloquea el rol real de la app receptora', () {
      expect(isWrongApp('receptor'), isTrue);
    });

    test('permite el propio rol de esta app', () {
      expect(isWrongApp('derivant'), isFalse);
    });

    test('no bloquea admin ni otros roles', () {
      expect(isWrongApp('admin'), isFalse);
      expect(isWrongApp('user'), isFalse);
    });

    test('el código de error coincide con el rol bloqueado', () {
      expect(kWrongRoleErrorCode, 'wrong_role_receptor');
    });
  });
}
