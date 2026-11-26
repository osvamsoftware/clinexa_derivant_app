import 'package:clinexa_derivant_app/data/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/core/helpers/localization_helper.dart';
import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/presentation/notifications/screens/notifications_screen.dart';

class NotificationDetailScreen extends StatelessWidget {
  static const String path = '/notifications/detail';
  final NotificationModel notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final dateStr = DateFormat('dd MMM yyyy · HH:mm', locale).format(notification.createdAt);

    final s = S.of(context);
    final c = context.clx;
    final t = context.clxText;
    final translatedTitle = LocalizationHelper.translateNotificationKey(
      s,
      notification.title,
      notification.data,
    );
    final translatedBody = LocalizationHelper.translateNotificationKey(
      s,
      notification.body,
      notification.data,
    );
    final (icon, tone) = notificationVisual(notification);
    final (bg, fg) = toneColors(context, tone);

    // Datos legibles: se omiten los identificadores internos.
    final details = notification.data.entries
        .where((e) => e.value != null && e.value.toString().isNotEmpty)
        .where((e) => !e.key.toLowerCase().endsWith('id'))
        .toList();

    return Scaffold(
      appBar: ClxAppBar(title: s.notificationDetailTitle),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(ClxSpace.s4, ClxSpace.s6, ClxSpace.s4, ClxSpace.s8),
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(ClxRadius.lg)),
            child: Icon(icon, size: 24, color: fg),
          ),
          const SizedBox(height: ClxSpace.s4),
          Text(translatedTitle, style: t.h1),
          const SizedBox(height: ClxSpace.s2),
          Row(
            children: [
              Icon(LucideIcons.clock, size: 14, color: c.inkSubtle),
              const SizedBox(width: ClxSpace.s1 + 2),
              Text(dateStr, style: t.data.copyWith(fontSize: 13, color: c.inkSubtle)),
            ],
          ),
          const SizedBox(height: ClxSpace.s6),
          ClxCard(child: Text(translatedBody, style: t.body)),
          if (details.isNotEmpty) ...[
            const SizedBox(height: ClxSpace.s8),
            Padding(
              padding: const EdgeInsets.only(left: ClxSpace.s1, bottom: ClxSpace.s2),
              child: Text(s.notificationDetails.toUpperCase(), style: t.label),
            ),
            ClxCard(
              padding: const EdgeInsets.symmetric(horizontal: ClxSpace.s4, vertical: ClxSpace.s2),
              child: Column(
                children: [
                  for (var i = 0; i < details.length; i++) ...[
                    ClxKeyValue(
                      label: _humanize(details[i].key),
                      value: details[i].value.toString(),
                    ),
                    if (i < details.length - 1) Divider(height: 1, color: c.border),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _humanize(String key) {
    final text = key.replaceAll('_', ' ').trim();
    if (text.isEmpty) return key;
    return text[0].toUpperCase() + text.substring(1);
  }
}
