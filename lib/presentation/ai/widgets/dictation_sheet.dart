import 'package:clinexa_derivant_app/core/services/speech_service.dart';
import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/data/models/ai_models.dart';
import 'package:clinexa_derivant_app/domain/ai_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/dictation_cubit.dart';
import 'package:clinexa_derivant_app/presentation/ai/widgets/ai_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// IA-05 · Dictado de datos clínicos. Devuelve solo los campos que el médico
/// marcó (edad, sexo, patologías y notas), o null si canceló.
Future<DictationFields?> showDictationSheet(BuildContext context) {
  final s = S.of(context);
  return ClxSheet.show<DictationFields>(
    context,
    title: s.aiDictationTitle,
    child: BlocProvider(
      create: (_) => DictationCubit(
        context.read<AiRepository>(),
        context.read<SpeechService>(),
      )..start(),
      child: const DictationBody(),
    ),
  );
}

/// Dictado que solo transcribe (para describir un caso, IA-03). Devuelve el
/// texto o null si se canceló.
Future<String?> showTranscriptionSheet(BuildContext context) {
  final s = S.of(context);
  return ClxSheet.show<String>(
    context,
    title: s.aiDictationCaseTitle,
    child: BlocProvider(
      create: (_) => DictationCubit(
        context.read<AiRepository>(),
        context.read<SpeechService>(),
        parse: false,
      )..start(),
      child: const DictationBody(),
    ),
  );
}

class DictationBody extends StatelessWidget {
  const DictationBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DictationCubit, DictationState>(
      listenWhen: (a, b) => a.phase != b.phase,
      listener: (context, state) {
        final cubit = context.read<DictationCubit>();
        // Solo transcripción: al terminar se devuelve el texto.
        if (!cubit.parse &&
            state.phase == DictationPhase.idle &&
            state.transcript.trim().isNotEmpty) {
          Navigator.of(context).pop(state.transcript.trim());
        }
      },
      builder: (context, state) {
        final Widget child = switch (state.phase) {
          DictationPhase.idle ||
          DictationPhase.starting ||
          DictationPhase.listening => _Listening(state: state),
          DictationPhase.parsing => _Parsing(key: const ValueKey('parsing')),
          DictationPhase.proposal => _Proposal(
            fields: state.fields ?? const DictationFields(),
            transcript: state.transcript,
          ),
          DictationPhase.failure => _Problem(
            key: const ValueKey('failure'),
            child: AiErrorNotice(
              error: state.error,
              onRetry: () => context.read<DictationCubit>().parseTranscript(
                state.transcript,
              ),
            ),
          ),
          DictationPhase.unavailable => _Problem(
            key: const ValueKey('unavailable'),
            child: ClxNotice(
              tone: ClxTone.warning,
              icon: LucideIcons.micOff,
              message: S.of(context).aiDictationUnavailable,
            ),
          ),
          DictationPhase.empty => _Problem(
            key: const ValueKey('empty'),
            child: ClxNotice(
              tone: ClxTone.info,
              icon: LucideIcons.mic,
              message: S.of(context).aiDictationEmpty,
            ),
          ),
        };
        return SingleChildScrollView(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: child,
          ),
        );
      },
    );
  }
}

class _Listening extends StatelessWidget {
  const _Listening({required this.state});

