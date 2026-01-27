import 'package:clinexa_derivant_app/core/constants/paths.dart';
import 'package:clinexa_derivant_app/core/services/validators.dart';
import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/cubit/auth_cubit.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/splash_screen.dart';
import 'package:clinexa_derivant_app/presentation/login/cubit/login_cubit.dart';
import 'package:clinexa_derivant_app/presentation/register/register_personal_screen.dart';
import 'package:clinexa_derivant_app/presentation/password_recovery/forgot_password/forgot_password_screen.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_button.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_dialogs.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  static const path = "/login";

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthLoginCubit(context.read()),
      child: BlocListener<AuthLoginCubit, AuthLoginState>(
        listener: (context, state) async {
          // ==========================
          // 🔹 Loading → mostrar dialog
          // ==========================
          if (state.status == Status.loading) {
            CustomDialogs.loadingDialog(context);
          }

          // ==========================
          // 🔹 Error → cerrar dialog y mostrar mensaje
          // ==========================
          if (state.status == Status.error) {
            context.pop();
            CustomDialogs.errorDialog(
              context,
              state.errorMessage ?? '--',
              onTap: () {
                context.pop();
              },
            );
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
    final cubit = context.read<AuthLoginCubit>();

    return Scaffold(
      appBar: AppBar(),
      backgroundColor: AppColors.neutral100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: context.read<AuthLoginCubit>().formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                //logo
                Center(child: Image.asset(paths.logoPng, height: 120)),

                const SizedBox(height: 24),

                // 🔹 Welcome Text
                Text(
                  s.welcomeTitle,
                  style: const TextStyle(
                    color: AppColors.primary40,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 24),

                // 🔹 Email field
                CustomTextField(
                  label: s.email,
                  hint: "example@example.com",
                  controller: cubit.emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (text) => validators.email(context, text ?? ""),
                ),

                const SizedBox(height: 20),

                // 🔹 Password field
                CustomTextField(
                  label: s.password,
                  hint: "***********",
                  isPassword: true,
                  controller: cubit.passwordController,
                  validator: (text) => validators.password(context, text ?? ""),
                ),

                const SizedBox(height: 6),

                // 🔹 Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      context.push(ForgotPasswordScreen.path);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                    ),
                    child: Text(
                      s.forgotPassword,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary40,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 🔹 Log In Button
                Center(
                  child: SizedBox(
                    width: 260,
                    child: CustomButton(
                      text: s.login,
                      height: 52,
                      onPressed: () {
                        final email = cubit.emailController.text.trim();
                        final pass = cubit.passwordController.text.trim();
                        if (email.isEmpty || pass.isEmpty) {
                          return;
                        } else {
                          context.read<AuthLoginCubit>().login(email, pass);
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Divider "or"
                Center(
                  child: Text(
                    s.or,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.neutral50,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 🔹 Sign Up Text
                Center(
                  child: GestureDetector(
                    onTap: () {
                      context.push(RegisterPersonalScreen.path);
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "${s.dontHaveAccount} ",
                        style: const TextStyle(
                          color: AppColors.neutral50,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: s.signup,
                            style: const TextStyle(
                              color: AppColors.primary40,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
