import 'package:clinexa_derivant_app/core/constants/paths.dart';
import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Pantalla de bloqueo cuando alguien inicia sesión en la app de derivantes
/// con credenciales de un médico receptor.
///
/// Antes esto se resolvía con un diálogo de error que reutilizaba el texto
/// de "este email ya está registrado" del flujo de registro — un mensaje sin
/// sentido en el contexto de iniciar sesión. Ver
/// `core/services/role_guard.dart`.
///
/// Se muestra como una ruta a pantalla completa por encima del login, no
/// como un diálogo, para que sea imposible seguir usando la app por error:
/// la única salida es el botón, que cierra la sesión que el cubit ya limpió.
class WrongRoleScreen extends StatelessWidget {
  const WrongRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.clx;
    final t = context.clxText;

    return PopScope(
      // Sin botón atrás: forzamos a que se resuelva con el botón de salida,
      // no dejando una sesión a medio cerrar por un gesto accidental.
      canPop: false,
      child: Scaffold(
        backgroundColor: c.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ClxSpace.s6),
            child: Column(
              children: [
                const SizedBox(height: ClxSpace.s8),
                SvgPicture.asset(paths.nameLogoSvg, height: 40),
                const Spacer(),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: c.warningSoft,
                    borderRadius: BorderRadius.circular(ClxRadius.lg),
                  ),
                  child: Icon(LucideIcons.arrowLeftRight, size: 30, color: c.warning),
                ),
                const SizedBox(height: ClxSpace.s6),
                Text(s.wrongRoleTitle, textAlign: TextAlign.center, style: t.h1),
                const SizedBox(height: ClxSpace.s3),
                Text(
                  s.wrongRoleMessageDerivante,
                  textAlign: TextAlign.center,
                  style: t.bodyMuted,
                ),
                const Spacer(),
                ClxButton(
                  label: s.wrongRoleExitButton,
                  icon: LucideIcons.logOut,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: ClxSpace.s4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
