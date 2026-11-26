// Driver del recorrido visual: guarda en disco cada captura que pide la
// prueba con `binding.takeScreenshot(nombre)`.
//
// Uso:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/recorrido_capturas_test.dart \
//     --dart-define=CLX_THEME=light -d <simulador>
//
// Las capturas van a CLX_CAPTURAS_DIR o, si no se define, a
// ../capturas-rediseno/derivante (fuera del repo).
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final dir =
      Platform.environment['CLX_CAPTURAS_DIR'] ??
      '${Directory.current.parent.path}/capturas-rediseno/derivante';
  await integrationDriver(
    onScreenshot:
        (String name, List<int> bytes, [Map<String, Object?>? args]) async {
          final file = File('$dir/$name.png');
          await file.create(recursive: true);
          await file.writeAsBytes(bytes);
          return true;
        },
  );
}
