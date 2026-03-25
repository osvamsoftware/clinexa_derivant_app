import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/domain/patient_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/cubit/auth_cubit.dart';
import 'package:clinexa_derivant_app/presentation/patients/cubit/patients_cubit.dart';
import 'package:clinexa_derivant_app/presentation/patients/cubit/patients_state.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_dialogs.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/patient_result_card.dart';
import 'package:clinexa_derivant_app/presentation/specialty/specialty_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PatientsScreen extends StatelessWidget {
  static const path = "/patients-list";

  const PatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().state.user;
    final s = S.of(context);

    if (user == null) {
      return Scaffold(body: Center(child: Text(s.userNotAuthenticated)));
    }

    return BlocProvider(
      create: (context) =>
          PatientsCubit(
              patientRepository: context.read<PatientRepository>(),
              specialtyRepository: context.read<SpecialtyRepository>(),
              userId: user.id ?? "",
            )
            ..loadPatients()
            ..loadSpecialties(allowedIds: user.specialties),
      child: const PatientsView(),
    );
  }
}

class PatientsView extends StatelessWidget {
  const PatientsView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.myPatients)),
      body: BlocConsumer<PatientsCubit, PatientsState>(
        listener: (context, state) {
          if (state.status == PatientsStatus.failure) {
            CustomDialogs.errorDialog(
              context,
              state.errorMessage ?? s.errorOccurred,
            );
          }
        },
        builder: (context, state) {
          if (state.status == PatientsStatus.loading &&
              state.patients.isEmpty) {
            // Only show full loading indicator if no patients are loaded yet and loading
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      decoration: InputDecoration(
                        labelText: s.search, // Or "Search by name"
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        context.read<PatientsCubit>().setSearchQuery(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    // Specialty Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: s.specialty, // Or "Select Specialty"
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      initialValue: state.selectedSpecialtyId,
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(s.all), // Or "All Specialties"
                        ),
                        ...state.specialties.map((specialty) {
                          return DropdownMenuItem<String>(
                            value: specialty.id,
                            child: Text(specialty.name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        context.read<PatientsCubit>().setSpecialtyId(value);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.patients.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_add_outlined,
                                size: 64,
                                color: AppColors.neutral80,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                s.noPatientsFound,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.neutral40,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                s.noPatientsPromotion,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.neutral50,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 8,
                          bottom:
                              100, // Espacio para no ser tapado por el bottombar/FAB
                        ),
                        itemCount: state.patients.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final patient = state.patients[index];

                          // Access address formatted string from AddressModel
                          final addressStr =
                              patient.address?.formattedAddress ??
                              patient.address?.city ??
                              s.noAddress;

                          return PatientResultCard(
                            name: patient.fullName,
                            protocolName: patient.protocol?.name,
                            address: addressStr,
                            pathology: patient.pathologies.isNotEmpty
                                ? "${patient.pathologies.length} pathologies"
                                : "-",
                            notes: patient.notes ?? '--',
                            status: patient.status.toUpperCase(),
                            hasActiveOrder: patient.order != null,
                            orderStatus: patient.order?.status.name,
                            onTap: () async {
                              await context.push(
                                '/patient-details',
                                extra: patient,
                              );

                              // Si hubo cambios, recargar la lista
                              if (context.mounted) {
                                context.read<PatientsCubit>().loadPatients();
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
