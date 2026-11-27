import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/data/models/ai_models.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/ai_request_state.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/rejection_feedback_cubit.dart';
import 'package:clinexa_derivant_app/presentation/ai/widgets/ai_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// IA-07 · "Consejos para tus derivaciones" en Mis pacientes. Necesita un
/// [RejectionFeedbackCubit] arriba; la consulta se hace una sola vez.
class RejectionFeedbackCard extends StatefulWidget {
  const RejectionFeedbackCard({super.key});

  @override
  State<RejectionFeedbackCard> createState() => _RejectionFeedbackCardState();
}

class _RejectionFeedbackCardState extends State<RejectionFeedbackCard> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<RejectionFeedbackCubit>();
    if (cubit.state.status == AiRequestStatus.idle) cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocBuilder<
      RejectionFeedbackCubit,
      AiRequestState<RejectionFeedback>
    >(
      builder: (context, state) {
        final Widget child = switch (state.status) {
          AiRequestStatus.idle || AiRequestStatus.loading => ClxAiThinking(
            key: const Key('ai_rejections_thinking'),
            title: s.aiRejectionsTitle,
            messages: [s.aiRejectionsThinking1, s.aiRejectionsThinking2],
          ),
          AiRequestStatus.failure => AiErrorNotice(
            key: const Key('ai_rejections_error'),
            error: state.error,
            onRetry: context.read<RejectionFeedbackCubit>().load,
          ),
          AiRequestStatus.success =>
            state.data!.total == 0
                ? _AllGood(
                    key: const Key('ai_rejections_none'),
                    summary: state.data!.summary,
                  )
                : _Feedback(
                    key: const Key('ai_rejections_result'),
                    data: state.data!,
                    expanded: _expanded,
                    onToggle: () => setState(() => _expanded = !_expanded),
                  ),
        };
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: child,
        );
      },
    );
  }
}

class _AllGood extends StatelessWidget {
  const _AllGood({super.key, required this.summary});
  final String summary;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.clx;
    final t = context.clxText;
    return ClxAiReveal(
      child: ClxAiSurface(
        glow: false,
        padding: const EdgeInsets.all(ClxSpace.s4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c.successSoft,
                borderRadius: BorderRadius.circular(ClxRadius.md),
              ),
              child: Icon(LucideIcons.thumbsUp, size: 18, color: c.success),
            ),
            const SizedBox(width: ClxSpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClxAiText(s.aiRejectionsNoneTitle, style: t.h3),
                  const SizedBox(height: 2),
                  Text(
                    summary.isEmpty ? s.aiRejectionsNoneMessage : summary,
                    style: t.bodySm,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({
    super.key,
    required this.data,
    required this.expanded,
    required this.onToggle,
  });

  final RejectionFeedback data;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.clx;
    final t = context.clxText;
    return ClxAiReveal(
      child: ClxAiSurface(
        padding: const EdgeInsets.all(ClxSpace.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AiCardHeader(
              title: s.aiRejectionsTitle,
              trailing: ClxBadge(
                label: s.aiRejectionsCount(data.total),
                tone: ClxTone.danger,
              ),
            ),
            const SizedBox(height: ClxSpace.s1),
            Text(s.aiRejectionsPeriod, style: t.bodySm.copyWith(fontSize: 12)),
            const SizedBox(height: ClxSpace.s3),
            Text(
              data.summary,
              style: t.body,
              maxLines: expanded ? null : 3,
              overflow: expanded ? null : TextOverflow.ellipsis,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              alignment: Alignment.topCenter,
              child: !expanded
                  ? const SizedBox(width: double.infinity)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: ClxSpace.s4),
                        for (var i = 0; i < data.categories.length; i++)
                          ClxAiReveal(
                            index: i,
                            child: _Category(category: data.categories[i]),
                          ),
                        const SizedBox(height: ClxSpace.s1),
                        ClxAiDisclaimer(text: s.aiDisclaimer),
                      ],
                    ),
            ),
            const SizedBox(height: ClxSpace.s2),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const Key('ai_rejections_toggle'),
                onPressed: onToggle,
                style: TextButton.styleFrom(
                  foregroundColor: c.accentViolet,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 36),
                ),
                icon: Icon(
                  expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                  size: 16,
                ),
                label: Text(
                  expanded
                      ? s.aiRejectionsShowLess
                      : s.aiRejectionsShowMore(data.categories.length),
                  style: t.bodySmStrong.copyWith(
                    color: c.accentViolet,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Category extends StatelessWidget {
  const _Category({required this.category});
  final RejectionCategory category;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.clx;
    final t = context.clxText;
    return Container(
      margin: const EdgeInsets.only(bottom: ClxSpace.s3),
      padding: const EdgeInsets.all(ClxSpace.s3),
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: BorderRadius.circular(ClxRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(category.name, style: t.bodyStrong)),
              const SizedBox(width: ClxSpace.s2),
              ClxBadge(label: s.aiRejectionsCount(category.count)),
            ],
          ),
          if (category.protocols.isNotEmpty) ...[
            const SizedBox(height: ClxSpace.s1),
            Text(
              s.aiRejectionsProtocols(category.protocols.join(', ')),
              style: t.bodySm,
            ),
          ],
          if (category.recommendation.isNotEmpty) ...[
            const SizedBox(height: ClxSpace.s2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    LucideIcons.lightbulb,
                    size: 15,
                    color: c.accentViolet,
                  ),
                ),
                const SizedBox(width: ClxSpace.s2),
                Expanded(
                  child: Text(
                    category.recommendation,
                    style: t.bodySm.copyWith(color: c.ink),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
