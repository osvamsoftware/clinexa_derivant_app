import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/data/models/order_model.dart';
import 'package:clinexa_derivant_app/data/models/patient_model.dart';
import 'package:clinexa_derivant_app/domain/order_repository.dart';
import 'package:clinexa_derivant_app/domain/patient_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/patient_info/cubit/patient_info_cubit.dart';
import 'package:clinexa_derivant_app/presentation/patient_info/cubit/patient_info_state.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/patient_result_card.dart';
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
    final c = context.clx;
    final t = context.clxText;

    return Scaffold(
      appBar: ClxAppBar(title: s.patientDetails),
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

            final order = patient.order;

            return ListView(
              padding: const EdgeInsets.fromLTRB(ClxSpace.s4, ClxSpace.s5, ClxSpace.s4, ClxSpace.s8),
              children: [
                // Encabezado del paciente
                Row(
                  children: [
                    ClxAvatar(name: patient.fullName, size: 56),
                    const SizedBox(width: ClxSpace.s4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(patient.fullName, style: t.h1),
                          const SizedBox(height: ClxSpace.s2),
                          Wrap(
                            spacing: ClxSpace.s2,
                            runSpacing: ClxSpace.s2,
                            children: [
                              ClxBadge(
                                label: isActive ? s.statusActive : s.statusInactive,
                                tone: isActive ? ClxTone.success : ClxTone.neutral,
                              ),
                              if (order != null)
                                ClxBadge(
                                  label: PatientResultCard.orderStatusLabel(order.status.name, s),
                                  tone: PatientResultCard.orderStatusTone(order.status.name),
                                  icon: LucideIcons.fileText,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (hasHiddenData) ...[
                  const SizedBox(height: ClxSpace.s5),
                  ClxNotice(
                    tone: ClxTone.warning,
                    icon: LucideIcons.lock,
                    title: s.partialData,
                    message: s.partialDataMessage,
                  ),
                ],

                // Orden y honorarios
                const SizedBox(height: ClxSpace.s6),
                if (order == null && patient.currentOrderId == null)
                  ClxNotice(
                    tone: ClxTone.neutral,
                    icon: LucideIcons.fileClock,
                    title: s.noOrderLinked,
                    message: s.noOrderLinkedMessage,
                  )
                else if (order != null && order.paymentStage != 'initial')
                  _OrderCard(order: order)
                else if (order == null && patient.currentOrderId != null)
                  const ClxCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClxSkeleton(width: 120, height: 16),
                        SizedBox(height: ClxSpace.s4),
                        ClxSkeleton(height: 12),
                        SizedBox(height: ClxSpace.s2),
                        ClxSkeleton(width: 200, height: 12),
                      ],
                    ),
                  ),

                const SizedBox(height: ClxSpace.s8),
                _InfoSection(
                  title: s.personalInfo,
                  children: [
                    ClxKeyValue(label: s.register_firstName, value: patient.firstName),
                    _row(s, s.register_lastName, patient.lastName, _isLastNamePartial(patient.lastName)),
                    _row(s, s.dni, patient.dni, _isFieldHidden(patient.dni), mono: true),
                    ClxKeyValue(label: s.gender, value: _genderLabel(s, patient.gender)),
                    ClxKeyValue(
                      label: s.birthDate,
                      value: patient.birthDate?.toString().split(' ').first ?? '',
                      mono: true,
                    ),
                  ],
                ),

                const SizedBox(height: ClxSpace.s6),
                _InfoSection(
                  title: s.contactInfo,
                  children: [
                    _row(s, s.phone, patient.phone, _isFieldHidden(patient.phone), mono: true),
                    _row(s, s.email, patient.email, _isFieldHidden(patient.email)),
                    _row(
                      s,
                      s.address,
                      patient.address?.formattedAddress ?? patient.address?.city,
                      _isFieldHidden(patient.address?.formattedAddress),
                    ),
                    ClxKeyValue(label: s.city, value: patient.address?.city ?? ''),
                  ],
                ),

                const SizedBox(height: ClxSpace.s6),
                _InfoSection(
                  title: s.medicalInfo,
                  children: [
                    ClxKeyValue(label: s.protocol, value: patient.protocol?.name ?? ''),
                    ClxKeyValue(
                      label: s.specialties,
                      value: patient.specialties.isNotEmpty
                          ? s.specialtiesCount(patient.specialties.length)
                          : '',
                    ),
                    ClxKeyValue(
                      label: s.homePathology,
                      value: patient.pathologies.isNotEmpty
                          ? s.pathologiesCount(patient.pathologies.length)
                          : '',
                    ),
                    ClxKeyValue(label: s.notes, value: patient.notes ?? ''),
                  ],
                ),

                // Firma del paciente
                if (patient.signatureUrl != null &&
                    patient.signatureUrl!.isNotEmpty) ...[
                  const SizedBox(height: ClxSpace.s6),
                  Padding(
                    padding: const EdgeInsets.only(left: ClxSpace.s1, bottom: ClxSpace.s2),
                    child: Text(s.signature.toUpperCase(), style: t.label),
                  ),
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      // La firma es una imagen sobre papel blanco.
                      color: ClxColors.surfaceRaised,
                      border: Border.all(color: c.border),
                      borderRadius: BorderRadius.circular(ClxRadius.lg),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(ClxRadius.lg),
                      child: Image.network(
                        patient.signatureUrl!,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Padding(
                            padding: EdgeInsets.all(ClxSpace.s4),
                            child: ClxSkeleton(height: double.infinity, radius: ClxRadius.md),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.imageOff, size: 28, color: ClxColors.inkSubtle),
                                const SizedBox(height: ClxSpace.s2),
                                Text(
                                  s.errorLoadingImage,
                                  style: t.bodySm.copyWith(color: ClxColors.inkMuted),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // Activar / desactivar: solo mientras nadie pagó por ver
                // los datos del paciente. Una vez que un receptor paga el
                // acceso inicial, patient.assignedTo queda seteado (y no
                // se limpia ni siquiera si luego rechaza al paciente), así
                // que ya no tiene sentido dejar que el derivante lo
                // active/desactive manualmente.
                if (patient.assignedTo == null) ...[
                  const SizedBox(height: ClxSpace.s8),
                  if (isActive)
                    ClxButton.secondary(
                      key: const Key('patient_toggle_status'),
                      label: s.markAsInactive,
                      icon: LucideIcons.userX,
                      onPressed: patientState.status == PatientInfoStatus.loading
                          ? null
                          : () => _showConfirmationDialog(
                                context,
                                s,
                                isMarkingAsActive: false,
                                cubit: context.read<PatientInfoCubit>(),
                              ),
                    )
                  else
                    ClxButton(
                      key: const Key('patient_toggle_status'),
                      label: s.markAsActive,
                      icon: LucideIcons.userCheck,
                      onPressed: patientState.status == PatientInfoStatus.loading
                          ? null
                          : () => _showConfirmationDialog(
                                context,
                                s,
                                isMarkingAsActive: true,
                                cubit: context.read<PatientInfoCubit>(),
                              ),
                    ),
                  const SizedBox(height: ClxSpace.s2),
                  Text(
                    isActive ? s.markAsInactiveHelper : s.markAsActiveHelper,
                    style: t.bodySm,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  String _genderLabel(S s, String? gender) {
    switch (gender) {
      case 'Male':
        return s.male;
      case 'Female':
        return s.female;
      case 'Other':
        return s.other;
      default:
        return gender ?? '';
    }
  }

  Widget _row(S s, String label, String? value, bool isHidden, {bool mono = false}) {
    if (isHidden) {
      return ClxKeyValue(
        label: label,
        value: '',
        valueWidget: ClxLockedValue(text: value ?? s.hiddenField, tooltip: s.payForFullData),
      );
    }
    return ClxKeyValue(label: label, value: value ?? '', mono: mono);
  }

  void _showConfirmationDialog(
    BuildContext context,
    S s, {
    required bool isMarkingAsActive,
    required PatientInfoCubit cubit,
  }) async {
    final confirmMessage = isMarkingAsActive
        ? s.confirmMarkAsActive
        : s.confirmMarkAsInactive;
    final newStatus = isMarkingAsActive ? 'active' : 'inactive';

    final ok = await ClxDialog.confirm(
      context,
      title: isMarkingAsActive ? s.markAsActiveTitle : s.markAsInactiveTitle,
      message: confirmMessage,
      confirmLabel: isMarkingAsActive ? s.markAsActive : s.markAsInactive,
      cancelLabel: s.cancel,
      icon: isMarkingAsActive ? LucideIcons.userCheck : LucideIcons.userX,
    );
    if (ok) cubit.updatePatientStatus(newStatus);
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: ClxSpace.s1, bottom: ClxSpace.s2),
          child: Text(title.toUpperCase(), style: context.clxText.label),
        ),
        ClxCard(
          padding: const EdgeInsets.symmetric(horizontal: ClxSpace.s4, vertical: ClxSpace.s2),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) Divider(height: 1, color: c.border),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.clx;
    final t = context.clxText;
    final hasNotes = order.notes != null && order.notes!.isNotEmpty;

    return ClxCard(
      padding: const EdgeInsets.all(ClxSpace.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.fileCheck, size: 18, color: c.brandBlue),
              const SizedBox(width: ClxSpace.s2),
              Expanded(child: Text(s.activeOrder, style: t.h3)),
              ClxBadge(
                label: PatientResultCard.orderStatusLabel(order.status.name, s),
                tone: PatientResultCard.orderStatusTone(order.status.name),
              ),
            ],
          ),
          const SizedBox(height: ClxSpace.s3),
          ClxKeyValue(
            label: s.orderId,
            value: order.id?.substring(0, 8) ?? "-",
            mono: true,
          ),
          Divider(height: ClxSpace.s5, color: c.border),
          Text(s.professionalFees, style: t.bodySm),
          const SizedBox(height: ClxSpace.s1),
          Text(
            "\$${(order.amount * 0.9).toStringAsFixed(2)}",
            style: t.dataLg,
          ),
          if (hasNotes) ...[
            Divider(height: ClxSpace.s6, color: c.border),
            Text(
              (order.status == OrderStatus.rejected
                      ? s.rejectionReason
                      : s.acceptanceNotes)
                  .toUpperCase(),
              style: t.label,
            ),
            const SizedBox(height: ClxSpace.s1),
            Text(order.notes!, style: t.body),
          ],
        ],
      ),
    );
  }
}
