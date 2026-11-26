// Clinexapp Design System — botones.
// Idéntico en las dos apps.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../clinexapp_tokens.dart';
import 'clx_palette.dart';

enum ClxButtonVariant {
  /// La acción principal de la pantalla. Una sola por zona.
  primary,

  /// Acciones de apoyo junto a la principal ("Cancelar").
  secondary,

  /// Acciones de bajo peso dentro de tarjetas ("Ver detalle").
  ghost,

  /// Destructivas e irreversibles. Siempre tras una confirmación.
  danger,

  /// Cualquier acción que ejecuta la IA.
  ai,
}

enum ClxButtonSize { sm, md, lg }

class ClxButton extends StatelessWidget {
  const ClxButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ClxButtonVariant.primary,
    this.size = ClxButtonSize.lg,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = true,
    this.pill = false,
  });

  const ClxButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = ClxButtonSize.lg,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = true,
    this.pill = false,
  }) : variant = ClxButtonVariant.secondary;

  const ClxButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = ClxButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = false,
    this.pill = false,
  }) : variant = ClxButtonVariant.ghost;

  const ClxButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = ClxButtonSize.lg,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = true,
    this.pill = false,
  }) : variant = ClxButtonVariant.danger;

  const ClxButton.ai({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = ClxButtonSize.lg,
    this.icon = LucideIcons.sparkles,
    this.trailingIcon,
    this.loading = false,
    this.expand = true,
    this.pill = false,
  }) : variant = ClxButtonVariant.ai;

  final String label;
  final VoidCallback? onPressed;
  final ClxButtonVariant variant;
  final ClxButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool loading;

  /// Ocupa todo el ancho disponible.
  final bool expand;

  /// Forma de píldora: solo en pantallas públicas (bienvenida, login).
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final enabled = onPressed != null && !loading;

    late final Color bg;
    late final Color fg;
    BorderSide side = BorderSide.none;
    switch (variant) {
      case ClxButtonVariant.primary:
        bg = c.brandBlue;
        fg = c.onBrand;
      case ClxButtonVariant.secondary:
        bg = c.surfaceRaised;
        fg = c.ink;
        side = BorderSide(color: c.borderStrong);
      case ClxButtonVariant.ghost:
        bg = Colors.transparent;
        fg = c.brandBlue;
      case ClxButtonVariant.danger:
        bg = c.danger;
        fg = c.isDark ? c.onBrand : Colors.white;
      case ClxButtonVariant.ai:
        bg = c.accentViolet;
        fg = c.isDark ? c.onBrand : Colors.white;
    }

    final height = switch (size) {
      ClxButtonSize.sm => 36.0,
      ClxButtonSize.md => 44.0,
      ClxButtonSize.lg => 52.0,
    };
    final fontSize = size == ClxButtonSize.sm ? 14.0 : 15.0;
    final iconSize = size == ClxButtonSize.sm ? 16.0 : 18.0;
    final hPad = size == ClxButtonSize.sm ? ClxSpace.s3 : ClxSpace.s5;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(fg)),
          )
        else if (icon != null)
          Icon(icon, size: iconSize, color: fg),
        if (loading || icon != null) const SizedBox(width: ClxSpace.s2),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.geist(fontSize: fontSize, fontWeight: FontWeight.w600, color: fg),
          ),
        ),
        if (trailingIcon != null && !loading) ...[
          const SizedBox(width: ClxSpace.s2),
          Icon(trailingIcon, size: iconSize, color: fg),
        ],
      ],
    );

    final radius = BorderRadius.circular(pill ? ClxRadius.pill : ClxRadius.md);
    final button = Opacity(
      opacity: enabled || loading ? 1 : 0.5,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(borderRadius: radius, side: side),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: Container(
            height: height,
            padding: EdgeInsets.symmetric(horizontal: hPad),
            // widthFactor 1: sin expand, el botón mide lo que su contenido
            // (un Container con alignment ocupaba todo el ancho disponible).
            child: Center(widthFactor: 1, child: content),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}

/// Botón de ícono cuadrado (barra superior, acciones de tarjeta).
class ClxIconButton extends StatelessWidget {
  const ClxIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.badge = false,
    this.filled = false,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  /// Punto indicador (por ejemplo, notificaciones sin leer).
  final bool badge;

  /// Con fondo y borde (para cabeceras sobre `surface`).
  final bool filled;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: filled ? c.surfaceRaised : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ClxRadius.md),
          side: filled ? BorderSide(color: c.border) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, size: 20, color: color ?? c.ink),
                if (badge)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: c.danger,
                        shape: BoxShape.circle,
                        border: Border.all(color: filled ? c.surfaceRaised : c.surface, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
