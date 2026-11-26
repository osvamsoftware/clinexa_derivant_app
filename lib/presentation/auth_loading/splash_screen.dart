import 'package:clinexa_derivant_app/core/constants/paths.dart';
import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/cubit/auth_cubit.dart';
import 'package:clinexa_derivant_app/presentation/user_status/user_status_check_screen.dart';
import 'package:clinexa_derivant_app/presentation/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  static const path = "/splash";
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SplashView();
  }
}

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final s = S.of(context);

    return Scaffold(
      backgroundColor: c.brandBlue,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) async {
          if (!state.initialized) return;
          await Future.delayed(Duration(milliseconds: 500));
          if (!context.mounted) return;
          if (state.status == AuthStatus.loading) return;
          if (state.user != null) {
            context.go(
              SessionCheckScreen.path,
              extra: context.read<AuthCubit>().state.user!.id,
            );
          } else {
            context.go(WelcomeScreen.path);
          }
        },
        // Pieza de marca: degradado del logo de borde a borde y el logo
        // sobre su placa clara. Sin texto sobre el degradado.
        child: Container(
          decoration: BoxDecoration(gradient: c.brandGradient),
          alignment: Alignment.center,
          child: Semantics(
            label: s.loading,
            child: ClxLogoPlate(
              padding: const EdgeInsets.fromLTRB(ClxSpace.s8, ClxSpace.s8, ClxSpace.s8, ClxSpace.s6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(paths.completeLogoSvg, height: 120),
                  const SizedBox(height: ClxSpace.s6),
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: ClxColors.brandBlue),
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
