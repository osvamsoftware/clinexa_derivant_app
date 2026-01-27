import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/cubit/auth_cubit.dart';
import 'package:clinexa_derivant_app/presentation/login/login_screen.dart';
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

    return Row(
      children: [
        // Avatar
        const CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(
            "https://images.unsplash.com/photo-1500648767791-00dcc994a43e",
          ),
        ),

        const SizedBox(width: 14),

        // Textos
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.homeWelcomeBack,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.blue.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const Spacer(),

        // Icons
        _circleIcon(Icons.notifications_none),

        const SizedBox(width: 10),
        _circleIcon(
          Icons.logout,
          onTap: () {
            context.read<AuthCubit>().logout();
            context.pushReplacement(LoginScreen.path);
          },
        ),
      ],
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
          color: Colors.blue.shade100.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87),
      ),
    );
  }
}
