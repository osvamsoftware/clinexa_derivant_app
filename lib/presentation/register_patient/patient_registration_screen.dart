import 'package:clinexa_derivant_app/core/services/validators.dart';
import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/domain/patient_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/cubit/auth_cubit.dart';
import 'package:clinexa_derivant_app/presentation/register_patient/cubit/patient_registration_cubit.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_button.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_dialogs.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinexa_derivant_app/domain/address_repository.dart';
import 'package:clinexa_derivant_app/presentation/address/cubit/address_cubit.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/address_search_box.dart';
import 'package:clinexa_derivant_app/presentation/patients/patients_screen.dart';
import 'package:go_router/go_router.dart';

class PatientRegistrationScreen extends StatelessWidget {
  static const path = "/register-patient";

  final String? protocolId;

  const PatientRegistrationScreen({super.key, this.protocolId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PatientRegistrationCubit(
            context.read<PatientRepository>(),
            protocolId: protocolId,
          ),
        ),
        BlocProvider(
          create: (context) => AddressCubit(context.read<AddressRepository>()),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<PatientRegistrationCubit, PatientRegistrationState>(
            listener: (context, state) {
              if (state.status == PatientRegistrationStatus.loading) {
                CustomDialogs.loadingDialog(context);
              }
              if (state.status == PatientRegistrationStatus.success) {
                context.pop(); // Close loading
                CustomDialogs.successDialog(
                  context: context,
                  successMessage: S.of(context).register_successMessage,
                  onPressed: () {
                    context.pop(); // Close dialog
                    context.goNamed(PatientsScreen.path); // Go to My Patients
                  },
                );
              }
              if (state.status == PatientRegistrationStatus.error) {
                context.pop(); // Close loading
                CustomDialogs.errorDialog(
                  context,
                  state.errorMessage ?? S.of(context).errorOccurred,
                );
              }
            },
          ),
          BlocListener<AddressCubit, AddressState>(
            listener: (context, state) {
              if (state.status == Status.success &&
                  state.selectedAddress != null) {
                context.read<PatientRegistrationCubit>().setAddress(
                  state.selectedAddress!,
                );
              }
            },
          ),
        ],
        child: const PatientRegistrationView(),
      ),
    );
  }
}

class PatientRegistrationView extends StatelessWidget {
  const PatientRegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final cubit = context.read<PatientRegistrationCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          s.registerPatient,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: cubit.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // PERSONAL INFO
              // =========================
              _SectionTitle(title: s.personalInfo),
              const SizedBox(height: 16),

              CustomTextField(
                label: s.register_firstName,
                controller: cubit.firstNameController,
                validator: (val) => validators.text(context, val ?? ""),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: s.register_lastName,
                controller: cubit.lastNameController,
                validator: (val) => validators.text(context, val ?? ""),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: s.dni,
                      controller: cubit.dniController,
                      keyboardType: TextInputType.number,
                      validator: (val) => validators.text(context, val ?? ""),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: s.birthDate,
                      controller: cubit.birthDateController,
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2000),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          cubit.setBirthDate(date);
                        }
                      },
                      validator: (val) => validators.text(context, val ?? ""),
                      icon: Icons.calendar_today,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Gender Dropdown
              Text(
                s.gender,
                style: const TextStyle(
                  color: AppColors.neutral10,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.primary95,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: [
                  DropdownMenuItem(value: "Male", child: Text(s.male)),
                  DropdownMenuItem(value: "Female", child: Text(s.female)),
                  DropdownMenuItem(value: "Other", child: Text(s.other)),
                ],
                onChanged: cubit.setGender,
                validator: (val) => val == null ? s.fieldRequired : null,
              ),

              const SizedBox(height: 32),

              // =========================
              // CONTACT INFO
              // =========================
              _SectionTitle(title: s.contactInfo),
              const SizedBox(height: 16),

              CustomTextField(
                label: s.phone,
                controller: cubit.phoneController,
                keyboardType: TextInputType.phone,
                validator: (val) => validators.phone(context, val ?? ""),
              ),

              CustomTextField(
                label: s.phone2,
                controller: cubit.phone2Controller,
                keyboardType: TextInputType.phone,
                validator: (val) => validators.phone(context, val ?? ""),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: s.register_email,
                controller: cubit.emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (val) => validators.email(context, val ?? ""),
              ),
              const SizedBox(height: 16),

              // Address Search - Replaced CustomTextField
              AddressSearchBox(controller: cubit.addressController),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: s.city,
                      controller: cubit.cityController,
                      readOnly: true, // Make read-only as it comes from API
                      validator: (val) => validators.text(context, val ?? ""),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: s.country,
                      controller: cubit.countryController,
                      readOnly: true, // Make read-only
                      validator: (val) => validators.text(context, val ?? ""),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // State and Zip Code (Automatically populated)
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: s.provinceState,
                      controller: cubit.stateController,
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: s.postalCode,
                      controller: cubit.postalCodeController,
                      readOnly: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // =========================
              // MEDICAL INFO (Notes)
              // =========================
              _SectionTitle(title: s.medicalInfo),
              const SizedBox(height: 16),

              CustomTextField(
                label: s.notes,
                controller: cubit.notesController,
                minLines: 3,
                maxLines: 5,
              ),

              const SizedBox(height: 48),

              // Submit Button
              CustomButton(
                text: s.save,
                onPressed: () {
                  cubit.register(
                    createdBy: context.read<AuthCubit>().state.user?.id,
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary40,
          ),
        ),
        const Divider(),
      ],
    );
  }
}
