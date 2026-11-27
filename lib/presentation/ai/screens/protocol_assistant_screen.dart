import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/data/models/ai_models.dart';
import 'package:clinexa_derivant_app/domain/ai_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/assistant_cubit.dart';
import 'package:clinexa_derivant_app/presentation/ai/widgets/ai_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Protocolo desde el que se abre el asistente (opcional).
class AssistantArgs {
  const AssistantArgs({required this.protocolId, required this.protocolName});
  final String protocolId;
  final String protocolName;
}

/// IA-09 · Asistente de protocolos: responde dudas con los datos de los
/// protocolos activos, con fuentes y preguntas sugeridas. La conversación
/// queda solo en el teléfono mientras la pantalla está abierta.
class ProtocolAssistantScreen extends StatelessWidget {
  static const path = '/ai/assistant';

  const ProtocolAssistantScreen({super.key, this.args});

  final AssistantArgs? args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AssistantCubit(
        context.read<AiRepository>(),
        protocolId: args?.protocolId,
      ),
      child: ProtocolAssistantView(args: args),
    );
  }
}

class ProtocolAssistantView extends StatefulWidget {
  const ProtocolAssistantView({super.key, this.args});

  final AssistantArgs? args;

  @override
  State<ProtocolAssistantView> createState() => _ProtocolAssistantViewState();
}

class _ProtocolAssistantViewState extends State<ProtocolAssistantView> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  /// Respuestas que ya se escribieron (no se vuelven a animar).
  final Set<int> _typed = {};

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final q = (text ?? _input.text).trim();
    if (q.isEmpty) return;
    _input.clear();
    setState(() {});
    context.read<AssistantCubit>().ask(q);
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
      final target = _scroll.position.maxScrollExtent;
      if (reduce) {
        _scroll.jumpTo(target);
      } else {
        _scroll.animateTo(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: ClxAppBar(
        title: s.aiAssistantTitle,
        actions: [
          BlocBuilder<AssistantCubit, AssistantState>(
            builder: (context, state) => state.messages.isEmpty
                ? const SizedBox.shrink()
                : ClxIconButton(
                    key: const Key('ai_assistant_clear'),
                    icon: LucideIcons.messageCirclePlus,
                    tooltip: s.aiAssistantClear,
                    onPressed: () {
                      _typed.clear();
                      context.read<AssistantCubit>().clear();
                    },
                  ),
          ),
          const SizedBox(width: ClxSpace.s2),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<AssistantCubit, AssistantState>(
              listener: (context, state) => _scrollToEnd(),
              builder: (context, state) {
                if (state.messages.isEmpty && !state.loading) {
                  return _Welcome(args: widget.args, onAsk: _send);
                }
                final lastAssistant = state.messages.lastIndexWhere(
                  (m) => !m.fromUser,
                );
                return ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(
                    ClxSpace.s4,
                    ClxSpace.s4,
                    ClxSpace.s4,
                    ClxSpace.s6,
                  ),
                  children: [
                    if (widget.args != null) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ClxBadge(
                          label: s.aiAssistantAbout(widget.args!.protocolName),
                          tone: ClxTone.info,
                          icon: LucideIcons.clipboardList,
                        ),
                      ),
                      const SizedBox(height: ClxSpace.s4),
                    ],
                    for (var i = 0; i < state.messages.length; i++) ...[
                      if (state.messages[i].fromUser)
                        _UserBubble(text: state.messages[i].content)
                      else
                        _AnswerBubble(
                          key: ValueKey('ai_answer_${state.messages[i].id}'),
                          message: state.messages[i],
                          animate: !_typed.contains(state.messages[i].id),
                          isLast: i == lastAssistant && !state.loading,
                          onTyped: () => _typed.add(state.messages[i].id),
                          onAsk: _send,
                        ),
                      const SizedBox(height: ClxSpace.s4),
                    ],
                    if (state.loading)
                      ClxAiThinking(
                        key: const Key('ai_assistant_thinking'),
                        title: s.aiThinkingTitle,
                        messages: [
                          s.aiAssistantThinking1,
                          s.aiAssistantThinking2,
                          s.aiAssistantThinking3,
                        ],
                      ),
                    if (state.error != null)
                      AiErrorNotice(
                        error: state.error,
                        onRetry: context.read<AssistantCubit>().retry,
                      ),
                  ],
                );
              },
            ),
          ),
          _Composer(
            controller: _input,
            onSend: _send,
            onChanged: () => setState(() {}),
          ),
        ],
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.args, required this.onAsk});

  final AssistantArgs? args;
  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final t = context.clxText;
    final starters = args == null
        ? [s.aiAssistantStarter1, s.aiAssistantStarter2, s.aiAssistantStarter3]
        : [
            s.aiAssistantProtocolStarter1,
            s.aiAssistantProtocolStarter2,
            s.aiAssistantProtocolStarter3,
          ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        ClxSpace.s4,
        ClxSpace.s5,
        ClxSpace.s4,
        ClxSpace.s6,
      ),
      children: [
        ClxAiReveal(
          child: ClxAiSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ClxAiSpark(size: 28),
                const SizedBox(height: ClxSpace.s3),
                ClxAiText(s.aiAssistantTitle, style: t.h2),
                const SizedBox(height: ClxSpace.s2),
                Text(
                  args == null
                      ? s.aiAssistantIntro
                      : s.aiAssistantIntroProtocol(args!.protocolName),
                  style: t.bodyMuted,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: ClxSpace.s5),
        Text(s.aiAssistantSuggested.toUpperCase(), style: t.label),
        const SizedBox(height: ClxSpace.s3),
        for (var i = 0; i < starters.length; i++) ...[
          ClxAiReveal(
            index: i + 1,
            child: _QuestionChip(
              key: ValueKey('ai_assistant_starter_$i'),
              text: starters[i],
              onTap: () => onAsk(starters[i]),
            ),
          ),
          const SizedBox(height: ClxSpace.s2),
        ],
        const SizedBox(height: ClxSpace.s3),
        ClxAiDisclaimer(text: s.aiAssistantPrivacy),
      ],
    );
  }
}

