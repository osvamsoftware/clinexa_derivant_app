import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/data/models/order_model.dart';
import 'package:clinexa_derivant_app/data/models/patient_model.dart';
import 'package:clinexa_derivant_app/domain/order_repository.dart';
import 'package:clinexa_derivant_app/domain/patient_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/patient_info/cubit/patient_info_cubit.dart';
import 'package:clinexa_derivant_app/presentation/patient_info/cubit/patient_info_state.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_button.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PatientDetailsScreen extends StatelessWidget {
  static const path = "/patient-details";
  final PatientModel patient;

  const PatientDetailsScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientInfoCubit(
        patientRepository: context.read<PatientRepository>(),
        orderRepository: context.read<OrderRepository>(),
        initialPatient: patient,
      ),
      child: PatientDetailsView(initialPatient: patient),
    );
  }
}

class PatientDetailsView extends StatelessWidget {
  final PatientModel initialPatient;

  const PatientDetailsView({super.key, required this.initialPatient});

  bool _isFieldHidden(String? value) {
    if (value == null) return true;
    if (value == "***") return true;
    return false;
  }

  bool _isLastNamePartial(String? lastName) {
    if (lastName == null) return false;
    return lastName.endsWith(".");
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.patientDetails)),
      body: MultiBlocListener(
        listeners: [
          BlocListener<PatientInfoCubit, PatientInfoState>(
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
                    context.pop();
                  },
                );
              }
            },
          ),
        ],
        child: BlocBuilder<PatientInfoCubit, PatientInfoState>(
          builder: (context, patientState) {
            final patient = patientState.patient ?? initialPatient;
            final isActive = patient.status.toLowerCase() == 'active';

            final hasHiddenData =
                _isFieldHidden(patient.phone) ||
                _isFieldHidden(patient.email) ||
                _isFieldHidden(patient.dni) ||
                _isLastNamePartial(patient.lastName) ||
                _isFieldHidden(patient.address?.formattedAddress);

            return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasHiddenData)
                        Card(
                          color: AppColors.warning30.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.lock_outline,
                                  color: AppColors.warning30,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    s.partialData,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      Text(
                        s.personalInfo,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildInfoRow(
                        s.register_firstName,
                        patient.firstName,
                        false,
                        theme,
                        s,
                      ),
                      _buildInfoRow(
                        s.register_lastName,
                        _isLastNamePartial(patient.lastName)
                            ? "${patient.lastName} 🔒"
                            : patient.lastName,
                        _isLastNamePartial(patient.lastName),
                        theme,
                        s,
                      ),
                      _buildInfoRow(
                        s.dni,
                        patient.dni,
                        _isFieldHidden(patient.dni),
                        theme,
                        s,
                      ),
                      _buildInfoRow(s.gender, patient.gender, false, theme, s),
                      _buildInfoRow(
                        s.birthDate,
                        patient.birthDate?.toString().split(' ').first,
                        false,
                        theme,
                        s,
                      ),

                      const SizedBox(height: 24),

                      Text(
                        s.contactInfo,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildInfoRow(
                        s.phone,
                        patient.phone,
                        _isFieldHidden(patient.phone),
                        theme,
                        s,
                      ),
                      _buildInfoRow(
                        s.email,
                        patient.email,
                        _isFieldHidden(patient.email),
                        theme,
                        s,
                      ),
                      _buildInfoRow(
                        s.address,
                        patient.address?.formattedAddress ??
                            patient.address?.city,
                        _isFieldHidden(patient.address?.formattedAddress),
                        theme,
                        s,
                      ),
                      _buildInfoRow(
                        s.city,
                        patient.address?.city,
                        false,
                        theme,
                        s,
                      ),

                      const SizedBox(height: 24),

                      Text(
                        s.medicalInfo,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildInfoRow(
                        s.protocol,
                        patient.protocol?.name,
                        false,
                        theme,
                        s,
                      ),
                      _buildInfoRow(
                        s.specialty,
                        patient.specialties.isNotEmpty
                            ? '${patient.specialties.length} especialidades'
                            : null,
                        false,
                        theme,
                        s,
                      ),
                      _buildInfoRow(
                        s.homePathology,
                        patient.pathologies.isNotEmpty
                            ? '${patient.pathologies.length} patologías'
                            : null,
                        false,
                        theme,
                        s,
                      ),
                      _buildInfoRow(s.notes, patient.notes, false, theme, s),

                      const SizedBox(height: 24),

                      // Firma del paciente
                      if (patient.signatureUrl != null &&
                          patient.signatureUrl!.isNotEmpty) ...[
                        Text(
                          s.signature,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.neutral80),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              patient.signatureUrl!,
                              fit: BoxFit.contain,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image_outlined,
                                        size: 40,
                                        color: AppColors.neutral50,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        s.errorLoadingImage,
                                        style: TextStyle(
                                          color: AppColors.neutral50,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      if (patient.order == null && patient.currentOrderId == null)
                        Card(
                          color: Colors.red[400], // Red card (less intense)
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    s.noOrderLinked,
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (patient.order != null)
                        Card(
                          color: AppColors.primary30,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.assignment_turned_in_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      s.activeOrder,
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildOrderInfoRow(
                                  s.orderId,
                                  patient.order!.id?.substring(0, 8) ?? "-",
                                  Colors.white70,
                                  Colors.white,
                                  theme,
                                ),
                                _buildOrderInfoRow(
                                  s.status,
                                  patient.order!.status.name.toUpperCase(),
                                  Colors.white70,
                                  Colors.white,
                                  theme,
                                ),
                                const Divider(color: Colors.white24),
                                const SizedBox(height: 8),
                                Text(
                                  s.professionalFees,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "\$${patient.order!.amount.toStringAsFixed(2)}",
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                if (patient.order!.notes != null &&
                                    patient.order!.notes!.isNotEmpty) ...[
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8),
                                    child: Divider(color: Colors.white24),
                                  ),
                                  Text(
                                    patient.order!.status ==
                                            OrderStatus.rejected
                                        ? "Motivo de rechazo:"
                                        : "Notas de aceptación:",
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    patient.order!.notes!,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        )
                      else
                        const Center(child: CircularProgressIndicator()),

                      const SizedBox(height: 32),

                      // Active/Inactive Button
                      if (isActive)
                        CustomButton(
                          text: s.markAsInactive,
                          onPressed:
                              patientState.status == PatientInfoStatus.loading
                              ? null
                              : () {
                                  _showConfirmationDialog(
                                    context,
                                    s,
                                    isMarkingAsActive: false,
                                    cubit: context.read<PatientInfoCubit>(),
                                  );
                                },
                        )
                      else
                        CustomButton(
                          text: s.markAsActive,
                          onPressed:
                              patientState.status == PatientInfoStatus.loading
                              ? null
                              : () {
                                  _showConfirmationDialog(
                                    context,
                                    s,
                                    isMarkingAsActive: true,
                                    cubit: context.read<PatientInfoCubit>(),
                                  );
                                },
                        ),
                    ],
                  ),
                );
          },
        ),
      ),
    );
  }

  Widget _buildOrderInfoRow(
    String label,
    String? value,
    Color labelColor,
    Color valueColor,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: theme.textTheme.bodyMedium?.copyWith(color: labelColor),
          ),
          Text(
            value ?? "-",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String? value,
    bool isHidden,
    ThemeData theme,
    S s,
  ) {
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
            child: isHidden
                ? Tooltip(
                    message: s.payForFullData,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock,
                          size: 16,
                          color: AppColors.warning30,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          value ?? "***",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.neutral40,
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(value ?? "-", style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    S s, {
    required bool isMarkingAsActive,
    required PatientInfoCubit cubit,
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
              cubit.updatePatientStatus(newStatus);
            },
            child: Text(s.confirm),
          ),
        ],
      ),
    );
  }
}
