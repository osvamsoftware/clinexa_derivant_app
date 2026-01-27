import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;

  const HeaderWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Volver atrás
        IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary40,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        const SizedBox(height: 8),
        // 🔹 Título principal
        Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primary40,
            ),
          ),
        ),
        const SizedBox(height: 28),
        // 🔹 Subtítulo
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary40,
          ),
        ),
        const SizedBox(height: 6),
        // 🔹 Descripción
        Text(
          description,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.neutral60,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
