import 'package:clinexa_derivant_app/core/services/validators.dart';
import 'package:clinexa_derivant_app/domain/auth_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/password_recovery/forgot_password/cubit/forgot_password_cubit.dart';
import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_dialogs.dart';
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
            title: s.recoveryEmailSentTitle,
            successMessage: s.recoveryEmailSent,
            buttonLabel: s.backToLogin,
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
        appBar: const ClxAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              ClxSpace.s6,
              ClxSpace.s4,
              ClxSpace.s6,
              ClxSpace.s6,
            ),
            child: Form(
              key: cubit.formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClxPageHeader(
                    title: s.forgotPasswordTitle,
                    subtitle: s.forgotPasswordDescription,
                  ),
                  const SizedBox(height: ClxSpace.s8),
                  ClxTextField(
                    key: const Key('forgot_email_field'),
                    label: s.email,
                    hint: s.emailHint,
                    icon: LucideIcons.mail,
                    controller: cubit.emailController,
                    validator: (val) => validators.email(context, val ?? ""),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => cubit.submit(),
                  ),
                  const SizedBox(height: ClxSpace.s6),
                  ClxButton(
                    label: s.sendInstructions,
                    icon: LucideIcons.send,
                    onPressed: cubit.submit,
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
