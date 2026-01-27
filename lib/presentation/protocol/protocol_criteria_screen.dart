import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/data/models/protocol_model.dart';
import 'package:clinexa_derivant_app/presentation/protocol/cubit/protocol_criteria_cubit.dart';
import 'package:clinexa_derivant_app/presentation/protocol/cubit/protocol_criteria_state.dart';
import 'package:clinexa_derivant_app/presentation/register_patient/patient_registration_screen.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_button.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';

class ProtocolCriteriaScreen extends StatelessWidget {
  static const path = '/protocol-criteria';
  final ProtocolModel protocol;

  const ProtocolCriteriaScreen({super.key, required this.protocol});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProtocolCriteriaCubit(protocol),
      child: const ProtocolCriteriaView(),
    );
  }
}

class ProtocolCriteriaView extends StatelessWidget {
  const ProtocolCriteriaView({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final s = S.of(context);

    return BlocListener<ProtocolCriteriaCubit, ProtocolCriteriaState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          final message = state.errorMessage == "ERROR_CRITERIA_NOT_MET"
              ? s.notAllCriteriaMet
              : state.errorMessage!;

          CustomDialogs.errorDialog(context, message);
          context.read<ProtocolCriteriaCubit>().resetError();
        }

        if (state.status == CriteriaStatus.completed) {
          // Navigate to Patient Registration with protocol ID
          context.pushNamed(
            PatientRegistrationScreen.path,
            extra: state.protocol.id, // Pass protocol ID
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.protocolDetails),
          actions: [
            TextButton(
              key: const Key('show_all_criteria_button'),
              onPressed: () {
                _showFullCriteriaDialog(context);
              },
              child: Text(s.showAll),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.protocolCriteriaVerificationInfo,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral10),
              ),
              const SizedBox(height: 24),
              _StepIndicator(),
              const SizedBox(height: 12),
              Expanded(child: _CriteriaList()),
              const SizedBox(height: 24),
              _NextButton(),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullCriteriaDialog(BuildContext context) {
    final state = context.read<ProtocolCriteriaCubit>().state;
    final s = S.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.allCriteriaFor(state.protocol.name)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: state.allCriteria.length,
            itemBuilder: (context, index) {
              final item = state.allCriteria[index];
              return ListTile(
                leading: const Icon(Icons.circle, size: 8),
                title: Text(item.text),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: Text(s.close)),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProtocolCriteriaCubit, ProtocolCriteriaState>(
      builder: (context, state) {
        final s = S.of(context);
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              s.stepXofY(state.currentStep, state.totalSteps),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary100,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CriteriaList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProtocolCriteriaCubit, ProtocolCriteriaState>(
      builder: (context, state) {
        final criteriaList = state.currentStepCriteria;
        return ListView.builder(
          itemCount: criteriaList.length,
          itemBuilder: (context, index) {
            final item = criteriaList[index];
            final isChecked = state.checkedCriteriaIds.contains(item.text);

            return Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  item.text,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral10),
                ),
                value: isChecked,
                activeColor: AppColors.primary40,
                onChanged: (val) {
                  context.read<ProtocolCriteriaCubit>().toggleCriteria(
                    item.text,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _NextButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProtocolCriteriaCubit, ProtocolCriteriaState>(
      builder: (context, state) {
        final s = S.of(context);
        return CustomButton(
          text: state.isLastStep ? s.nextRegister : s.nextStep,
          onPressed: () {
            context.read<ProtocolCriteriaCubit>().nextStep();
          },
        );
      },
    );
  }
}
