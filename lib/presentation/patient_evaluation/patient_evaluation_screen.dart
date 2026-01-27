import 'dart:io';

import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/data/models/order_model.dart';
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
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PatientEvaluationScreen extends StatelessWidget {
  static const path = "/patient-evaluation";
  final PatientModel patient;
  final OrderModel order;

  const PatientEvaluationScreen({
    super.key,
    required this.patient,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              OrderCubit(orderRepository: context.read<OrderRepository>()),
        ),
        BlocProvider(
          create: (context) => PaymentCubit(
            paymentRepository: context.read<PaymentRepository>(),
          ),
        ),
      ],
      child: PatientEvaluationView(patient: patient, order: order),
    );
  }
}

class PatientEvaluationView extends StatefulWidget {
  final PatientModel patient;
  final OrderModel order;

  const PatientEvaluationView({
    super.key,
    required this.patient,
    required this.order,
  });

  @override
  State<PatientEvaluationView> createState() => _PatientEvaluationViewState();
}

class _PatientEvaluationViewState extends State<PatientEvaluationView> {
  List<File> _attachedDocuments = [];

  Future<void> _pickDocuments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _attachedDocuments = result.paths
              .where((path) => path != null)
              .map((path) => File(path!))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        final s = S.of(context);
        CustomDialogs.errorDialog(context, "${s.errorSelectingFiles}: $e");
      }
    }
  }

  void _removeDocument(int index) {
    setState(() {
      _attachedDocuments.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.patientEvaluation)),
      body: MultiBlocListener(
        listeners: [
          BlocListener<OrderCubit, OrderState>(
            listener: (context, state) {
              if (state.status == OrderCubitStatus.success) {
                CustomDialogs.successDialog(
                  context: context,
                  onPressed: () {},
                  successMessage: s.orderCreatedSuccessfully,
                );
                Navigator.pop(context);
              } else if (state.status == OrderCubitStatus.failure) {
                CustomDialogs.errorDialog(
                  context,
                  state.errorMessage ?? s.errorOccurred,
                );
              }
            },
          ),
          BlocListener<PaymentCubit, PaymentState>(
            listener: (context, state) {
              if (state.status == PaymentStatus.success) {
                if (state.successMessage != null) {
                  CustomDialogs.successDialog(
                    context: context,
                    onPressed: () {},
                    successMessage: s.orderCreatedSuccessfully,
                  );
                }
                Navigator.pop(context);
              } else if (state.status == PaymentStatus.failure) {
                CustomDialogs.errorDialog(
                  context,
                  state.errorMessage ?? s.errorOccurred,
                );
              }
            },
          ),
        ],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: AppColors.danger20.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.warning0,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              s.fullData,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.fullDataAvailableAfterPayment,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                s.personalInfo,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _buildInfoRow(
                s.register_firstName,
                widget.patient.firstName,
                theme,
              ),
              _buildInfoRow(
                s.register_lastName,
                widget.patient.lastName,
                theme,
              ),
              _buildInfoRow(s.dni, widget.patient.dni, theme),
              _buildInfoRow(s.gender, widget.patient.gender, theme),
              _buildInfoRow(
                s.birthDate,
                widget.patient.birthDate?.toString().split(' ').first,
                theme,
              ),

              const SizedBox(height: 24),

              Text(
                s.contactInfo,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _buildInfoRow(s.phone, widget.patient.phone, theme),
              _buildInfoRow(s.email, widget.patient.email, theme),
              _buildInfoRow(
                s.address,
                widget.patient.address?.formattedAddress ??
                    widget.patient.address?.city,
                theme,
              ),

              const SizedBox(height: 24),

              Text(
                s.medicalInfo,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _buildInfoRow(s.protocol, widget.patient.protocol?.name, theme),
              _buildInfoRow(s.notes, widget.patient.notes, theme),

              const SizedBox(height: 32),

              Text(
                s.attachProof,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _pickDocuments,
                icon: const Icon(Icons.attach_file),
                label: Text(s.attachDocuments),
              ),

              if (_attachedDocuments.isNotEmpty) ...[
                const SizedBox(height: 12),
                ..._attachedDocuments.asMap().entries.map((entry) {
                  final index = entry.key;
                  final file = entry.value;
                  return ListTile(
                    leading: const Icon(Icons.description),
                    title: Text(file.path.split('/').last),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _removeDocument(index),
                    ),
                  );
                }),
              ],

              if (_attachedDocuments.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    s.noDocumentsAttached,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral40,
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: Text(s.confirmReject),
                            content: Text(s.confirmRejectMessage),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: Text(s.cancel),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  context.read<OrderCubit>().rejectOrder(
                                    widget.order.id ?? "",
                                    _attachedDocuments.isNotEmpty
                                        ? _attachedDocuments
                                        : null,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.danger0,
                                ),
                                child: Text(s.reject),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger0,
                        side: const BorderSide(color: AppColors.danger0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(s.rejectPatient),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: s.acceptAndPayFinal,
                      onPressed: () {
                        context.read<PaymentCubit>().initiatePayment(
                          widget.patient.id ?? "",
                          "full",
                        );
                      },
                    ),
                  ),
                ],
              ),

              BlocBuilder<OrderCubit, OrderState>(
                builder: (context, orderState) {
                  if (orderState.status == OrderCubitStatus.loading) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              BlocBuilder<PaymentCubit, PaymentState>(
                builder: (context, paymentState) {
                  if (paymentState.status == PaymentStatus.processing ||
                      paymentState.status == PaymentStatus.creatingIntent) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 8),
                            Text(s.processing),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
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
}
