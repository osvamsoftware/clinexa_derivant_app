import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/cubit/auth_cubit.dart';
import 'package:clinexa_derivant_app/presentation/notifications/screens/notifications_screen.dart';
import 'package:clinexa_derivant_app/presentation/profile/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Cabecera de Inicio: saludo con avatar de iniciales y accesos a
/// notificaciones y perfil. Fondo `surface`, sin degradado (el degradado
/// queda para las pantallas públicas).
class HomeHeader extends StatelessWidget {
  final String name;

  const HomeHeader({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final t = context.clxText;
    final s = S.of(context);

    return Container(
      width: double.infinity,
      color: c.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(ClxSpace.s4, ClxSpace.s3, ClxSpace.s4, ClxSpace.s2),
          child: Row(
            children: [
              ClxAvatar(name: name, size: 44),
              const SizedBox(width: ClxSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.homeWelcomeBack, style: t.bodySm, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(name, style: t.h2, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: ClxSpace.s2),
              ClxIconButton(
                key: const Key('home_notifications_button'),
                icon: LucideIcons.bell,
                tooltip: s.notificationScreenTitle,
                filled: true,
                onPressed: () => context.push(NotificationsScreen.path),
              ),
              const SizedBox(width: ClxSpace.s2),
              ClxIconButton(
                key: const Key('home_profile_button'),
                icon: LucideIcons.userRound,
                tooltip: s.myProfile,
                filled: true,
                onPressed: () {
                  final user = context.read<AuthCubit>().state.user;
                  if (user != null) {
                    context.push(EditProfileScreen.path, extra: user);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
