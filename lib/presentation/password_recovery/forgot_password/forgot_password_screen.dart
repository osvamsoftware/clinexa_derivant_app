import 'package:clinexa_derivant_app/core/services/validators.dart';
import 'package:clinexa_derivant_app/domain/auth_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/password_recovery/forgot_password/cubit/forgot_password_cubit.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_button.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_dialogs.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatelessWidget {
  static const path = "/forgot-password";

  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordCubit(context.read<AuthRepository>()),
      child: const ForgotPasswordView(),
    );
  }
}

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final cubit = context.read<ForgotPasswordCubit>();

    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state.status == ForgotPasswordStatus.loading) {
          CustomDialogs.loadingDialog(context);
        } else if (state.status == ForgotPasswordStatus.success) {
          context.pop(); // Close loading
          // Success dialog
          CustomDialogs.successDialog(
            context: context,
            successMessage: s.recoveryEmailSent, // Needs translation
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Go back to login
            },
          );
        } else if (state.status == ForgotPasswordStatus.error) {
          context.pop(); // Close loading
          CustomDialogs.errorDialog(
            context,
            state.errorMessage ?? s.errorOccurred,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.forgotPassword), // Needs translation
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: cubit.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  s.forgotPasswordDescription, // Needs translation
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: s.email,
                  controller: cubit.emailController,
                  validator: (val) => validators.email(context, val ?? ""),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: s.sendInstructions, // Needs translation
                  onPressed: cubit.submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