class _QuestionChip extends StatelessWidget {
  const _QuestionChip({super.key, required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  // Misma píldora que en la app Investigador.
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: ClxAiSuggestion(label: text, onTap: onTap),
  );
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ClxSpace.s4,
            vertical: ClxSpace.s3,
          ),
          decoration: BoxDecoration(
            color: c.brandBlue,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(ClxRadius.lg),
              topRight: Radius.circular(ClxRadius.lg),
              bottomLeft: Radius.circular(ClxRadius.lg),
              bottomRight: Radius.circular(ClxRadius.sm),
            ),
          ),
          child: Text(
            text,
            style: context.clxText.body.copyWith(color: c.onBrand),
          ),
        ),
      ),
    );
  }
}

class _AnswerBubble extends StatefulWidget {
  const _AnswerBubble({
    super.key,
    required this.message,
    required this.animate,
    required this.isLast,
    required this.onTyped,
    required this.onAsk,
  });

  final AssistantMessage message;
  final bool animate;
  final bool isLast;
  final VoidCallback onTyped;
  final ValueChanged<String> onAsk;

  @override
  State<_AnswerBubble> createState() => _AnswerBubbleState();
}

class _AnswerBubbleState extends State<_AnswerBubble> {
  late bool _done = !widget.animate;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final t = context.clxText;
    final m = widget.message;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClxAiSurface(
          glow: widget.isLast,
          padding: const EdgeInsets.all(ClxSpace.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ClxAiSpark(size: 16),
                  const SizedBox(width: ClxSpace.s2),
                  Text(
                    s.aiAssistantName,
                    style: t.bodySmStrong.copyWith(
                      color: context.clx.accentViolet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ClxSpace.s2),
              ClxAiTypewriter(
                m.content,
                animate: widget.animate,
                onDone: () {
                  widget.onTyped();
                  if (mounted && !_done) setState(() => _done = true);
                },
              ),
              if (_done && m.sources.isNotEmpty) ...[
                const SizedBox(height: ClxSpace.s4),
                Text(s.aiAssistantSources.toUpperCase(), style: t.label),
                const SizedBox(height: ClxSpace.s2),
                for (var i = 0; i < m.sources.length; i++)
                  ClxAiReveal(
                    index: i,
                    child: _Source(source: m.sources[i]),
                  ),
              ],
            ],
          ),
        ),
        if (_done && widget.isLast) ...[
          if (m.followUps.isNotEmpty) ...[
            const SizedBox(height: ClxSpace.s3),
            for (var i = 0; i < m.followUps.length; i++) ...[
              ClxAiReveal(
                index: i + 1,
                child: _QuestionChip(
                  key: ValueKey('ai_assistant_followup_$i'),
                  text: m.followUps[i],
                  onTap: () => widget.onAsk(m.followUps[i]),
                ),
              ),
              const SizedBox(height: ClxSpace.s2),
            ],
          ],
          const SizedBox(height: ClxSpace.s2),
          ClxAiDisclaimer(text: s.aiDisclaimer),
        ],
      ],
    );
  }
}

class _Source extends StatelessWidget {
  const _Source({required this.source});
  final AssistantSource source;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final t = context.clxText;
    return Container(
      margin: const EdgeInsets.only(bottom: ClxSpace.s2),
      padding: const EdgeInsets.all(ClxSpace.s3),
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: BorderRadius.circular(ClxRadius.md),
        border: Border(left: BorderSide(color: c.accentViolet, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.clipboardList, size: 14, color: c.inkMuted),
              const SizedBox(width: ClxSpace.s2),
              Expanded(child: Text(source.protocolName, style: t.bodySmStrong)),
            ],
          ),
          if (source.excerpt.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('“${source.excerpt}”', style: t.bodySm),
          ],
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.onSend,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String?> onSend;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.clx;
    return BlocBuilder<AssistantCubit, AssistantState>(
      buildWhen: (a, b) => a.loading != b.loading,
      builder: (context, state) {
        final canSend = controller.text.trim().length >= 3 && !state.loading;
        return Container(
          decoration: BoxDecoration(
            color: c.surfaceRaised,
            border: Border(top: BorderSide(color: c.border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                ClxSpace.s4,
                ClxSpace.s3,
                ClxSpace.s4,
                ClxSpace.s3,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: ClxTextField(
                      key: const Key('ai_assistant_input'),
                      hint: s.aiAssistantHint,
                      controller: controller,
                      minLines: 1,
                      maxLines: 4,
                      // La pregunta admite hasta 500 caracteres.
                      inputFormatters: [LengthLimitingTextInputFormatter(500)],
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                      onChanged: (_) => onChanged(),
                      onSubmitted: canSend ? (v) => onSend(v) : null,
                    ),
                  ),
                  const SizedBox(width: ClxSpace.s2),
                  Opacity(
                    opacity: canSend ? 1 : 0.45,
                    child: ClxAiIconButton(
                      key: const Key('ai_assistant_send'),
                      icon: LucideIcons.arrowUp,
                      tooltip: s.aiAssistantSend,
                      size: 48,
                      onPressed: canSend ? () => onSend(null) : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
