// Clinexapp Design System — insignias, avisos, estados vacíos, esqueletos,
// diálogos y mensajes.
// Idéntico en las dos apps.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../clinexapp_tokens.dart';
import 'clx_buttons.dart';
import 'clx_palette.dart';

/// Tono de un estado. Un estado = un color en todo el producto.
enum ClxTone {
  /// Borrador, inactivo, sin asignar.
  neutral,

  /// Postulado, en revisión.
  info,

  /// Aceptado, pagado, activo, completado.
  success,

  /// Pendiente de pago, por vencer.
  warning,

  /// Rechazado, vencido, pago fallido.
  danger,

  /// Sugerido por IA, extraído de PDF.
  ai,
}

class _ToneColors {
  const _ToneColors(this.fg, this.bg, this.dot);
  final Color fg;
  final Color bg;
  final Color dot;
}

_ToneColors _tone(ClxPalette c, ClxTone tone) => switch (tone) {
      ClxTone.neutral => _ToneColors(c.inkMuted, c.surfaceSunken, c.inkSubtle),
      ClxTone.info => _ToneColors(c.onBrandBlueSoft, c.brandBlueSoft, c.brandBlue),
      ClxTone.success => _ToneColors(c.success, c.successSoft, c.success),
      ClxTone.warning => _ToneColors(c.warning, c.warningSoft, c.isDark ? c.warning : c.accentAmber),
      ClxTone.danger => _ToneColors(c.danger, c.dangerSoft, c.danger),
      ClxTone.ai => _ToneColors(c.accentViolet, c.accentVioletSoft, c.accentViolet),
    };

/// Insignia de estado en píldora con punto (o ícono). Siempre con texto.
class ClxBadge extends StatelessWidget {
  const ClxBadge({super.key, required this.label, this.tone = ClxTone.neutral, this.icon});

  /// Marca de IA: violeta con destello.
  const ClxBadge.ai({super.key, this.label = 'IA'})
      : tone = ClxTone.ai,
        icon = LucideIcons.sparkles;

  final String label;
  final ClxTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = _tone(context.clx, tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: t.bg, borderRadius: BorderRadius.circular(ClxRadius.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 13, color: t.fg)
          else
            Container(width: 6, height: 6, decoration: BoxDecoration(color: t.dot, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.geist(fontSize: 12.5, height: 16 / 12.5, fontWeight: FontWeight.w600, color: t.fg),
            ),
          ),
        ],
      ),
    );
  }
}

/// Aviso en línea (informativo, éxito, advertencia, error o IA).
class ClxNotice extends StatelessWidget {
  const ClxNotice({super.key, required this.message, this.title, this.tone = ClxTone.info, this.icon, this.action});

  final String message;
  final String? title;
  final ClxTone tone;
  final IconData? icon;
  final Widget? action;

