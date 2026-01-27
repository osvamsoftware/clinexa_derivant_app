import 'package:clinexa_derivant_app/domain/address_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/address/cubit/address_cubit.dart';
import 'package:clinexa_derivant_app/presentation/login/login_screen.dart';
import 'package:clinexa_derivant_app/presentation/register/cubit/register_cubit.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/address_search_box.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_button.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_dialogs.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';

class RegisterProfileScreen extends StatelessWidget {
  static const path = "/register-profile";

  const RegisterProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AddressCubit(context.read<AddressRepository>()),
        ),
      ],
      child: BlocListener<RegisterCubit, RegisterState>(
        listener: (context, state) async {
          final s = S.of(context);

          // =====================================================
          // 🔄 LOADING
          // =====================================================
          if (state.status == RegisterStatus.loading) {
            CustomDialogs.loadingDialog(context);
          }

          // =====================================================
          // ❌ ERROR
          // =====================================================
          if (state.status == RegisterStatus.error) {
            // cerrar loading
            context.pop(context);

            CustomDialogs.errorDialog(
              context,
              state.errorMessage ?? s.errorOccurred,
            );
          }

          // =====================================================
          // ✅ SUCCESS
          // =====================================================
          if (state.status == RegisterStatus.success) {
            context.pop(context); // cerrar loading

            CustomDialogs.successDialog(
              context: context,
              successMessage: s.register_successMessage,
              onPressed: () {
                // enviar al login
                context.pushReplacement(LoginScreen.path);
              },
            );
          }
        },
        child: const RegisterProfileView(),
      ),
    );
  }
}

class RegisterProfileView extends StatelessWidget {
  const RegisterProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterCubit>();
    final s = S.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(s.createAccount)),
      body: Form(
        key: cubit.formStep3Key,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              AddressSearchBox(controller: cubit.addressController),
              const SizedBox(height: 16),
              CustomTextField(
                minLines: 4,
                maxLines: 7,
                label: s.biography,
                controller: cubit.biographyController,
                hint: s.biographyHint,
                validator: (t) =>
                    (t == null || t.isEmpty) ? s.fieldRequired : null,
              ),
              const SizedBox(height: 32),
              BlocBuilder<AddressCubit, AddressState>(
                builder: (context, addressState) {
                  return CustomButton(
                    text: s.createAccount,
                    onPressed: () {
                      cubit.setAddressDetail(
                        detail: addressState.selectedAddress,
                      );
                      if (cubit.formStep3Key.currentState!.validate()) {
                        cubit.submit();
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
