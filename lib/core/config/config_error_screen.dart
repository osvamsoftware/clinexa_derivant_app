import 'package:flutter/material.dart';

/// Pantalla que se muestra cuando el `.env` no está listo para un build de
/// release.
///
/// Sin esto, `AppConfig.assertValid()` lanzaba dentro de `main()` y Flutter
/// se limitaba a registrar la excepción: el proceso seguía vivo y la app se
/// quedaba **en la pantalla de lanzamiento para siempre**, sin ningún mensaje.
/// Desde fuera parece que está cargando, y el motivo real solo aparecía en
/// `logcat` o en la consola de Xcode.
///
/// Es un fallo que solo puede darse en un build mal compilado, así que quien
/// lo va a ver es quien lo compiló: el texto está pensado para esa persona.
class ConfigErrorScreen extends StatelessWidget {
  final String detalle;

  const ConfigErrorScreen({super.key, required this.detalle});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0D2B45),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.settings_outlined,
                    color: Colors.white70,
                    size: 56,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Configuración incompleta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Esta versión se compiló sin la configuración necesaria, '
                    'así que no puede funcionar.',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      detalle,
                      style: const TextStyle(
                        color: Color(0xFFFFCDD2),
                        fontSize: 13,
                        fontFamily: 'monospace',
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Revisa el archivo .env del proyecto y vuelve a compilar.',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
