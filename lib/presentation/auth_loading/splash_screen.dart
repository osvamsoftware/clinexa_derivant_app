import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/cubit/auth_cubit.dart';
import 'package:clinexa_derivant_app/presentation/user_status/user_status_check_screen.dart';
import 'package:clinexa_derivant_app/presentation/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
    final theme = Theme.of(context);
    final s = S.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) async {
          if (!state.initialized) return;
          await Future.delayed(Duration(milliseconds: 500));
          if (state.user != null) {
            context.go(
              SessionCheckScreen.path,
              extra: context.read<AuthCubit>().state.user!.id,
            );
          } else {
            context.go(WelcomeScreen.path);
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpinKitPulse(
                size: 120,
                duration: const Duration(milliseconds: 1500),
                color: theme.colorScheme.primary,
              ),

              const SizedBox(height: 32),

              // ⭐ Texto animado
              AnimatedTextKit(
                repeatForever: true,
                animatedTexts: [
                  FadeAnimatedText(
                    s.appName,
                    duration: const Duration(seconds: 2),
                    textStyle: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FadeAnimatedText(
                    s.loading,
                    duration: const Duration(seconds: 2),
                    textStyle: theme.textTheme.titleLarge,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