  static IconData _defaultIcon(ClxTone tone) => switch (tone) {
        ClxTone.success => LucideIcons.circleCheck,
        ClxTone.warning => LucideIcons.triangleAlert,
        ClxTone.danger => LucideIcons.circleAlert,
        ClxTone.ai => LucideIcons.sparkles,
        _ => LucideIcons.info,
      };

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final tc = _tone(c, tone);
    final txt = context.clxText;
    return Container(
      padding: const EdgeInsets.all(ClxSpace.s4),
      decoration: BoxDecoration(color: tc.bg, borderRadius: BorderRadius.circular(ClxRadius.lg)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? _defaultIcon(tone), size: 18, color: tc.fg),
          const SizedBox(width: ClxSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(title!, style: txt.bodySmStrong.copyWith(color: c.ink, fontSize: 14)),
                  const SizedBox(height: 2),
                ],
                Text(message, style: txt.bodySm.copyWith(color: c.ink)),
                if (action != null) ...[const SizedBox(height: ClxSpace.s3), action!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado vacío o de error: ícono, título, texto y acción opcional.
class ClxEmptyState extends StatelessWidget {
  const ClxEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = LucideIcons.inbox,
    this.actionLabel,
    this.onAction,
    this.tone = ClxTone.info,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final ClxTone tone;

  @override
  Widget build(BuildContext context) {
    final tc = _tone(context.clx, tone);
    final t = context.clxText;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ClxSpace.s8, vertical: ClxSpace.s12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: tc.bg, borderRadius: BorderRadius.circular(ClxRadius.lg)),
              child: Icon(icon, size: 26, color: tc.fg),
            ),
            const SizedBox(height: ClxSpace.s4),
            Text(title, style: t.h3, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: ClxSpace.s2),
              Text(message!, style: t.bodySm, textAlign: TextAlign.center),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: ClxSpace.s6),
              ClxButton.secondary(label: actionLabel!, onPressed: onAction, expand: false, size: ClxButtonSize.md),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bloque de esqueleto con pulso suave. Se usa con el tamaño final del contenido.
class ClxSkeleton extends StatefulWidget {
  const ClxSkeleton({super.key, this.width = double.infinity, this.height = 14, this.radius = ClxRadius.sm});

  final double width;
  final double height;
  final double radius;

  @override
  State<ClxSkeleton> createState() => _ClxSkeletonState();
}

class _ClxSkeletonState extends State<ClxSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final box = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(color: c.surfaceSunken, borderRadius: BorderRadius.circular(widget.radius)),
    );
    if (reduce) return box;
    return FadeTransition(opacity: Tween(begin: 0.55, end: 1.0).animate(_ctrl), child: box);
  }
}

/// Lista de tarjetas esqueleto para estados de carga de listas.
class ClxSkeletonList extends StatelessWidget {
  const ClxSkeletonList({super.key, this.count = 5, this.padding = const EdgeInsets.all(ClxSpace.s4)});

  final int count;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: ClxSpace.s3),
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(ClxSpace.s4),
        decoration: BoxDecoration(
          color: c.surfaceRaised,
          borderRadius: BorderRadius.circular(ClxRadius.lg),
          border: Border.all(color: c.border),
        ),
        child: const Row(
          children: [
            ClxSkeleton(width: 40, height: 40, radius: 20),
            SizedBox(width: ClxSpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClxSkeleton(width: 160, height: 14),
                  SizedBox(height: ClxSpace.s2),
                  ClxSkeleton(width: 220, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Indicador de carga pequeño y centrado (solo para la verificación de sesión
/// o acciones puntuales; para listas usa [ClxSkeletonList]).
class ClxLoader extends StatelessWidget {
  const ClxLoader({super.key, this.size = 28});
  final double size;

  @override
  Widget build(BuildContext context) => Center(
        child: SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: context.clx.brandBlue),
        ),
      );
}

/// Mensajes breves (snackbar) con el estilo del sistema.
class ClxToast {
  ClxToast._();

  static void show(BuildContext context, String message, {ClxTone tone = ClxTone.neutral}) {
    final c = context.clx;
    final icon = switch (tone) {
      ClxTone.success => LucideIcons.circleCheck,
      ClxTone.danger => LucideIcons.circleAlert,
      ClxTone.warning => LucideIcons.triangleAlert,
      ClxTone.ai => LucideIcons.sparkles,
      _ => LucideIcons.info,
    };
    final iconColor = switch (tone) {
      ClxTone.success => ClxColorsDark.success,
      ClxTone.danger => ClxColorsDark.danger,
      ClxTone.warning => ClxColorsDark.warning,
      ClxTone.ai => ClxColorsDark.accentViolet,
      _ => ClxColorsDark.brandBlueHover,
    };
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: c.isDark ? c.surfaceRaised : ClxColors.ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ClxRadius.md),
            side: c.isDark ? BorderSide(color: c.border) : BorderSide.none,
          ),
          content: Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: ClxSpace.s3),
              Expanded(child: Text(message, style: GoogleFonts.geist(color: ClxColorsDark.ink, fontSize: 14, height: 1.35))),
            ],
          ),
        ),
      );
  }

  static void success(BuildContext context, String message) => show(context, message, tone: ClxTone.success);
  static void error(BuildContext context, String message) => show(context, message, tone: ClxTone.danger);
  static void info(BuildContext context, String message) => show(context, message, tone: ClxTone.info);
}

