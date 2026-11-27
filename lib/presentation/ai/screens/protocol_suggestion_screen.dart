import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/data/models/ai_models.dart';
import 'package:clinexa_derivant_app/domain/ai_repository.dart';
import 'package:clinexa_derivant_app/domain/protocol_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/ai_request_state.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/protocol_suggestion_cubit.dart';
import 'package:clinexa_derivant_app/presentation/ai/widgets/ai_common.dart';
import 'package:clinexa_derivant_app/presentation/ai/widgets/dictation_sheet.dart';
import 'package:clinexa_derivant_app/presentation/protocol/protocol_criteria_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// IA-03 · "Describe tu caso y te sugiero protocolos". Al tocar una
/// sugerencia se abre el flujo de derivación de siempre para ese protocolo.
class ProtocolSuggestionScreen extends StatelessWidget {
  static const path = '/ai/suggest-protocols';

  const ProtocolSuggestionScreen({super.key, this.startWithDictation = false});

  /// Abre el dictado apenas se muestra la pantalla.
  final bool startWithDictation;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProtocolSuggestionCubit(context.read<AiRepository>()),
      child: ProtocolSuggestionView(startWithDictation: startWithDictation),
    );
  }
}

class ProtocolSuggestionView extends StatefulWidget {
  const ProtocolSuggestionView({super.key, this.startWithDictation = false});

  final bool startWithDictation;

  @override
  State<ProtocolSuggestionView> createState() => _ProtocolSuggestionViewState();
}

class _ProtocolSuggestionViewState extends State<ProtocolSuggestionView> {
  final _controller = TextEditingController();
  String? _opening;

