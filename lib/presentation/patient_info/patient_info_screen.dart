import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/data/models/patient_model.dart';
import 'package:clinexa_derivant_app/domain/patient_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/patient_info/cubit/patient_info_cubit.dart';
import 'package:clinexa_derivant_app/presentation/patient_info/cubit/patient_info_state.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_button.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PatientInfoScreen extends StatelessWidget {
  static const path = "/patient-info";
  final PatientModel patient;

  const PatientInfoScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientInfoCubit(
        patientRepository: context.read<PatientRepository>(),
        initialPatient: patient,
      ),
      child: const PatientInfoView(),
    );
  }
}

class PatientInfoView extends StatelessWidget {
  const PatientInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.patientDetails)),
      body: BlocConsumer<PatientInfoCubit, PatientInfoState>(
        listener: (context, state) {
          if (state.status == PatientInfoStatus.failure) {
            CustomDialogs.errorDialog(
              context,
              state.errorMessage ?? s.errorOccurred,
            );
          } else if (state.status == PatientInfoStatus.success &&
              state.successMessage != null) {
            CustomDialogs.successDialog(
              context: context,
              successMessage: state.successMessage!,
              onPressed: () {
                // Retornar true para indicar que hubo cambios

                context.pop(true);
                context.pop(true);
              },
            );
          }
        },
        builder: (context, state) {
          if (state.patient == null) {
            return Center(child: Text(s.noPatientsFound));
          }

          final patient = state.patient!;
          final theme = Theme.of(context);
          final isActive = patient.status.toLowerCase() == 'active';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estado del paciente
                _buildStatusCard(patient, theme, s),

                const SizedBox(height: 24),

                // Información personal
                Text(
                  s.personalInfo,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                _buildInfoRow(s.register_firstName, patient.firstName, theme),
                _buildInfoRow(s.register_lastName, patient.lastName, theme),
                _buildInfoRow(s.dni, patient.dni, theme),
                _buildInfoRow(s.gender, patient.gender, theme),
                _buildInfoRow(
                  s.birthDate,
                  patient.birthDate?.toString().split(' ').first,
                  theme,
                ),

                const SizedBox(height: 24),

                // Información de contacto
                Text(
                  s.contactInfo,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                _buildInfoRow(s.phone, patient.phone, theme),
                _buildInfoRow(s.email, patient.email, theme),
                _buildInfoRow(
                  s.address,
                  patient.address?.formattedAddress ?? patient.address?.city,
                  theme,
                ),
                _buildInfoRow(s.city, patient.address?.city, theme),

                const SizedBox(height: 24),

                // Información médica
                Text(
                  s.medicalInfo,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                _buildInfoRow(s.protocol, patient.protocol?.name, theme),
                _buildInfoRow(
                  s.specialty,
                  patient.specialties.isNotEmpty
                      ? '${patient.specialties.length} especialidades'
                      : null,
                  theme,
                ),
                _buildInfoRow(
                  s.homePathology,
                  patient.pathologies.isNotEmpty
                      ? '${patient.pathologies.length} patologías'
                      : null,
                  theme,
                ),
                _buildInfoRow(s.notes, patient.notes, theme),

                const SizedBox(height: 32),

                // Botón para cambiar estado
                if (isActive)
                  CustomButton(
                    text: s.markAsInactive,
                    onPressed: state.status == PatientInfoStatus.loading
                        ? null
                        : () {
                            _showConfirmationDialog(
                              context,
                              s,
                              isMarkingAsActive: false,
                            );
                          },
                  )
                else
                  CustomButton(
                    text: s.markAsActive,
                    onPressed: state.status == PatientInfoStatus.loading
                        ? null
                        : () {
                            _showConfirmationDialog(
                              context,
                              s,
                              isMarkingAsActive: true,
                            );
                          },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(PatientModel patient, ThemeData theme, S s) {
    // Determinar el status basado en el order
    final orderStatus = patient.order?.status.name;
    final Color statusColor;
    final String statusText;
    final IconData statusIcon;

    if (orderStatus != null) {
      switch (orderStatus) {
        case 'assigned':
          statusColor = Colors.amber;
          statusText = s.orderStatusAssigned;
          statusIcon = Icons.pending;
          break;
        case 'accepted':
          statusColor = Colors.green;
          statusText = s.orderStatusAccepted;
          statusIcon = Icons.check_circle;
          break;
        case 'rejected':
          statusColor = Colors.red;
          statusText = s.orderStatusRejected;
          statusIcon = Icons.cancel;
          break;
        default:
          statusColor = Colors.grey;
          statusText = orderStatus;
          statusIcon = Icons.info;
      }
    } else {
      // Sin order vinculado - verificar si el paciente está activo o inactivo
      final isActive = patient.status.toLowerCase() == 'active';

      if (isActive) {
        // Paciente activo sin order - azul índigo
        statusColor = Colors.indigo;
        statusText = s.statusActive;
        statusIcon = Icons.check_circle_outline;
      } else {
        // Paciente inactivo sin order - gris
        statusColor = Colors.grey;
        statusText = s.statusInactive;
        statusIcon = Icons.info_outline;
      }
    }

    return Card(
      elevation: 0,
      color: statusColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.status,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral40,
                    ),
                  ),
                  Text(
                    statusText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value ?? "-", style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    S s, {
    required bool isMarkingAsActive,
  }) {
    final confirmMessage = isMarkingAsActive
        ? s.confirmMarkAsActive
        : s.confirmMarkAsInactive;
    final newStatus = isMarkingAsActive ? 'active' : 'inactive';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.confirmAction),
        content: Text(confirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<PatientInfoCubit>().updatePatientStatus(newStatus);
            },
            child: Text(s.confirm),
          ),
        ],
      ),
    );
  }
}
