import 'package:clinexa_derivant_app/core/services/validators.dart';
import 'package:clinexa_derivant_app/domain/auth_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/register/cubit/register_cubit.dart';
import 'package:clinexa_derivant_app/presentation/register/register_profesional_screen.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_button.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_textfield.dart';
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
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(s.errorOccurred),
              content: Text(state.errorMessage!),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(s.ok),
                ),
              ],
            ),
          );
        }
      },
      child: BlocBuilder<RegisterCubit, RegisterState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text(s.createAccount)),
            body: Form(
              key: cubit.formStep1Key,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    //register header
                    Text(
                      s.register_header,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomTextField(
                      label: s.register_firstName,
                      controller: cubit.firstNameController,
                      validator: (t) =>
                          (t == null || t.isEmpty) ? s.fieldRequired : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: s.register_lastName,
                      controller: cubit.lastNameController,
                      validator: (t) =>
                          (t == null || t.isEmpty) ? s.fieldRequired : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: s.email,
                      controller: cubit.emailController,
                      validator: (t) => validators.email(context, t ?? ""),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: s.password,
                      isPassword: true,
                      controller: cubit.passController,
                      validator: (t) => validators.password(context, t ?? ""),
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: s.register_next,
                      isLoading: state.status == RegisterStatus.loading,
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
          );
        },
      ),
    );
  }
}