/// Diálogos del sistema.
class ClxDialog {
  ClxDialog._();

  /// Confirmación. Devuelve true si se confirmó. Con [destructive], el botón
  /// de confirmar es rojo y nunca es la acción por defecto.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    String? message,
    required String confirmLabel,
    String cancelLabel = 'Cancelar',
    bool destructive = false,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ClxDialogBody(
        title: title,
        message: message,
        icon: icon ?? (destructive ? LucideIcons.triangleAlert : null),
        tone: destructive ? ClxTone.danger : ClxTone.info,
        actions: [
          destructive
              ? ClxButton.danger(label: confirmLabel, onPressed: () => Navigator.of(ctx).pop(true), size: ClxButtonSize.md)
              : ClxButton(label: confirmLabel, onPressed: () => Navigator.of(ctx).pop(true), size: ClxButtonSize.md),
          ClxButton.secondary(label: cancelLabel, onPressed: () => Navigator.of(ctx).pop(false), size: ClxButtonSize.md),
        ],
      ),
    );
    return result ?? false;
  }

  /// Aviso con un solo botón.
  static Future<void> alert(
    BuildContext context, {
    required String title,
    String? message,
    String buttonLabel = 'Entendido',
    ClxTone tone = ClxTone.info,
    IconData? icon,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => _ClxDialogBody(
        title: title,
        message: message,
        icon: icon,
        tone: tone,
        actions: [ClxButton(label: buttonLabel, onPressed: () => Navigator.of(ctx).pop(), size: ClxButtonSize.md)],
      ),
    );
  }

  /// Contenedor genérico con el estilo del sistema para diálogos a medida.
  static Widget body({required String title, String? message, IconData? icon, ClxTone tone = ClxTone.info, Widget? content, required List<Widget> actions}) =>
      _ClxDialogBody(title: title, message: message, icon: icon, tone: tone, content: content, actions: actions);
}

class _ClxDialogBody extends StatelessWidget {
  const _ClxDialogBody({required this.title, this.message, this.icon, this.tone = ClxTone.info, this.content, required this.actions});

  final String title;
  final String? message;
  final IconData? icon;
  final ClxTone tone;
  final Widget? content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final t = context.clxText;
    final tc = _tone(c, tone);
    return Dialog(
      backgroundColor: c.surfaceRaised,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: ClxSpace.s6, vertical: ClxSpace.s6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ClxRadius.xl)),
      child: Padding(
        padding: const EdgeInsets.all(ClxSpace.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: tc.bg, borderRadius: BorderRadius.circular(ClxRadius.lg)),
                child: Icon(icon, size: 22, color: tc.fg),
              ),
              const SizedBox(height: ClxSpace.s4),
            ],
            Text(title, style: t.h2),
            if (message != null) ...[
              const SizedBox(height: ClxSpace.s2),
              Text(message!, style: t.bodyMuted),
            ],
            if (content != null) ...[const SizedBox(height: ClxSpace.s4), content!],
            const SizedBox(height: ClxSpace.s6),
            for (var i = 0; i < actions.length; i++) ...[
              actions[i],
              if (i < actions.length - 1) const SizedBox(height: ClxSpace.s2),
            ],
          ],
        ),
      ),
    );
  }
}

/// Hoja inferior con asa, título y contenido.
class ClxSheet {
  ClxSheet._();

  static Future<T?> show<T>(BuildContext context, {required String title, required Widget child, String? subtitle}) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.clx.surfaceRaised,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(ClxRadius.xl))),
      builder: (ctx) {
        final c = ctx.clx;
        final t = ctx.clxText;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(ClxSpace.s5, ClxSpace.s3, ClxSpace.s5, ClxSpace.s5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(color: c.border, borderRadius: BorderRadius.circular(ClxRadius.pill)),
                    ),
                  ),
                  const SizedBox(height: ClxSpace.s4),
                  Text(title, style: t.h2),
                  if (subtitle != null) ...[const SizedBox(height: ClxSpace.s1), Text(subtitle, style: t.bodySm)],
                  const SizedBox(height: ClxSpace.s4),
                  Flexible(child: child),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
