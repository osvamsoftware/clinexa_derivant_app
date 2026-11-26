import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
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
    // Se pinta fuera del árbol normal de la app (antes de cargar la
    // configuración), así que usa el tema del sistema directamente.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: Builder(
        builder: (context) {
          final c = context.clx;
          final t = context.clxText;
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(ClxSpace.s6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: c.dangerSoft,
                          borderRadius: BorderRadius.circular(ClxRadius.lg),
                        ),
                        child: Icon(
                          LucideIcons.settings,
                          color: c.danger,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: ClxSpace.s6),
                      Text('Configuración incompleta', style: t.h1),
                      const SizedBox(height: ClxSpace.s3),
                      Text(
                        'Esta versión se compiló sin la configuración necesaria, '
                        'así que no puede funcionar.',
                        style: t.bodyMuted,
                      ),
                      const SizedBox(height: ClxSpace.s6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(ClxSpace.s4),
                        decoration: BoxDecoration(
                          color: c.surfaceSunken,
                          border: Border.all(color: c.border),
                          borderRadius: BorderRadius.circular(ClxRadius.md),
                        ),
                        child: Text(
                          detalle,
                          style: t.data.copyWith(fontSize: 13, color: c.danger),
                        ),
                      ),
                      const SizedBox(height: ClxSpace.s6),
                      Text(
                        'Revisa el archivo .env del proyecto y vuelve a compilar.',
                        style: t.bodySm,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
