import 'package:clinexa_derivant_app/core/constants/paths.dart';
import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_button.dart';
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

    return PopScope(
      // Sin botón atrás: forzamos a que se resuelva con el botón de salida,
      // no dejando una sesión a medio cerrar por un gesto accidental.
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.neutral100,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(paths.completeLogoSvg, height: 90),
                const SizedBox(height: 40),
                const Icon(
                  Icons.swap_horiz_rounded,
                  size: 64,
                  color: AppColors.primary40,
                ),
                const SizedBox(height: 24),
                Text(
                  s.wrongRoleTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary40,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  s.wrongRoleMessageDerivante,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.neutral50,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: 200,
                  child: CustomButton(
                    text: s.wrongRoleExitButton,
                    height: 48,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
