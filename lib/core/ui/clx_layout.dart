// Clinexapp Design System — estructura de pantalla, tarjetas y listas.
// Idéntico en las dos apps.
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../clinexapp_tokens.dart';
import 'clx_palette.dart';

/// Barra superior estándar de las pantallas internas: título a la izquierda,
/// botón de volver con ícono Lucide y fondo `surface`.
class ClxAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ClxAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.showBack = true,
    this.onBack,
    this.bottom,
    this.backgroundColor,
  });

  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBack;
  final VoidCallback? onBack;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;

  @override
  Size get preferredSize => Size.fromHeight(56 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final canPop = Navigator.of(context).canPop();
    return AppBar(
      backgroundColor: backgroundColor ?? c.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: (showBack && canPop) || leading != null ? 0 : ClxSpace.s4,
      automaticallyImplyLeading: false,
      leading: leading ??
          (showBack && (canPop || onBack != null)
              ? IconButton(
                  tooltip: 'Volver',
                  icon: Icon(LucideIcons.arrowLeft, color: c.ink, size: 22),
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                )
              : null),
      title: title == null ? null : Text(title!, style: context.clxText.h2, maxLines: 1, overflow: TextOverflow.ellipsis),
      actions: [
        ...?actions,
        if (actions != null) const SizedBox(width: ClxSpace.s2),
      ],
      bottom: bottom,
      shape: Border(bottom: BorderSide(color: c.border)),
    );
  }
}

/// Encabezado grande de pantalla (título + subtítulo opcional).
class ClxPageHeader extends StatelessWidget {
  const ClxPageHeader({super.key, required this.title, this.subtitle, this.eyebrow, this.trailing});

  final String title;
  final String? subtitle;

  /// Rótulo pequeño en mayúsculas encima del título.
  final String? eyebrow;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.clxText;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[
                Text(eyebrow!.toUpperCase(), style: t.label),
                const SizedBox(height: ClxSpace.s1),
              ],
              Text(title, style: t.h1),
              if (subtitle != null) ...[
                const SizedBox(height: ClxSpace.s2),
                Text(subtitle!, style: t.bodyMuted),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: ClxSpace.s3), trailing!],
      ],
    );
  }
}

/// Título de sección con acción opcional a la derecha.
class ClxSectionHeader extends StatelessWidget {
  const ClxSectionHeader({super.key, required this.title, this.actionLabel, this.onAction, this.subtitle});

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = context.clxText;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: t.h2),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: t.bodySm),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(ClxRadius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: ClxSpace.s1, vertical: ClxSpace.s1),
              child: Text(actionLabel!, style: t.link.copyWith(fontSize: 14)),
            ),
          ),
      ],
    );
  }
}

/// Tarjeta del sistema: `surface-raised`, borde fino, radio lg y sombra azulada.
class ClxCard extends StatelessWidget {
  const ClxCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(ClxSpace.s5),
    this.onTap,
    this.color,
    this.borderColor,
    this.flat = false,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  /// Sin sombra (para tarjetas anidadas o sobre `surface-sunken`).
  final bool flat;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final radius = BorderRadius.circular(ClxRadius.lg);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? c.surfaceRaised,
        borderRadius: radius,
        border: Border.all(color: borderColor ?? c.border),
        boxShadow: flat ? null : c.shadowCard,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? Padding(padding: padding, child: child) : InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
      ),
    );
  }
}

/// Fila de lista: ícono en cuadro suave, título, subtítulo y remate.
class ClxListTile extends StatelessWidget {
  const ClxListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.trailing,
    this.onTap,
    this.showChevron,
    this.iconColor,
    this.iconBackground,
    this.dense = false,
    this.destructive = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Por defecto se muestra si hay [onTap] y no hay [trailing].
  final bool? showChevron;
  final Color? iconColor;
  final Color? iconBackground;
  final bool dense;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final t = context.clxText;
    final chevron = showChevron ?? (onTap != null && trailing == null);
    final fg = destructive ? c.danger : (iconColor ?? c.brandBlue);
    final bg = destructive ? c.dangerSoft : (iconBackground ?? c.brandBlueSoft);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ClxSpace.s4, vertical: dense ? ClxSpace.s3 : ClxSpace.s4),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: ClxSpace.s3)],
            if (leading == null && icon != null) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(ClxRadius.md)),
                child: Icon(icon, size: 18, color: fg),
              ),
              const SizedBox(width: ClxSpace.s3),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.bodyStrong.copyWith(color: destructive ? c.danger : c.ink)),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: t.bodySm, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: ClxSpace.s3), trailing!],
            if (chevron) ...[
              const SizedBox(width: ClxSpace.s2),
              Icon(LucideIcons.chevronRight, size: 18, color: c.inkSubtle),
            ],
          ],
        ),
      ),
    );
  }
}

