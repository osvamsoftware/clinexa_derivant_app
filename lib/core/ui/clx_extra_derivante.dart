// Clinexapp Design System — componentes extra que hoy solo usa la app
// Derivante. Mismo estilo que el resto de la carpeta; si el Receptor los
// necesita, se pueden mover a los archivos compartidos.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../clinexapp_tokens.dart';
import 'clx_palette.dart';

/// Control segmentado (dos o tres opciones excluyentes).
class ClxSegmented<T> extends StatelessWidget {
  const ClxSegmented({super.key, required this.segments, required this.value, required this.onChanged});

  final List<ClxSegment<T>> segments;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    return Container(
      padding: const EdgeInsets.all(ClxSpace.s1),
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: BorderRadius.circular(ClxRadius.md + 2),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          for (final seg in segments)
            Expanded(
              child: _SegmentButton(
                segment: seg,
                selected: seg.value == value,
                onTap: () => onChanged(seg.value),
              ),
            ),
        ],
      ),
    );
  }
}

class ClxSegment<T> {
  const ClxSegment({required this.value, required this.label, this.icon});
  final T value;
  final String label;
  final IconData? icon;
}

class _SegmentButton<T> extends StatelessWidget {
  const _SegmentButton({required this.segment, required this.selected, required this.onTap});

  final ClxSegment<T> segment;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final fg = selected ? c.ink : c.inkMuted;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? c.surfaceRaised : Colors.transparent,
        borderRadius: BorderRadius.circular(ClxRadius.md),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 36,
            alignment: Alignment.center,
            decoration: selected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(ClxRadius.md),
                    border: Border.all(color: c.border),
                    boxShadow: c.shadowCard,
                  )
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (segment.icon != null) ...[
                  Icon(segment.icon, size: 16, color: selected ? c.brandBlue : fg),
                  const SizedBox(width: ClxSpace.s2),
                ],
                Flexible(
                  child: Text(
                    segment.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.geist(fontSize: 14, fontWeight: FontWeight.w600, color: fg),
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

/// Lista de sugerencias bajo un campo de búsqueda (direcciones,
/// especialidades, patologías).
class ClxSuggestionList<T> extends StatelessWidget {
  const ClxSuggestionList({
    super.key,
    required this.items,
    required this.label,
    required this.onSelected,
    this.icon,
    this.maxItems = 6,
  });

  final List<T> items;
  final String Function(T) label;
  final ValueChanged<T> onSelected;
  final IconData? icon;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final t = context.clxText;
    final visible = items.take(maxItems).toList();
    return Container(
      margin: const EdgeInsets.only(top: ClxSpace.s2),
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: BorderRadius.circular(ClxRadius.md),
        border: Border.all(color: c.border),
        boxShadow: c.shadowFloat,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(ClxRadius.md),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < visible.length; i++) ...[
              InkWell(
                onTap: () => onSelected(visible[i]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: ClxSpace.s4, vertical: ClxSpace.s3),
                  child: Row(
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 16, color: c.inkSubtle),
                        const SizedBox(width: ClxSpace.s3),
                      ],
                      Expanded(child: Text(label(visible[i]), style: t.body.copyWith(fontSize: 14.5))),
                    ],
                  ),
                ),
              ),
              if (i < visible.length - 1) Divider(height: 1, thickness: 1, color: c.border),
            ],
          ],
        ),
      ),
    );
  }
}

/// Etiqueta seleccionada que se puede quitar (especialidades elegidas).
class ClxInputChip extends StatelessWidget {
  const ClxInputChip({super.key, required this.label, this.onRemove, this.removeTooltip = 'Quitar'});

  final String label;
  final VoidCallback? onRemove;
  final String removeTooltip;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    return Container(
      padding: EdgeInsets.only(left: ClxSpace.s3, right: onRemove == null ? ClxSpace.s3 : ClxSpace.s1, top: 2, bottom: 2),
      decoration: BoxDecoration(
        color: c.brandBlueSoft,
        borderRadius: BorderRadius.circular(ClxRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.geist(fontSize: 13.5, fontWeight: FontWeight.w600, color: c.onBrandBlueSoft),
              ),
            ),
          ),
          if (onRemove != null)
            Tooltip(
              message: removeTooltip,
              child: InkResponse(
                onTap: onRemove,
                radius: 16,
                child: Padding(
                  padding: const EdgeInsets.all(ClxSpace.s1),
                  child: Icon(LucideIcons.x, size: 14, color: c.onBrandBlueSoft),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Barra de navegación inferior de las pantallas principales: fondo
/// `surfaceRaised`, borde superior y el destino activo en `brandBlue`.
class ClxNavBar extends StatelessWidget {
  const ClxNavBar({super.key, required this.items, required this.currentIndex, required this.onTap});

  final List<ClxNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

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
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(child: _NavButton(item: items[i], selected: i == currentIndex, onTap: () => onTap(i))),
            ],
          ),
        ),
      ),
    );
  }
}

class ClxNavItem {
  const ClxNavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.selected, required this.onTap});

  final ClxNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final color = selected ? c.brandBlue : c.inkSubtle;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        highlightShape: BoxShape.rectangle,
        containedInkWell: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                color: selected ? c.brandBlueSoft : Colors.transparent,
                borderRadius: BorderRadius.circular(ClxRadius.pill),
              ),
              child: Icon(item.icon, size: 20, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: GoogleFonts.geist(fontSize: 12, fontWeight: selected ? FontWeight.w600 : FontWeight.w500, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila de dato bloqueado (paciente con datos parciales hasta que el
/// investigador pague el acceso).
class ClxLockedValue extends StatelessWidget {
  const ClxLockedValue({super.key, required this.text, this.tooltip});

  final String text;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.lock, size: 14, color: c.warning),
        const SizedBox(width: ClxSpace.s1),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.right,
            style: context.clxText.bodySm.copyWith(color: c.inkMuted, fontSize: 14),
          ),
        ),
      ],
    );
    return Align(
      alignment: Alignment.centerRight,
      child: tooltip == null ? row : Tooltip(message: tooltip!, child: row),
    );
  }
}

/// Placa clara para apoyar el logo sobre el degradado de marca. El logotipo
/// lleva azul marino y no se recolorea: en tema oscuro necesita fondo claro
/// para leerse, así que la placa es siempre blanca en los dos temas.
class ClxLogoPlate extends StatelessWidget {
  const ClxLogoPlate({super.key, required this.child, this.padding = const EdgeInsets.all(ClxSpace.s5), this.radius = ClxRadius.xl});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: ClxColors.surfaceRaised,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: ClxShadow.float,
      ),
      child: child,
    );
  }
}
