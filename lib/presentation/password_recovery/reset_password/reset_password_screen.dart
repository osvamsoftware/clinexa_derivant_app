import 'package:clinexa_derivant_app/core/services/validators.dart';
import 'package:clinexa_derivant_app/domain/auth_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/login/login_screen.dart';
import 'package:clinexa_derivant_app/presentation/password_recovery/reset_password/cubit/reset_password_cubit.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_button.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_dialogs.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordScreen extends StatelessWidget {
  static const path = "/reset-password";
  final String oobCode;

  const ResetPasswordScreen({super.key, required this.oobCode});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ResetPasswordCubit(context.read<AuthRepository>(), oobCode: oobCode),
      child: const ResetPasswordView(),
    );
  }
}

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final cubit = context.read<ResetPasswordCubit>();

    return BlocListener<ResetPasswordCubit, ResetPasswordState>(
      listener: (context, state) {
        if (state.status == ResetPasswordStatus.loading) {
          CustomDialogs.loadingDialog(context);
        } else if (state.status == ResetPasswordStatus.success) {
          context.pop(); // Close loading
          // Success dialog
          CustomDialogs.successDialog(
            context: context,
            successMessage: s.passwordResetSuccess,
            onPressed: () {
              context.pop(); // Close dialog
              // Navigate to login clearing stack
              context.goNamed(LoginScreen.path);
            },
          );
        } else if (state.status == ResetPasswordStatus.error) {
          context.pop(); // Close loading
          CustomDialogs.errorDialog(
            context,
            state.errorMessage ?? s.errorOccurred,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(s.resetPassword)),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: cubit.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  label: s.newPassword,
                  controller: cubit.newPasswordController,
                  validator: (val) => validators.password(context, val ?? ""),
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: s.confirmNewPassword,
                  controller: cubit.confirmPasswordController,
                  validator: (val) {
                    if (val == null || val.isEmpty) return s.fieldRequired;
                    if (val != cubit.newPasswordController.text) {
                      return s.passwordsDoNotMatch;
                    }
                    return null;
                  },
                  isPassword: true,
                ),
                const SizedBox(height: 32),
                CustomButton(text: s.save, onPressed: cubit.submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