/// Grupo de filas dentro de una tarjeta, separadas por divisores.
class ClxListGroup extends StatelessWidget {
  const ClxListGroup({super.key, required this.children, this.title});

  final List<Widget> children;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i < children.length - 1) items.add(Divider(height: 1, thickness: 1, color: c.border, indent: ClxSpace.s4));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(left: ClxSpace.s1, bottom: ClxSpace.s2),
            child: Text(title!.toUpperCase(), style: context.clxText.label),
          ),
        ClxCard(padding: EdgeInsets.zero, child: Column(children: items)),
      ],
    );
  }
}

/// Par rótulo / valor para fichas de detalle.
class ClxKeyValue extends StatelessWidget {
  const ClxKeyValue({super.key, required this.label, required this.value, this.mono = false, this.icon, this.valueWidget});

  final String label;
  final String value;

  /// Valor en monoespaciada (montos, códigos, IDs, fechas).
  final bool mono;
  final IconData? icon;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final t = context.clxText;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ClxSpace.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: 16, color: c.inkSubtle)),
            const SizedBox(width: ClxSpace.s2),
          ],
          Expanded(
            flex: 4,
            child: Text(label, style: t.bodySm),
          ),
          const SizedBox(width: ClxSpace.s3),
          Expanded(
            flex: 6,
            child: valueWidget ??
                Text(
                  value.isEmpty ? '—' : value,
                  textAlign: TextAlign.right,
                  style: mono ? t.data : t.bodySmStrong.copyWith(fontSize: 14),
                ),
          ),
        ],
      ),
    );
  }
}

/// Avatar con iniciales sobre `brand-blue-soft`.
class ClxAvatar extends StatelessWidget {
  const ClxAvatar({super.key, required this.name, this.size = 40, this.imageUrl});

  final String name;
  final double size;
  final String? imageUrl;

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.brandBlueSoft,
        shape: BoxShape.circle,
        image: hasImage ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover) : null,
      ),
      alignment: Alignment.center,
      child: hasImage
          ? null
          : Text(
              initials(name),
              style: context.clxText.bodyStrong.copyWith(color: c.onBrandBlueSoft, fontSize: size * 0.38),
            ),
    );
  }
}

/// Indicador de pasos para flujos de varias pantallas (registro, derivación).
class ClxStepper extends StatelessWidget {
  const ClxStepper({super.key, required this.current, required this.total, this.label});

  /// Paso actual, empezando en 1.
  final int current;
  final int total;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PASO $current DE $total${label != null ? ' · ${label!.toUpperCase()}' : ''}',
          style: context.clxText.label,
        ),
        const SizedBox(height: ClxSpace.s2),
        Row(
          children: List.generate(total, (i) {
            final done = i < current;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i == total - 1 ? 0 : ClxSpace.s1),
                decoration: BoxDecoration(
                  color: done ? c.brandBlue : c.surfaceSunken,
                  borderRadius: BorderRadius.circular(ClxRadius.pill),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Barra inferior fija para la acción principal de un formulario.
class ClxBottomBar extends StatelessWidget {
  const ClxBottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: ClxSpace.s2),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(ClxSpace.s4, ClxSpace.s3, ClxSpace.s4, ClxSpace.s2),
          child: child,
        ),
      ),
    );
  }
}

/// Tarjeta de métrica: rótulo, cifra y detalle opcional.
class ClxStatCard extends StatelessWidget {
  const ClxStatCard({super.key, required this.label, required this.value, this.icon, this.detail, this.brand = false, this.onTap});

  final String label;
  final String value;
  final IconData? icon;
  final String? detail;

  /// Destaca la métrica principal (una por fila).
  final bool brand;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final t = context.clxText;
    return ClxCard(
      onTap: onTap,
      padding: const EdgeInsets.all(ClxSpace.s4),
      color: brand ? c.brandTealSoft : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label.toUpperCase(), style: t.label, maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (icon != null) Icon(icon, size: 16, color: brand ? c.brandTealText : c.inkSubtle),
            ],
          ),
          const SizedBox(height: ClxSpace.s2),
          Text(value, style: t.dataLg),
          if (detail != null) ...[
            const SizedBox(height: ClxSpace.s1),
            Text(detail!, style: t.bodySm, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }
}

/// Encabezado de marca con el degradado del logo (splash, bienvenida, login).
class ClxBrandHeader extends StatelessWidget {
  const ClxBrandHeader({super.key, required this.child, this.height, this.bottomRadius = ClxRadius.xl});

  final Widget child;
  final double? height;
  final double bottomRadius;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: c.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(bottomRadius)),
      ),
      child: child,
    );
  }
}
