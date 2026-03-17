import 'package:clinexa_derivant_app/core/constants/paths.dart';
import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/cubit/auth_cubit.dart';

import 'package:clinexa_derivant_app/presentation/notifications/screens/notifications_screen.dart';
import 'package:clinexa_derivant_app/presentation/profile/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeHeader extends StatelessWidget {
  final String name;

  const HomeHeader({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      width: double.infinity,
      color: AppColors.primary10, // Background color
      child: SafeArea(
        // Ensure content safe area
        bottom: false,
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage(paths.iconLogoPng),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.homeWelcomeBack,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70, // Lighter white/transparent
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Icons
            _circleIcon(
              Icons.person_outline,
              onTap: () {
                final user = context.read<AuthCubit>().state.user;
                if (user != null) {
                  context.push(EditProfileScreen.path, extra: user);
                }
              },
            ),

            const SizedBox(width: 10),
            _circleIcon(
              Icons.notifications_none,
              onTap: () {
                context.push(NotificationsScreen.path);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Bubble icon widget
  Widget _circleIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: AppColors.primary30.withOpacity(
            0.3,
          ), // Darker tone for button bg
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white), // White icon
      ),
    );
  }
}