  final DictationState state;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.clx;
    final t = context.clxText;
    final cubit = context.read<DictationCubit>();
    final listening = state.phase == DictationPhase.listening;
    return Column(
      key: const ValueKey('listening'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          cubit.parse ? s.aiDictationHint : s.aiDictationCaseHint,
          style: t.bodySm,
        ),
        const SizedBox(height: ClxSpace.s4),
        Center(
          child: ClxAiMicButton(
            key: const Key('ai_dictation_mic'),
            listening: listening,
            level: state.level,
            tooltip: listening ? s.aiDictationStop : s.aiDictate,
            onPressed: listening ? cubit.stop : cubit.start,
          ),
        ),
        const SizedBox(height: ClxSpace.s2),
        Center(
          child: Text(
            listening ? s.aiDictationListening : s.aiDictationPreparing,
            style: t.bodySmStrong.copyWith(color: c.accentViolet),
          ),
        ),
        const SizedBox(height: ClxSpace.s3),
        ClxAiVoiceWave(level: state.level, active: listening),
        const SizedBox(height: ClxSpace.s4),
        ClxAiSurface(
          glow: false,
          padding: const EdgeInsets.all(ClxSpace.s4),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topLeft,
              child: Text(
                state.transcript.isEmpty
                    ? s.aiDictationPlaceholder
                    : state.transcript,
                key: const Key('ai_dictation_transcript'),
                style: state.transcript.isEmpty
                    ? t.bodyMuted.copyWith(color: c.inkSubtle)
                    : t.body,
              ),
            ),
          ),
        ),
        const SizedBox(height: ClxSpace.s5),
        ClxAiButton(
          key: const Key('ai_dictation_done'),
          label: s.aiDictationStop,
          icon: LucideIcons.check,
          onPressed: listening ? cubit.stop : null,
        ),
        const SizedBox(height: ClxSpace.s2),
        Center(
          child: ClxButton.ghost(
            label: s.cancel,
            onPressed: () {
              cubit.cancel();
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}

class _Parsing extends StatelessWidget {
  const _Parsing({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final state = context.read<DictationCubit>().state;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClxAiThinking(
          title: s.aiThinkingTitle,
          messages: [
            s.aiDictationThinking1,
            s.aiDictationThinking2,
            s.aiDictationThinking3,
          ],
        ),
        const SizedBox(height: ClxSpace.s4),
        _TranscriptQuote(text: state.transcript),
      ],
    );
  }
}

class _TranscriptQuote extends StatelessWidget {
  const _TranscriptQuote({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.clx;
    final t = context.clxText;
    return Container(
      padding: const EdgeInsets.all(ClxSpace.s3),
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: BorderRadius.circular(ClxRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.aiDictationTranscript.toUpperCase(), style: t.label),
          const SizedBox(height: ClxSpace.s1),
          Text(
            text,
            style: t.bodySm,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Problem extends StatelessWidget {
  const _Problem({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final cubit = context.read<DictationCubit>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        child,
        const SizedBox(height: ClxSpace.s5),
        ClxAiButton(
          label: s.aiDictationTryAgain,
          icon: LucideIcons.mic,
          onPressed: cubit.start,
        ),
        const SizedBox(height: ClxSpace.s2),
        Center(
          child: ClxButton.ghost(
            label: s.cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}

enum _Field { age, sex, pathologies, notes }

class _Proposal extends StatefulWidget {
  const _Proposal({required this.fields, required this.transcript});

  final DictationFields fields;
  final String transcript;

  @override
  State<_Proposal> createState() => _ProposalState();
}

class _ProposalState extends State<_Proposal> {
  late final Set<_Field> _selected = {
    if (widget.fields.age != null) _Field.age,
    if (widget.fields.sex != null) _Field.sex,
    if (widget.fields.pathologies.isNotEmpty) _Field.pathologies,
    if (widget.fields.notes.trim().isNotEmpty) _Field.notes,
  };

  void _toggle(_Field f) => setState(
    () => _selected.contains(f) ? _selected.remove(f) : _selected.add(f),
  );

  DictationFields _result() {
    final f = widget.fields;
    return DictationFields(
      age: _selected.contains(_Field.age) ? f.age : null,
      sex: _selected.contains(_Field.sex) ? f.sex : null,
      pathologies: _selected.contains(_Field.pathologies)
          ? f.pathologies
          : const [],
      notes: _selected.contains(_Field.notes) ? f.notes : '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final f = widget.fields;
    final rows = <(_Field, String, String, String?)>[
      if (f.age != null)
        (_Field.age, s.aiFieldAge, s.aiAgeYears(f.age!), s.aiDictationAgeNote),
      if (f.sex != null)
        (_Field.sex, s.aiFieldSex, aiSexLabel(context, f.sex), null),
      if (f.pathologies.isNotEmpty)
        (
          _Field.pathologies,
          s.aiFieldPathologies,
          f.pathologies.join(', '),
          null,
        ),
      if (f.notes.trim().isNotEmpty)
        (_Field.notes, s.aiFieldNotes, f.notes.trim(), null),
    ];
    return Column(
      key: const ValueKey('proposal'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClxAiReveal(
          child: ClxAiSurface(
            padding: const EdgeInsets.all(ClxSpace.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AiCardHeader(title: s.aiDictationProposal),
                const SizedBox(height: ClxSpace.s1),
                Text(s.aiDictationProposalHint, style: context.clxText.bodySm),
                const SizedBox(height: ClxSpace.s3),
                if (rows.isEmpty)
                  Text(s.aiDictationNothing, style: context.clxText.bodyMuted)
                else
                  for (var i = 0; i < rows.length; i++)
                    ClxAiReveal(
                      index: i + 1,
                      child: _ProposalRow(
                        key: ValueKey('ai_dictation_field_${rows[i].$1.name}'),
                        label: rows[i].$2,
                        value: rows[i].$3,
                        note: rows[i].$4,
                        selected: _selected.contains(rows[i].$1),
                        onTap: () => _toggle(rows[i].$1),
                      ),
                    ),
              ],
            ),
          ),
        ),
        for (final w in f.warnings) ...[
          const SizedBox(height: ClxSpace.s3),
          ClxNotice(tone: ClxTone.warning, message: w),
        ],
        const SizedBox(height: ClxSpace.s3),
        const ClxAiDisclaimer(),
        const SizedBox(height: ClxSpace.s4),
        ClxAiButton(
          key: const Key('ai_dictation_apply'),
          label: s.aiDictationApply,
          icon: LucideIcons.check,
          onPressed: _selected.isEmpty
              ? null
              : () => Navigator.of(context).pop(_result()),
        ),
        const SizedBox(height: ClxSpace.s2),
        Center(
          child: ClxButton.ghost(
            label: s.aiDictationTryAgain,
            icon: LucideIcons.mic,
            onPressed: context.read<DictationCubit>().start,
          ),
        ),
      ],
    );
  }
}

class _ProposalRow extends StatelessWidget {
  const _ProposalRow({
    super.key,
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
    this.note,
  });

  final String label;
  final String value;
  final String? note;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final t = context.clxText;
    return Semantics(
      checked: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ClxRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: ClxSpace.s2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: selected ? c.accentViolet : Colors.transparent,
                  borderRadius: BorderRadius.circular(ClxRadius.sm),
                  border: Border.all(
                    color: selected ? c.accentViolet : c.borderStrong,
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? const Icon(
                        LucideIcons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: ClxSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label.toUpperCase(), style: t.label),
                    const SizedBox(height: 2),
                    Text(value, style: t.body),
                    if (note != null) ...[
                      const SizedBox(height: 2),
                      Text(note!, style: t.bodySm.copyWith(fontSize: 12.5)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