  @override
  void initState() {
    super.initState();
    if (widget.startWithDictation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _dictate();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dictate() async {
    final text = await showTranscriptionSheet(context);
    if (text == null || !mounted) return;
    final current = _controller.text.trim();
    final joined = current.isEmpty ? text : '$current $text';
    // El backend admite hasta 1000 caracteres.
    _controller.text = joined.length > 1000
        ? joined.substring(0, 1000)
        : joined;
    setState(() {});
  }

  void _suggest() {
    FocusManager.instance.primaryFocus?.unfocus();
    context.read<ProtocolSuggestionCubit>().suggest(_controller.text);
  }

  Future<void> _open(ProtocolSuggestion suggestion) async {
    if (_opening != null) return;
    setState(() => _opening = suggestion.protocolId);
    final s = S.of(context);
    try {
      final protocol = await context.read<ProtocolRepository>().getProtocolById(
        suggestion.protocolId,
      );
      if (!mounted) return;
      context.pushNamed(ProtocolCriteriaScreen.path, extra: protocol);
    } catch (_) {
      if (mounted) ClxToast.error(context, s.aiSuggestOpenError);
    } finally {
      if (mounted) setState(() => _opening = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final t = context.clxText;
    return Scaffold(
      appBar: ClxAppBar(title: s.aiSuggestTitle),
      body:
          BlocBuilder<
            ProtocolSuggestionCubit,
            AiRequestState<ProtocolSuggestions>
          >(
            builder: (context, state) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  ClxSpace.s4,
                  ClxSpace.s5,
                  ClxSpace.s4,
                  ClxSpace.s8,
                ),
                children: [
                  ClxAiText(s.aiSuggestEntryTitle, style: t.h1),
                  const SizedBox(height: ClxSpace.s2),
                  Text(s.aiSuggestEntrySubtitle, style: t.bodyMuted),
                  const SizedBox(height: ClxSpace.s5),
                  ClxTextField(
                    key: const Key('ai_suggest_field'),
                    label: s.aiSuggestFieldLabel,
                    hint: s.aiSuggestFieldHint,
                    controller: _controller,
                    minLines: 4,
                    maxLines: 8,
                    maxLength: 1000,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: ClxSpace.s2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClxAiDisclaimer(text: s.aiSuggestPrivacy),
                      ),
                    ],
                  ),
                  const SizedBox(height: ClxSpace.s4),
                  Row(
                    children: [
                      ClxAiIconButton(
                        key: const Key('ai_suggest_dictate'),
                        icon: LucideIcons.mic,
                        tooltip: s.aiDictate,
                        size: 52,
                        onPressed: state.isLoading ? null : _dictate,
                      ),
                      const SizedBox(width: ClxSpace.s3),
                      Expanded(
                        child: ClxAiButton(
                          key: const Key('ai_suggest_submit'),
                          label: s.aiSuggestAction,
                          icon: LucideIcons.wandSparkles,
                          loading: state.isLoading,
                          loadingLabel: s.aiSuggestLoading,
                          onPressed: _controller.text.trim().length < 5
                              ? null
                              : _suggest,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ClxSpace.s6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: switch (state.status) {
                      AiRequestStatus.idle => const SizedBox.shrink(),
                      AiRequestStatus.loading => ClxAiThinking(
                        key: const Key('ai_suggest_thinking'),
                        title: s.aiThinkingTitle,
                        messages: [
                          s.aiSuggestThinking1,
                          s.aiSuggestThinking2,
                          s.aiSuggestThinking3,
                        ],
                      ),
                      AiRequestStatus.failure => AiErrorNotice(
                        error: state.error,
                        onRetry: _suggest,
                      ),
                      AiRequestStatus.success => _Results(
                        key: ValueKey(state.data),
                        result: state.data!,
                        opening: _opening,
                        onOpen: _open,
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

class _Results extends StatelessWidget {
  const _Results({
    super.key,
    required this.result,
    required this.opening,
    required this.onOpen,
  });

  final ProtocolSuggestions result;
  final String? opening;
  final ValueChanged<ProtocolSuggestion> onOpen;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final t = context.clxText;
    return Column(
      key: const Key('ai_suggest_results'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(s.aiSuggestResultsTitle, style: t.h2)),
            ClxAiTag(label: s.aiSuggestedTag),
          ],
        ),
        const SizedBox(height: ClxSpace.s3),
        if (result.suggestions.isEmpty)
          ClxNotice(
            tone: ClxTone.info,
            icon: LucideIcons.searchX,
            message: s.aiSuggestEmpty,
          )
        else
          for (var i = 0; i < result.suggestions.length; i++) ...[
            ClxAiReveal(
              index: i,
              child: _SuggestionCard(
                key: ValueKey('ai_suggestion_$i'),
                suggestion: result.suggestions[i],
                opening: opening == result.suggestions[i].protocolId,
                onTap: () => onOpen(result.suggestions[i]),
              ),
            ),
            const SizedBox(height: ClxSpace.s3),
          ],
        if (result.note.isNotEmpty) ...[
          const SizedBox(height: ClxSpace.s1),
          ClxNotice(tone: ClxTone.info, message: result.note),
          const SizedBox(height: ClxSpace.s3),
        ],
        ClxAiDisclaimer(text: s.aiDisclaimer),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    super.key,
    required this.suggestion,
    required this.opening,
    required this.onTap,
  });

  final ProtocolSuggestion suggestion;
  final bool opening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.clx;
    final t = context.clxText;
    final tags = {
      ...suggestion.specialties,
      ...suggestion.pathologies,
    }.take(3).toList();
    return ClxAiSurface(
      glow: false,
      padding: const EdgeInsets.all(ClxSpace.s4),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClxAiScore(
                score: suggestion.score,
                size: 60,
                label: s.aiFitLabel,
              ),
              const SizedBox(width: ClxSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(suggestion.name, style: t.h3),
                    const SizedBox(height: ClxSpace.s1),
                    Text(suggestion.reason, style: t.bodySm),
                  ],
                ),
              ),
            ],
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: ClxSpace.s3),
            Wrap(
              spacing: ClxSpace.s2,
              runSpacing: ClxSpace.s2,
              children: [for (final tag in tags) ClxBadge(label: tag)],
            ),
          ],
          const SizedBox(height: ClxSpace.s3),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (opening)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: ClxLoader(size: 18),
                )
              else ...[
                Text(
                  s.aiSuggestOpen,
                  style: t.bodySmStrong.copyWith(color: c.brandBlue),
                ),
                const SizedBox(width: ClxSpace.s1),
                Icon(LucideIcons.arrowRight, size: 16, color: c.brandBlue),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
