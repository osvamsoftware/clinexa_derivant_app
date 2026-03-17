import 'dart:typed_data';

import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/domain/patient_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/cubit/auth_cubit.dart';
import 'package:clinexa_derivant_app/presentation/protocol/protocol_selection_screen.dart'; // Import ProtocolSelectionScreen

import 'package:clinexa_derivant_app/presentation/shared/widgets/home_header.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/patient_result_card.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:clinexa_derivant_app/core/services/notification_service.dart';
import 'package:clinexa_derivant_app/presentation/home/cubit/home_cubit.dart';
import 'package:clinexa_derivant_app/presentation/home/cubit/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  static const path = "/home";

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (context) {
        final userId = context.read<AuthCubit>().state.user?.id;
        final notificationService = context.read<NotificationService>();

        return HomeCubit(notificationService, context.read<PatientRepository>())
          ..init(userId ?? '');
      },
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final user = context.select((AuthCubit cubit) => cubit.state.user);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER (Full width)
            HomeHeader(name: user?.firstName ?? "User"),

            const SizedBox(height: 20),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE & SEARCH
                    // Combined row for title and maybe search later, for now just title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.patientList,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        // Register Patient Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: Tooltip(
                            message: s.registerPatient,
                            child: FilledButton(
                              onPressed: () async {
                                context.pushNamed(ProtocolSelectionScreen.path);
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.secondary40,
                                padding: const EdgeInsets.all(12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ), // Slightly rounded
                                ),
                                minimumSize: const Size(0, 0), // Compact
                              ),
                              child: SizedBox(
                                width: 80,
                                child: const Icon(Icons.person_add, size: 20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    // REAL RESULTS BOX
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                        ),
                        child: BlocBuilder<HomeCubit, HomeState>(
                          builder: (context, state) {
                            if (state.status == HomeStatus.loading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (state.status == HomeStatus.failure) {
                              return Center(
                                child: Text(
                                  state.errorMessage ?? s.errorOccurred,
                                ),
                              );
                            }
                            if (state.patients.isEmpty) {
                              return Center(child: Text(s.noPatientsFound));
                            }

                            return ListView.separated(
                              itemCount: state.patients.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final patient = state.patients[index];
                                // Asumimos que el protocolo tiene un nombre o usamos placeholder
                                final protocolName =
                                    patient.protocol?.name ??
                                    patient.protocolId ??
                                    "Sin protocolo";
                                // Asumimos que la patología principal está en la lista o usamos placeholder
                                final pathology = patient.pathologies.isNotEmpty
                                    ? patient.pathologies.first
                                    : "--";

                                return PatientResultCard(
                                  onTap: () {
                                    if (patient.order != null) {
                                      context.push(
                                        '/patient-details',
                                        extra: patient,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(s.noOrderLinked),
                                        ),
                                      );
                                    }
                                  },
                                  name: patient.fullName,
                                  protocolName: protocolName,
                                  address:
                                      patient.address?.formattedAddress ??
                                      s.noAddress,
                                  pathology: pathology,
                                  status: patient.status,
                                  notes: patient.notes ?? "--",
                                  hasActiveOrder: patient.order != null,
                                  orderStatus: patient.order?.status.name,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
