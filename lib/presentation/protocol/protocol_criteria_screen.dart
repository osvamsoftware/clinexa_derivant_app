import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/data/models/protocol_model.dart';
import 'package:clinexa_derivant_app/presentation/protocol/cubit/protocol_criteria_cubit.dart';
import 'package:clinexa_derivant_app/presentation/protocol/cubit/protocol_criteria_state.dart';
import 'package:clinexa_derivant_app/presentation/register_patient/patient_registration_screen.dart';
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
    final s = S.of(context);

    return BlocListener<ProtocolCriteriaCubit, ProtocolCriteriaState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          if (state.errorMessage == "ERROR_CRITERIA_NOT_MET") {
            ClxDialog.alert(
              context,
              title: s.criteriaNotMet,
              message: s.notAllCriteriaMet,
              buttonLabel: s.ok,
              tone: ClxTone.warning,
              icon: LucideIcons.listChecks,
            );
          } else {
            CustomDialogs.errorDialog(context, state.errorMessage!);
          }
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
        appBar: ClxAppBar(
          title: s.protocolDetails,
          actions: [
            ClxButton.ghost(
              key: const Key('show_all_criteria_button'),
              label: s.showAll,
              size: ClxButtonSize.sm,
              onPressed: () => _showFullCriteriaSheet(context),
            ),
          ],
        ),
        body: const _CriteriaBody(),
        bottomNavigationBar: ClxBottomBar(child: _NextButton()),
      ),
    );
  }

  void _showFullCriteriaSheet(BuildContext context) {
    final state = context.read<ProtocolCriteriaCubit>().state;
    final s = S.of(context);
    ClxSheet.show(
      context,
      title: s.allCriteriaTitle,
      subtitle: state.protocol.name,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: state.allCriteria.length,
        separatorBuilder: (_, __) =>
            Divider(height: ClxSpace.s5, color: context.clx.border),
        itemBuilder: (context, index) {
          final item = state.allCriteria[index];
          final t = context.clxText;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  (index + 1).toString().padLeft(2, '0'),
                  style: t.data.copyWith(color: context.clx.inkSubtle),
                ),
              ),
              const SizedBox(width: ClxSpace.s2),
              Expanded(child: Text(item.text, style: t.body)),
            ],
          );
        },
      ),
    );
  }
}

class _CriteriaBody extends StatelessWidget {
  const _CriteriaBody();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final t = context.clxText;
    return BlocBuilder<ProtocolCriteriaCubit, ProtocolCriteriaState>(
      builder: (context, state) {
        final criteriaList = state.currentStepCriteria;
        final checkedInStep = criteriaList
            .where((c) => state.checkedCriteriaIds.contains(c.text))
            .length;
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            ClxSpace.s4,
            ClxSpace.s5,
            ClxSpace.s4,
            ClxSpace.s6,
          ),
          children: [
            ClxStepper(
              current: state.currentStep,
              total: state.totalSteps < 1 ? 1 : state.totalSteps,
              label: s.criteriaStepLabel,
            ),
            const SizedBox(height: ClxSpace.s5),
            Text(state.protocol.name, style: t.h1),
            const SizedBox(height: ClxSpace.s2),
            Text(s.protocolCriteriaVerificationInfo, style: t.bodyMuted),
            const SizedBox(height: ClxSpace.s6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.criteriaChecklistLabel.toUpperCase(),
                    style: t.label,
                  ),
                ),
                ClxBadge(
                  label: s.criteriaCheckedCount(
                    checkedInStep,
                    criteriaList.length,
                  ),
                  tone: checkedInStep == criteriaList.length
                      ? ClxTone.success
                      : ClxTone.neutral,
                ),
              ],
            ),
            const SizedBox(height: ClxSpace.s3),
            for (var i = 0; i < criteriaList.length; i++) ...[
              ClxCheckTile(
                key: ValueKey('criterion_$i'),
                text: criteriaList[i].text,
                selected: state.checkedCriteriaIds.contains(
                  criteriaList[i].text,
                ),
                onTap: () {
                  context.read<ProtocolCriteriaCubit>().toggleCriteria(
                    criteriaList[i].text,
                  );
                },
              ),
              if (i < criteriaList.length - 1)
                const SizedBox(height: ClxSpace.s2),
            ],
          ],
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
        return ClxButton(
          key: const Key('criteria_next_button'),
          label: state.isLastStep ? s.nextRegister : s.nextStep,
          trailingIcon: LucideIcons.arrowRight,
          onPressed: () {
            context.read<ProtocolCriteriaCubit>().nextStep();
          },
        );
      },
    );
  }
}
