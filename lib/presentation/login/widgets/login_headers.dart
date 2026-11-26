import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Encabezado de formulario público: volver, título y descripción.
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
    final t = context.clxText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClxIconButton(
          icon: LucideIcons.arrowLeft,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.pop(),
        ),
        const SizedBox(height: ClxSpace.s4),
        Text(title.toUpperCase(), style: t.label),
        const SizedBox(height: ClxSpace.s1),
        Text(subtitle, style: t.h1),
        const SizedBox(height: ClxSpace.s2),
        Text(description, style: t.bodyMuted),
      ],
    );
  }
}
