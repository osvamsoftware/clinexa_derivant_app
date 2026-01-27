import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/data/models/patient_model.dart';
import 'package:clinexa_derivant_app/domain/order_repository.dart';
import 'package:clinexa_derivant_app/domain/payment_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/order/cubit/order_cubit.dart';
import 'package:clinexa_derivant_app/presentation/order/cubit/order_state.dart';
import 'package:clinexa_derivant_app/presentation/payment/cubit/payment_cubit.dart';
import 'package:clinexa_derivant_app/presentation/payment/cubit/payment_state.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_button.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PatientDetailsScreen extends StatelessWidget {
  static const path = "/patient-details";
  final PatientModel patient;

  const PatientDetailsScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              OrderCubit(orderRepository: context.read<OrderRepository>())
                ..loadOrderForPatient(patient.id ?? ""),
        ),
        BlocProvider(
          create: (context) => PaymentCubit(
            paymentRepository: context.read<PaymentRepository>(),
          ),
        ),
      ],
      child: PatientDetailsView(patient: patient),
    );
  }
}

class PatientDetailsView extends StatelessWidget {
  final PatientModel patient;

  const PatientDetailsView({super.key, required this.patient});

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

    final hasHiddenData =
        _isFieldHidden(patient.phone) ||
        _isFieldHidden(patient.email) ||
        _isFieldHidden(patient.dni) ||
        _isLastNamePartial(patient.lastName) ||
        _isFieldHidden(patient.address?.formattedAddress);

    return Scaffold(
      appBar: AppBar(title: Text(s.patientDetails)),
      body: BlocListener<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state.status == PaymentStatus.success) {
            if (state.successMessage != null) {
              CustomDialogs.successDialog(
                context: context,
                onPressed: () {},
                successMessage: s.orderCreatedSuccessfully,
              );
            }

            context.read<OrderCubit>().loadOrderForPatient(patient.id ?? "");
          } else if (state.status == PaymentStatus.failure) {
            CustomDialogs.errorDialog(
              context,
              state.errorMessage ?? s.errorOccurred,
            );
          }
        },
        child: BlocBuilder<OrderCubit, OrderState>(
          builder: (context, orderState) {
            final hasOrder = orderState.order != null;
            final orderStatus = orderState.order?.status.name;

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
                    patient.address?.formattedAddress ?? patient.address?.city,
                    _isFieldHidden(patient.address?.formattedAddress),
                    theme,
                    s,
                  ),
                  _buildInfoRow(s.city, patient.address?.city, false, theme, s),

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
                  _buildInfoRow(s.notes, patient.notes, false, theme, s),

                  const SizedBox(height: 32),

                  if (hasHiddenData && !hasOrder)
                    CustomButton(
                      text: s.payForFullData,
                      onPressed: () {
                        context.read<PaymentCubit>().initiatePayment(
                          patient.id ?? "",
                          "initial",
                        );
                      },
                    ),

                  if (hasOrder && orderStatus == "assigned")
                    CustomButton(
                      text: s.patientEvaluation,
                      onPressed: () {
                        // Navegar a pantalla de evaluación
                        Navigator.pushNamed(
                          context,
                          '/patient-evaluation',
                          arguments: {
                            'patient': patient,
                            'order': orderState.order,
                          },
                        );
                      },
                    ),

                  if (hasOrder && orderStatus == "accepted")
                    Card(
                      color: AppColors.primary20.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primary20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                s.orderStatusAccepted,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
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
}
