import 'package:clinexa_derivant_app/core/constants/paths.dart';
import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/login/login_screen.dart';
import 'package:clinexa_derivant_app/presentation/register/register_personal_screen.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  static const path = "/welcome";

  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const WelcomeView();
  }
}

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // 🔹 Logo
                SvgPicture.asset(paths.completeLogoSvg),

                // 🔹 Descripción
                Text(
                  s.welcomeDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.neutral20,
                    fontSize: 15.5,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 32),
                Spacer(),
                // 🔹 Botón Log In
                CustomButton(
                  height: 50,
                  width: 200,
                  text: s.login,
                  onPressed: () => context.push(LoginScreen.path),
                ),

                const SizedBox(height: 16),

                // 🔹 Botón Sign Up
                CustomButton(
                  width: 200,
                  text: s.signup,
                  opacity: true,
                  textColor: AppColors.primary20,
                  onPressed: () => context.push(RegisterPersonalScreen.path),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
