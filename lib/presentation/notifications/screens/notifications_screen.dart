import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/data/models/notification_model.dart';
import 'package:clinexa_derivant_app/presentation/notifications/cubit/notifications_cubit.dart';
import 'package:clinexa_derivant_app/presentation/notifications/cubit/notifications_state.dart';
import 'package:clinexa_derivant_app/domain/repositories/notification_repository.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/cubit/auth_cubit.dart';
import 'package:clinexa_derivant_app/presentation/notifications/screens/notification_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:developer';

import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/core/helpers/localization_helper.dart';

class NotificationsScreen extends StatelessWidget {
  static const String path = '/notifications';

  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final authState = context.read<AuthCubit>().state;
        final userId = authState.user?.id;

        final cubit = NotificationsCubit(
          context.read<NotificationRepository>(),
        );

        if (userId != null) {
          cubit.fetchNotifications(userId);
        }
        return cubit;
      },
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final authState = context.read<AuthCubit>().state;
      final userId = authState.user?.id;
      if (userId != null) {
        context.read<NotificationsCubit>().fetchNotifications(userId);
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _onRefresh() async {
    final userId = context.read<AuthCubit>().state.user?.id;
    if (userId != null) {
      await context.read<NotificationsCubit>().fetchNotifications(
        userId,
        refresh: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      appBar: ClxAppBar(title: s.notificationScreenTitle),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state.status == NotificationsStatus.initial ||
              (state.status == NotificationsStatus.loading &&
                  state.notifications.isEmpty)) {
            return const ClxSkeletonList(count: 6);
          }

          if (state.status == NotificationsStatus.failure &&
              state.notifications.isEmpty) {
            return ClxEmptyState(
              icon: LucideIcons.circleAlert,
              tone: ClxTone.danger,
              title: s.errorLoadingNotifications,
              message: s.errorNetwork,
              actionLabel: s.retry,
              onAction: _onRefresh,
            );
          }

          if (state.notifications.isEmpty) {
            return ClxEmptyState(
              icon: LucideIcons.bellOff,
              title: s.noNotificationsFound,
              message: s.noNotificationsHint,
            );
          }

          return RefreshIndicator(
            color: context.clx.brandBlue,
            onRefresh: _onRefresh,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(ClxSpace.s4, ClxSpace.s4, ClxSpace.s4, ClxSpace.s6),
              itemCount:
                  state.notifications.length + (state.hasReachedMax ? 0 : 1),
              separatorBuilder: (_, __) => const SizedBox(height: ClxSpace.s3),
              itemBuilder: (context, index) {
                if (index >= state.notifications.length) {
                  return const Padding(
                    padding: EdgeInsets.all(ClxSpace.s4),
                    child: ClxLoader(size: 22),
                  );
                }

                final notification = state.notifications[index];
                return _NotificationCard(
                  key: ValueKey('notification_card_$index'),
                  notification: notification,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Ícono y tono de una notificación según su tipo (un estado = un color).
(IconData, ClxTone) notificationVisual(NotificationModel n) {
  final key = '${n.typeNotification} ${n.title}'.toLowerCase();
  if (key.contains('rejected')) return (LucideIcons.circleX, ClxTone.danger);
  if (key.contains('accepted')) return (LucideIcons.circleCheck, ClxTone.success);
  if (key.contains('taken')) return (LucideIcons.userCheck, ClxTone.info);
  if (key.contains('assigned')) return (LucideIcons.send, ClxTone.info);
  if (key.contains('prospect')) return (LucideIcons.userPlus, ClxTone.info);
  return (LucideIcons.bell, ClxTone.neutral);
}

/// Colores de fondo y texto de un tono (para el cuadro del ícono).
(Color, Color) toneColors(BuildContext context, ClxTone tone) {
  final c = context.clx;
  return switch (tone) {
    ClxTone.success => (c.successSoft, c.success),
    ClxTone.danger => (c.dangerSoft, c.danger),
    ClxTone.warning => (c.warningSoft, c.warning),
    ClxTone.info => (c.brandBlueSoft, c.onBrandBlueSoft),
    ClxTone.ai => (c.accentVioletSoft, c.accentViolet),
    ClxTone.neutral => (c.surfaceSunken, c.inkMuted),
  };
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final t = context.clxText;
    final s = S.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateStr = DateFormat('dd MMM yyyy · HH:mm', locale).format(notification.createdAt);

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

    return ClxCard(
      padding: const EdgeInsets.all(ClxSpace.s4),
      borderColor: notification.isRead ? null : c.brandBlue.withValues(alpha: 0.45),
      onTap: () {
        log(
          'Tap en notificación tipo: ${notification.typeNotification}',
          name: 'NotificationsScreen',
        );
        context.push(NotificationDetailScreen.path, extra: notification);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(ClxRadius.md)),
            child: Icon(icon, size: 18, color: fg),
          ),
          const SizedBox(width: ClxSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        translatedTitle,
                        style: notification.isRead ? t.body : t.bodyStrong,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!notification.isRead) ...[
                      const SizedBox(width: ClxSpace.s2),
                      ClxBadge(label: s.unread, tone: ClxTone.info),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  translatedBody,
                  style: t.bodySm,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: ClxSpace.s2),
                Text(dateStr, style: t.data.copyWith(fontSize: 12, color: c.inkSubtle)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
