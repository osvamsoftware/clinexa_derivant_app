import 'package:clinexa_derivant_app/core/services/validators.dart';
import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/domain/patient_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';

import 'package:clinexa_derivant_app/presentation/register_patient/cubit/patient_registration_cubit.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_dialogs.dart';
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
          BlocListener<PatientRegistrationCubit, PatientRegistrationState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == PatientRegistrationStatus.loading) {
                CustomDialogs.loadingDialog(context);
              } else if (state.status ==
                  PatientRegistrationStatus.formCompleted) {
                // Formulario completado, navegar a pantalla de firma
                final cubit = context.read<PatientRegistrationCubit>();
                context.push('/patient-signature', extra: cubit);
              } else if (state.status == PatientRegistrationStatus.success) {
                context.pop(); // Close loading
                CustomDialogs.successDialog(
                  context: context,
                  successMessage: S.of(context).patientCreatedSuccessfully,
                  onPressed: () {
                    context.pop(); // Close success dialog
                    context.goNamed(PatientsScreen.path);
                  },
                );
              } else if (state.status == PatientRegistrationStatus.error) {
                context.pop(); // Close loading
                CustomDialogs.errorDialog(
                  context,
                  state.errorMessage ?? S.of(context).errorOccurred,
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
    const gap = SizedBox(height: ClxSpace.s5);

    return Scaffold(
      appBar: ClxAppBar(title: s.registerPatient),
      bottomNavigationBar: ClxBottomBar(
        child: BlocBuilder<PatientRegistrationCubit, PatientRegistrationState>(
          builder: (context, state) {
            return ClxButton(
              key: const Key('patient_registration_submit'),
              label: s.continueToSignature,
              trailingIcon: LucideIcons.arrowRight,
              loading: state.status == PatientRegistrationStatus.loading,
              onPressed: () {
                cubit.completeForm();
              },
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(ClxSpace.s4, ClxSpace.s5, ClxSpace.s4, ClxSpace.s8),
        child: Form(
          key: cubit.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClxStepper(current: 1, total: 3, label: s.referralStepPatient),
              const SizedBox(height: ClxSpace.s5),
              Text(s.patientRegistrationSubtitle, style: context.clxText.bodyMuted),
              const SizedBox(height: ClxSpace.s8),

              // =========================
              // DATOS PERSONALES
              // =========================
              _SectionTitle(title: s.personalInfo, icon: LucideIcons.user),
              ClxTextField(
                label: s.register_firstName,
                controller: cubit.firstNameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (val) => validators.text(context, val ?? ""),
              ),
              gap,
              ClxTextField(
                label: s.register_lastName,
                controller: cubit.lastNameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (val) => validators.text(context, val ?? ""),
              ),
              gap,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClxTextField(
                      label: s.dni,
                      mono: true,
                      controller: cubit.dniController,
                      keyboardType: TextInputType.number,
                      validator: (val) => validators.dni(context, val ?? ""),
                    ),
                  ),
                  const SizedBox(width: ClxSpace.s3),
                  Expanded(
                    child: ClxTextField(
                      label: s.birthDate,
                      hint: s.datePlaceholder,
                      mono: true,
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
                      suffix: Icon(LucideIcons.calendar, size: 18, color: context.clx.inkSubtle),
                    ),
                  ),
                ],
              ),
              gap,
              ClxDropdown<String>(
                label: s.gender,
                hint: s.selectOption,
                value: cubit.gender,
                items: const ["Male", "Female", "Other"],
                itemLabel: (v) => switch (v) {
                  "Male" => s.male,
                  "Female" => s.female,
                  _ => s.other,
                },
                onChanged: cubit.setGender,
                validator: (val) => val == null ? s.fieldRequired : null,
              ),

              const SizedBox(height: ClxSpace.s8),

              // =========================
              // CONTACTO
              // =========================
              _SectionTitle(title: s.contactInfo, icon: LucideIcons.phone),
              ClxTextField(
                label: s.phone,
                icon: LucideIcons.phone,
                controller: cubit.phoneController,
                keyboardType: TextInputType.phone,
                validator: (val) => validators.phone(context, val ?? ""),
              ),
              gap,
              ClxTextField(
                label: s.phone2,
                icon: LucideIcons.phone,
                controller: cubit.phone2Controller,
                keyboardType: TextInputType.phone,
                validator: (val) => validators.phone(context, val ?? ""),
              ),
              gap,
              ClxTextField(
                label: s.register_email,
                hint: s.emailHint,
                icon: LucideIcons.mail,
                controller: cubit.emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (val) => validators.email(context, val ?? ""),
              ),
              gap,
              AddressSearchBox(
                label: s.address,
                controller: cubit.addressController,
                onClear: cubit.clearAddress,
              ),
              gap,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClxTextField(
                      label: s.city,
                      hint: s.autoFilled,
                      controller: cubit.cityController,
                      readOnly: true, // Viene de la dirección elegida
                      validator: (val) => validators.text(context, val ?? ""),
                    ),
                  ),
                  const SizedBox(width: ClxSpace.s3),
                  Expanded(
                    child: ClxTextField(
                      label: s.country,
                      hint: s.autoFilled,
                      controller: cubit.countryController,
                      readOnly: true,
                      validator: (val) => validators.text(context, val ?? ""),
                    ),
                  ),
                ],
              ),
              gap,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClxTextField(
                      label: s.provinceState,
                      hint: s.autoFilled,
                      controller: cubit.stateController,
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: ClxSpace.s3),
                  Expanded(
                    child: ClxTextField(
                      label: s.postalCode,
                      hint: s.autoFilled,
                      mono: true,
                      controller: cubit.postalCodeController,
                      readOnly: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: ClxSpace.s8),

              // =========================
              // INFORMACIÓN MÉDICA
              // =========================
              _SectionTitle(title: s.medicalInfo, icon: LucideIcons.stethoscope),
              ClxTextField(
                label: s.notes,
                hint: s.notesHint,
                optional: true,
                controller: cubit.notesController,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    return Padding(
      padding: const EdgeInsets.only(bottom: ClxSpace.s4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: c.brandBlue),
          const SizedBox(width: ClxSpace.s2),
          Text(title, style: context.clxText.h2),
        ],
      ),
    );
  }
}
