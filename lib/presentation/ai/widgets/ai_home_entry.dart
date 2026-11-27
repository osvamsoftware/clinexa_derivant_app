import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/ai/screens/protocol_suggestion_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Entrada destacada de Inicio (IA-03): "Describe tu caso y te sugiero
/// protocolos", por texto o por dictado.
class AiHomeEntry extends StatelessWidget {
  const AiHomeEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final t = context.clxText;
    return ClxAiSurface(
      key: const Key('ai_home_entry'),
      padding: const EdgeInsets.all(ClxSpace.s4),
      onTap: () => context.push(ProtocolSuggestionScreen.path),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: ClxAiSpark(size: 22),
              ),
              const SizedBox(width: ClxSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClxAiText(s.aiSuggestEntryTitle, style: t.h3, maxLines: 2),
                    const SizedBox(height: 2),
                    Text(
                      s.aiSuggestEntrySubtitle,
                      style: t.bodySm,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ClxSpace.s3),
          Row(
            children: [
              Expanded(
                child: ClxAiButton(
                  key: const Key('ai_home_describe'),
                  label: s.aiSuggestEntryAction,
                  icon: LucideIcons.wandSparkles,
                  compact: true,
                  onPressed: () => context.push(ProtocolSuggestionScreen.path),
                ),
              ),
              const SizedBox(width: ClxSpace.s2),
              ClxAiIconButton(
                key: const Key('ai_home_dictate'),
                icon: LucideIcons.mic,
                tooltip: s.aiDictate,
                size: 40,
                onPressed: () =>
                    context.push(ProtocolSuggestionScreen.path, extra: true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
