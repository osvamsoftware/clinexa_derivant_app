import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/presentation/notifications/screens/home_screen.dart';
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
      return Scaffold(
        body: ClxEmptyState(
          icon: LucideIcons.lock,
          title: s.userNotAuthenticated,
          tone: ClxTone.danger,
        ),
      );
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
    final t = context.clxText;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<PatientsCubit, PatientsState>(
          listener: (context, state) {
            if (state.status == PatientsStatus.failure) {
              CustomDialogs.errorDialog(
                context,
                state.errorMessage ?? s.errorOccurred,
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<PatientsCubit>();
            final isLoading =
                (state.status == PatientsStatus.loading ||
                    state.status == PatientsStatus.initial) &&
                state.patients.isEmpty;
            final hasFilters =
                (state.searchQuery?.isNotEmpty ?? false) ||
                state.selectedSpecialtyId != null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    ClxSpace.s4,
                    ClxSpace.s4,
                    ClxSpace.s4,
                    ClxSpace.s4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(s.myPatients, style: t.h1),
                      const SizedBox(height: ClxSpace.s1),
                      Text(
                        isLoading
                            ? s.loading
                            : hasFilters
                            ? s.resultsCount(state.patients.length)
                            : s.patientsCount(state.patients.length),
                        style: t.bodySm,
                      ),
                      const SizedBox(height: ClxSpace.s4),
                      ClxSearchField(
                        key: const Key('patients_search_field'),
                        hint: s.searchPatientsHint,
                        onChanged: cubit.setSearchQuery,
                      ),
                      const SizedBox(height: ClxSpace.s3),
                      ClxDropdown<String?>(
                        icon: LucideIcons.stethoscope,
                        value: state.selectedSpecialtyId,
                        items: [null, ...state.specialties.map((e) => e.id)],
                        itemLabel: (id) => id == null
                            ? s.allSpecialties
                            : state.specialties
                                  .firstWhere((e) => e.id == id)
                                  .name,
                        onChanged: cubit.setSpecialtyId,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (isLoading) {
                        return const ClxSkeletonList(
                          count: 5,
                          padding: EdgeInsets.fromLTRB(
                            ClxSpace.s4,
                            0,
                            ClxSpace.s4,
                            ClxSpace.s4,
                          ),
                        );
                      }
                      if (state.patients.isEmpty) {
                        return SingleChildScrollView(
                          child: hasFilters
                              ? ClxEmptyState(
                                  icon: LucideIcons.searchX,
                                  title: s.noResults,
                                  message: s.noPatientsResultsHint,
                                )
                              : ClxEmptyState(
                                  icon: LucideIcons.userPlus,
                                  title: s.noPatientsFound,
                                  message: s.noPatientsPromotion,
                                  actionLabel: s.referPatientAction,
                                  onAction: () => context.go(HomeScreen.path),
                                ),
                        );
                      }
                      return RefreshIndicator(
                        color: context.clx.brandBlue,
                        onRefresh: cubit.loadPatients,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            ClxSpace.s4,
                            0,
                            ClxSpace.s4,
                            ClxSpace.s6,
                          ),
                          itemCount: state.patients.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: ClxSpace.s3),
                          itemBuilder: (context, index) {
                            final patient = state.patients[index];

                            // Access address formatted string from AddressModel
                            final addressStr =
                                patient.address?.formattedAddress ??
                                patient.address?.city ??
                                s.noAddress;

                            return PatientResultCard(
                              key: ValueKey('patient_card_$index'),
                              name: patient.fullName,
                              protocolName: patient.protocol?.name,
                              address: addressStr,
                              pathology: patient.pathologies.isNotEmpty
                                  ? "${patient.pathologies.length} pathologies"
                                  : "-",
                              notes: patient.notes ?? '--',
                              status: patient.status.toUpperCase(),
                              hasActiveOrder: patient.order != null,
                              orderStatus:
                                  patient.order?.status.name ??
                                  patient.status.toUpperCase(),
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
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
