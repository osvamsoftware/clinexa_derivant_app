import 'package:clinexa_derivant_app/core/services/validators.dart';
import 'package:clinexa_derivant_app/domain/auth_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/register/cubit/register_cubit.dart';
import 'package:clinexa_derivant_app/presentation/register/register_profesional_screen.dart';
import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RegisterPersonalScreen extends StatelessWidget {
  static const path = "/register-personal";

  const RegisterPersonalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(context.read<AuthRepository>()),
      child: const RegisterPersonalView(),
    );
  }
}

class RegisterPersonalView extends StatelessWidget {
  const RegisterPersonalView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterCubit>();
    final s = S.of(context);
    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state.status == RegisterStatus.error &&
            state.errorMessage != null) {
          ClxDialog.alert(
            context,
            title: s.errorOccurred,
            message: state.errorMessage!,
            buttonLabel: s.ok,
            tone: ClxTone.danger,
            icon: LucideIcons.circleAlert,
          );
        }
      },
      child: BlocBuilder<RegisterCubit, RegisterState>(
        builder: (context, state) {
          return Scaffold(
            appBar: const ClxAppBar(),
            body: Form(
              key: cubit.formStep1Key,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  ClxSpace.s6,
                  ClxSpace.s4,
                  ClxSpace.s6,
                  ClxSpace.s8,
                ),
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClxStepper(
                        current: 1,
                        total: 3,
                        label: s.register_step1_title,
                      ),
                      const SizedBox(height: ClxSpace.s6),
                      ClxPageHeader(
                        title: s.createAccount,
                        subtitle: s.register_header,
                      ),
                      const SizedBox(height: ClxSpace.s8),
                      ClxTextField(
                        key: const Key('register_first_name_field'),
                        label: s.register_firstName,
                        controller: cubit.firstNameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.givenName],
                        validator: (t) =>
                            (t == null || t.isEmpty) ? s.fieldRequired : null,
                      ),
                      const SizedBox(height: ClxSpace.s5),
                      ClxTextField(
                        label: s.register_lastName,
                        controller: cubit.lastNameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.familyName],
                        validator: (t) =>
                            (t == null || t.isEmpty) ? s.fieldRequired : null,
                      ),
                      const SizedBox(height: ClxSpace.s5),
                      ClxTextField(
                        label: s.email,
                        hint: s.emailHint,
                        icon: LucideIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        controller: cubit.emailController,
                        validator: (t) => validators.email(context, t ?? ""),
                      ),
                      const SizedBox(height: ClxSpace.s5),
                      ClxTextField(
                        label: s.password,
                        helper: s.passwordHelper,
                        icon: LucideIcons.lock,
                        isPassword: true,
                        autofillHints: const [AutofillHints.newPassword],
                        controller: cubit.passController,
                        validator: (t) => validators.password(context, t ?? ""),
                      ),
                      const SizedBox(height: ClxSpace.s8),
                      ClxButton(
                        label: s.register_next,
                        trailingIcon: LucideIcons.arrowRight,
                        loading: state.status == RegisterStatus.loading,
                        onPressed: () async {
                          if (cubit.formStep1Key.currentState!.validate()) {
                            // Validar email (async)
                            final success = await cubit.validateStep1();
                            if (success && context.mounted) {
                              context.push(
                                RegisterProfessionalScreen.path,
                                extra: cubit,
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
