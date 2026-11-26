import 'package:clinexa_derivant_app/core/constants/paths.dart';
import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/login/login_screen.dart';
import 'package:clinexa_derivant_app/presentation/register/register_personal_screen.dart';
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
    final c = context.clx;
    final t = context.clxText;
    final height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: c.surface,
      body: Column(
        children: [
          // Pieza de marca: degradado del logo con el logotipo sobre placa.
          ClxBrandHeader(
            height: height * 0.46,
            child: SafeArea(
              bottom: false,
              child: Center(
                child: ClxLogoPlate(
                  padding: const EdgeInsets.all(ClxSpace.s6),
                  child: SvgPicture.asset(paths.completeLogoSvg, height: 132),
                ),
              ),
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(ClxSpace.s6, ClxSpace.s8, ClxSpace.s6, ClxSpace.s4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.welcomeSubtitle.toUpperCase(), style: t.label.copyWith(color: c.brandTealText)),
                    const SizedBox(height: ClxSpace.s2),
                    Text(s.welcomeHeadline, style: t.display),
                    const SizedBox(height: ClxSpace.s3),
                    Text(s.welcomeDescription, style: t.bodyMuted),
                    const Spacer(),
                    ClxButton(
                      key: const Key('welcome_login_button'),
                      label: s.login,
                      pill: true,
                      onPressed: () => context.push(LoginScreen.path),
                    ),
                    const SizedBox(height: ClxSpace.s3),
                    ClxButton.secondary(
                      key: const Key('welcome_signup_button'),
                      label: s.signup,
                      pill: true,
                      onPressed: () => context.push(RegisterPersonalScreen.path),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
