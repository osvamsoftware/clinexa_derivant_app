import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/data/models/ai_models.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/ai_request_state.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/eligibility_cubit.dart';
import 'package:clinexa_derivant_app/presentation/ai/widgets/ai_common.dart';
import 'package:clinexa_derivant_app/presentation/register_patient/cubit/patient_registration_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// IA-02 · Pre-evaluación de elegibilidad dentro del formulario del
/// paciente: los datos clínicos se cargan después de los criterios, así que
/// la evaluación se ofrece aquí, antes de enviar la derivación.
///
/// Advierte si un criterio no se cumple, pero nunca bloquea el envío.
class EligibilityPanel extends StatelessWidget {
  const EligibilityPanel({super.key});

  AiCase _case(PatientRegistrationCubit reg, EligibilityCubit elig) => AiCase(
    age: elig.ageFor(reg.birthDate),
    sex: EligibilityCubit.sexFromGender(reg.gender),
    pathologies: elig.state.pathologies,
    notes: reg.notesController.text.trim(),
  );

  void _evaluate(BuildContext context) {
    final reg = context.read<PatientRegistrationCubit>();
    final elig = context.read<EligibilityCubit>();
    final aiCase = _case(reg, elig);
    FocusManager.instance.primaryFocus?.unfocus();
    if (aiCase.isEmpty) {
      ClxToast.show(
        context,
        S.of(context).aiEligibilityEmptyCase,
        tone: ClxTone.warning,
      );
      return;
    }
    elig.evaluate(aiCase);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final t = context.clxText;
    // Se reconstruye cuando cambian la fecha de nacimiento o el sexo.
    return BlocBuilder<PatientRegistrationCubit, PatientRegistrationState>(
      buildWhen: (a, b) => a.formRevision != b.formRevision,
      builder: (context, _) => BlocBuilder<EligibilityCubit, EligibilityState>(
        builder: (context, state) {
          final req = state.request;
          return Column(
            key: const Key('ai_eligibility_panel'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClxAiSurface(
                padding: const EdgeInsets.all(ClxSpace.s4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AiCardHeader(title: s.aiEligibilityTitle),
                    const SizedBox(height: ClxSpace.s2),
                    Text(s.aiEligibilityIntro, style: t.bodySm),
                    const SizedBox(height: ClxSpace.s4),
                    _CaseSummary(
                      aiCase: _case(
                        context.read<PatientRegistrationCubit>(),
                        context.read<EligibilityCubit>(),
                      ),
                    ),
                    const SizedBox(height: ClxSpace.s4),
                    ClxAiButton(
                      key: const Key('ai_eligibility_evaluate'),
                      label: req.status == AiRequestStatus.success
                          ? s.aiEligibilityReevaluate
                          : s.aiEligibilityEvaluate,
                      icon: req.status == AiRequestStatus.success
                          ? LucideIcons.rotateCw
                          : LucideIcons.listChecks,
                      loading: req.isLoading,
                      loadingLabel: s.aiEligibilityEvaluating,
                      onPressed: () => _evaluate(context),
                    ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                alignment: Alignment.topCenter,
                child: switch (req.status) {
                  AiRequestStatus.idle => const SizedBox(
                    width: double.infinity,
                  ),
                  AiRequestStatus.loading => Padding(
                    padding: const EdgeInsets.only(top: ClxSpace.s4),
                    child: ClxAiThinking(
                      key: const Key('ai_eligibility_thinking'),
                      title: s.aiThinkingTitle,
                      messages: [
                        s.aiEligibilityThinking1,
                        s.aiEligibilityThinking2,
                        s.aiEligibilityThinking3,
                        s.aiEligibilityThinking4,
                      ],
                    ),
                  ),
                  AiRequestStatus.failure => Padding(
                    padding: const EdgeInsets.only(top: ClxSpace.s4),
                    child: AiErrorNotice(
                      error: req.error,
                      onRetry: () => _evaluate(context),
                    ),
                  ),
                  AiRequestStatus.success => Padding(
                    padding: const EdgeInsets.only(top: ClxSpace.s4),
                    child: _Result(state: state),
                  ),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CaseSummary extends StatefulWidget {
  const _CaseSummary({required this.aiCase});

  final AiCase aiCase;

  @override
  State<_CaseSummary> createState() => _CaseSummaryState();
}

class _CaseSummaryState extends State<_CaseSummary> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    context.read<EligibilityCubit>().addPathology(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.clx;
    final t = context.clxText;
    final cubit = context.read<EligibilityCubit>();
    final aiCase = widget.aiCase;
    return Container(
      padding: const EdgeInsets.all(ClxSpace.s3),
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: BorderRadius.circular(ClxRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(s.aiEligibilityCaseLabel.toUpperCase(), style: t.label),
          const SizedBox(height: ClxSpace.s2),
          Row(
            children: [
              Expanded(
                child: _Fact(
                  label: s.aiFieldAge,
                  value: aiCase.age == null
                      ? s.aiNotProvided
                      : s.aiAgeYears(aiCase.age!),
                ),
              ),
              Expanded(
                child: _Fact(
                  label: s.aiFieldSex,
                  value: aiSexLabel(context, aiCase.sex),
                ),
              ),
            ],
          ),
          const SizedBox(height: ClxSpace.s3),
          Text(s.aiEligibilityPathologies, style: t.bodySmStrong),
          const SizedBox(height: ClxSpace.s2),
          if (aiCase.pathologies.isNotEmpty) ...[
            Wrap(
              spacing: ClxSpace.s2,
              runSpacing: ClxSpace.s2,
              children: [
                for (final p in aiCase.pathologies)
                  ClxInputChip(
                    label: p,
                    removeTooltip: s.aiRemove,
                    onRemove: () => cubit.removePathology(p),
                  ),
              ],
            ),
            const SizedBox(height: ClxSpace.s2),
          ],
          Row(
            children: [
              Expanded(
                child: ClxTextField(
                  key: const Key('ai_eligibility_pathology_field'),
                  hint: s.aiEligibilityPathologyHint,
                  controller: _controller,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _add(),
                ),
              ),
              const SizedBox(width: ClxSpace.s2),
              ClxIconButton(
                icon: LucideIcons.plus,
                tooltip: s.aiAdd,
                filled: true,
                onPressed: _add,
              ),
            ],
          ),
          const SizedBox(height: ClxSpace.s3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.notebookPen, size: 14, color: c.inkSubtle),
              const SizedBox(width: ClxSpace.s2),
              Expanded(
                child: Text(
                  s.aiEligibilityNotesFromForm,
                  style: t.bodySm.copyWith(fontSize: 12.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.clxText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: t.bodySm.copyWith(fontSize: 12)),
        Text(value, style: t.bodyStrong),
      ],
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.state});

  final EligibilityState state;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final t = context.clxText;
    final result = state.result!;
    return Column(
      key: const Key('ai_eligibility_result'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClxAiReveal(
          child: ClxAiSurface(
            padding: const EdgeInsets.all(ClxSpace.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClxAiScore(score: result.fitScore, label: s.aiFitLabel),
                    const SizedBox(width: ClxSpace.s4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClxAiTag(label: s.aiSuggestedTag),
                          const SizedBox(height: ClxSpace.s2),
                          Text(result.summary, style: t.body),
                        ],
                      ),
                    ),
                  ],
                ),
                if (state.missingCount > 0) ...[
                  const SizedBox(height: ClxSpace.s3),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ClxBadge(
                      label: s.aiEligibilityMissingCount(state.missingCount),
                      tone: ClxTone.warning,
                      icon: LucideIcons.circleHelp,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (state.hasFails) ...[
          const SizedBox(height: ClxSpace.s3),
          ClxAiReveal(
            index: 1,
            child: ClxNotice(
              key: const Key('ai_eligibility_fails_warning'),
              tone: ClxTone.warning,
              title: s.aiEligibilityFailsWarningTitle,
              message: s.aiEligibilityFailsWarning,
            ),
          ),
        ],
        const SizedBox(height: ClxSpace.s4),
        Text(s.aiEligibilityCorrectHint, style: t.bodySm),
        const SizedBox(height: ClxSpace.s2),
        for (var i = 0; i < result.items.length; i++) ...[
          ClxAiReveal(
            index: i + 2,
            child: _ItemCard(item: result.items[i], state: state),
          ),
          const SizedBox(height: ClxSpace.s2),
        ],
        const SizedBox(height: ClxSpace.s2),
        ClxAiDisclaimer(text: s.aiDisclaimer),
        const SizedBox(height: ClxSpace.s2),
        ClxAiDisclaimer(text: s.aiEligibilityAttachNote),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.state});

  final EligibilityItem item;
  final EligibilityState state;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.clx;
    final t = context.clxText;
    final current = state.statusOf(item);
    final corrected = state.isCorrected(item);
    return ClxCard(
      key: ValueKey('ai_eligibility_item_${item.order}'),
      padding: const EdgeInsets.all(ClxSpace.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                item.order.toString().padLeft(2, '0'),
                style: t.data.copyWith(color: c.inkSubtle),
              ),
              const SizedBox(width: ClxSpace.s2),
              Text(
                (item.isExclusion
                        ? s.aiCriterionExclusion
                        : s.aiCriterionInclusion)
                    .toUpperCase(),
                style: t.label,
              ),
              const Spacer(),
              const SizedBox(width: ClxSpace.s2),
              if (corrected)
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.userPen, size: 13, color: c.brandBlue),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          s.aiCorrectedByYou,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.bodySm.copyWith(
                            fontSize: 12,
                            color: c.brandBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: ClxSpace.s1),
          Text(item.text, style: t.bodyStrong),
          if (item.evidence.isNotEmpty) ...[
            const SizedBox(height: ClxSpace.s1),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    LucideIcons.quote,
                    size: 12,
                    color: c.accentViolet,
                  ),
                ),
                const SizedBox(width: ClxSpace.s2),
                Expanded(child: Text(item.evidence, style: t.bodySm)),
              ],
            ),
          ],
          const SizedBox(height: ClxSpace.s3),
          _StatusSelector(
            order: item.order,
            value: current,
            onChanged: (v) =>
                context.read<EligibilityCubit>().correct(item.order, v),
          ),
        ],
      ),
    );
  }
}

/// Tres opciones para que el médico confirme o corrija el resultado.
class _StatusSelector extends StatelessWidget {
  const _StatusSelector({
    required this.order,
    required this.value,
    required this.onChanged,
  });

  final int order;
  final EligibilityStatus value;
  final ValueChanged<EligibilityStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Row(
      children: [
        for (final (status, label, icon) in [
          (EligibilityStatus.meets, s.aiStatusMeets, LucideIcons.circleCheck),
          (EligibilityStatus.fails, s.aiStatusFails, LucideIcons.circleX),
          (
            EligibilityStatus.missing,
            s.aiStatusMissing,
            LucideIcons.circleHelp,
          ),
        ]) ...[
          Expanded(
            child: _StatusOption(
              key: ValueKey('ai_eligibility_${order}_${status.name}'),
              status: status,
              label: label,
              icon: icon,
              selected: status == value,
              onTap: () => onChanged(status),
            ),
          ),
          if (status != EligibilityStatus.missing)
            const SizedBox(width: ClxSpace.s2),
        ],
      ],
    );
  }
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    super.key,
    required this.status,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final EligibilityStatus status;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final (fg, bg) = switch (status) {
      EligibilityStatus.meets => (c.success, c.successSoft),
      EligibilityStatus.fails => (c.danger, c.dangerSoft),
      EligibilityStatus.missing => (c.warning, c.warningSoft),
    };
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? bg : Colors.transparent,
        borderRadius: BorderRadius.circular(ClxRadius.pill),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ClxRadius.pill),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: ClxSpace.s2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ClxRadius.pill),
              border: Border.all(
                color: selected ? fg.withValues(alpha: 0.6) : c.border,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: selected ? fg : c.inkSubtle),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.clxText.bodySmStrong.copyWith(
                      fontSize: 12.5,
                      color: selected ? fg : c.inkMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
