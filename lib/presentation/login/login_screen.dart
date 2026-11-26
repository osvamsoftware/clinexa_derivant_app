import 'package:clinexa_derivant_app/core/constants/paths.dart';
import 'package:clinexa_derivant_app/core/services/error_handler.dart';
import 'package:clinexa_derivant_app/core/services/role_guard.dart';
import 'package:clinexa_derivant_app/core/services/validators.dart';
import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/login/cubit/login_cubit.dart';
import 'package:clinexa_derivant_app/presentation/login/wrong_role_screen.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/cubit/auth_cubit.dart';
import 'package:clinexa_derivant_app/core/services/notification_service.dart';
import 'package:clinexa_derivant_app/domain/auth_repository.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/splash_screen.dart';
import 'package:clinexa_derivant_app/presentation/register/register_personal_screen.dart';
import 'package:clinexa_derivant_app/presentation/password_recovery/forgot_password/forgot_password_screen.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  static const path = "/login";

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthLoginCubit(
        context.read<AuthRepository>(),
        context.read<NotificationService>(),
      ),
      child: BlocListener<AuthLoginCubit, AuthLoginState>(
        listener: (context, state) async {
          // ==========================
          // 🔹 Loading → mostrar dialog
          // ==========================
          if (state.status == Status.loading) {
            CustomDialogs.loadingDialog(context);
          }

          // ==========================
          // Error → cerrar dialog y mostrar mensaje
          // ==========================
          if (state.status == Status.error) {
            context.pop();

            if (state.errorMessage == kWrongRoleErrorCode) {
              // Pantalla completa, no un diálogo: es imposible seguir
              // usando el login por error, y solo se sale con el botón.
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => const WrongRoleScreen(),
                ),
              );
            } else {
              final friendlyMessage = ErrorHandler.getErrorMessage(
                context,
                state.errorMessage ?? '',
              );
              CustomDialogs.errorDialog(
                context,
                friendlyMessage,
                onTap: () {
                  context.pop();
                },
              );
            }
          }

          // ==========================
          // 🔹 Success → cerrar dialog y redirigir
          // ==========================
          if (state.status == Status.success) {
            context.read<AuthCubit>().initAuth();
            context.pushReplacement(SplashScreen.path);
          }
        },
        child: const LoginView(),
      ),
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.clx;
    final t = context.clxText;
    final cubit = context.read<AuthLoginCubit>();

    void submit() {
      if (cubit.formKey.currentState?.validate() ?? false) {
        final email = cubit.emailController.text.trim();
        final pass = cubit.passwordController.text.trim();
        context.read<AuthLoginCubit>().login(email, pass);
      }
    }

    return Scaffold(
      backgroundColor: c.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pieza de marca compacta con el logotipo sobre placa.
            ClxBrandHeader(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    ClxSpace.s4,
                    ClxSpace.s2,
                    ClxSpace.s4,
                    ClxSpace.s8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 44,
                        child: Navigator.of(context).canPop()
                            ? ClxIconButton(
                                icon: LucideIcons.arrowLeft,
                                tooltip: MaterialLocalizations.of(
                                  context,
                                ).backButtonTooltip,
                                filled: true,
                                onPressed: () => context.pop(),
                              )
                            : null,
                      ),
                      Center(
                        child: ClxLogoPlate(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ClxSpace.s5,
                            vertical: ClxSpace.s4,
                          ),
                          child: SvgPicture.asset(
                            paths.nameLogoSvg,
                            height: 44,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  ClxSpace.s6,
                  ClxSpace.s8,
                  ClxSpace.s6,
                  ClxSpace.s6,
                ),
                child: Form(
                  key: cubit.formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.welcomeTitle, style: t.h1),
                        const SizedBox(height: ClxSpace.s2),
                        Text(s.loginSubtitle, style: t.bodyMuted),
                        const SizedBox(height: ClxSpace.s8),
                        ClxTextField(
                          key: const Key('login_email_field'),
                          label: s.email,
                          hint: s.emailHint,
                          icon: LucideIcons.mail,
                          controller: cubit.emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          validator: (text) =>
                              validators.email(context, text ?? ""),
                        ),
                        const SizedBox(height: ClxSpace.s5),
                        ClxTextField(
                          key: const Key('login_password_field'),
                          label: s.password,
                          icon: LucideIcons.lock,
                          isPassword: true,
                          controller: cubit.passwordController,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onSubmitted: (_) => submit(),
                          validator: (text) =>
                              validators.password(context, text ?? ""),
                        ),
                        const SizedBox(height: ClxSpace.s2),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ClxButton.ghost(
                            key: const Key('login_forgot_button'),
                            label: s.forgotPassword,
                            size: ClxButtonSize.sm,
                            onPressed: () =>
                                context.push(ForgotPasswordScreen.path),
                          ),
                        ),
                        const SizedBox(height: ClxSpace.s6),
                        ClxButton(
                          key: const Key('login_submit_button'),
                          label: s.login,
                          pill: true,
                          onPressed: submit,
                        ),
                        const SizedBox(height: ClxSpace.s6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                s.dontHaveAccount,
                                style: t.bodySm.copyWith(fontSize: 14),
                              ),
                            ),
                            ClxButton.ghost(
                              key: const Key('login_signup_button'),
                              label: s.signup,
                              size: ClxButtonSize.sm,
                              onPressed: () =>
                                  context.push(RegisterPersonalScreen.path),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
