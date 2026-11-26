// Clinexapp Design System — campos de formulario.
// Idéntico en las dos apps.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../clinexapp_tokens.dart';
import 'clx_palette.dart';

/// Rótulo de campo (visible siempre, encima del control).
class ClxFieldLabel extends StatelessWidget {
  const ClxFieldLabel(this.text, {super.key, this.optional = false, this.trailing});

  final String text;
  final bool optional;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.clxText;
    return Padding(
      padding: const EdgeInsets.only(bottom: ClxSpace.s2),
      child: Row(
        children: [
          Flexible(child: Text(text, style: t.bodySmStrong.copyWith(fontSize: 14))),
          if (optional) Text('  Opcional', style: t.bodySm.copyWith(color: context.clx.inkSubtle)),
          if (trailing != null) ...[const Spacer(), trailing!],
        ],
      ),
    );
  }
}

/// Decoración de campo del sistema (también para dropdowns y selectores).
InputDecoration clxInputDecoration(
  BuildContext context, {
  String? hint,
  IconData? icon,
  Widget? suffix,
  String? helper,
  String? counterText,
}) {
  final c = context.clx;
  OutlineInputBorder outline(Color color, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(ClxRadius.md),
        borderSide: BorderSide(color: color, width: w),
      );
  return InputDecoration(
    filled: true,
    fillColor: c.surfaceRaised,
    hintText: hint,
    hintStyle: GoogleFonts.geist(color: c.inkSubtle, fontSize: 15),
    helperText: helper,
    helperStyle: GoogleFonts.geist(color: c.inkMuted, fontSize: 13),
    helperMaxLines: 3,
    counterText: counterText,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    prefixIcon: icon != null ? Icon(icon, size: 18, color: c.inkSubtle) : null,
    prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    suffixIcon: suffix,
    errorStyle: GoogleFonts.geist(color: c.danger, fontSize: 13, fontWeight: FontWeight.w500),
    errorMaxLines: 3,
    border: outline(c.borderStrong),
    enabledBorder: outline(c.borderStrong),
    disabledBorder: outline(c.border),
    focusedBorder: outline(c.focusRing, 2),
    errorBorder: outline(c.danger),
    focusedErrorBorder: outline(c.danger, 2),
  );
}

/// Campo de texto con rótulo visible arriba, ayuda opcional y error.
class ClxTextField extends StatefulWidget {
  const ClxTextField({
    super.key,
    this.label,
    this.hint,
    this.helper,
    this.icon,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.isPassword = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
    this.readOnly = false,
    this.enabled = true,
    this.onTap,
    this.suffix,
    this.optional = false,
    this.textAlign = TextAlign.start,
    this.inputFormatters,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.initialValue,
    this.mono = false,
  });

  final String? label;
  final String? hint;
  final String? helper;
  final IconData? icon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final bool isPassword;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final bool readOnly;
  final bool enabled;
  final VoidCallback? onTap;
  final Widget? suffix;
  final bool optional;
  final TextAlign textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final String? initialValue;

  /// Valor en monoespaciada (códigos, DNI, montos).
  final bool mono;

  @override
  State<ClxTextField> createState() => _ClxTextFieldState();
}

class _ClxTextFieldState extends State<ClxTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final style = widget.mono
        ? GoogleFonts.sourceCodePro(fontSize: 15, color: c.ink, fontWeight: FontWeight.w500)
        : GoogleFonts.geist(fontSize: 15, color: c.ink);

    Widget? suffix = widget.suffix;
    if (widget.isPassword) {
      suffix = IconButton(
        tooltip: _obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(_obscure ? LucideIcons.eye : LucideIcons.eyeOff, size: 18, color: c.inkSubtle),
      );
    }

    final field = TextFormField(
      controller: widget.controller,
      initialValue: widget.controller == null ? widget.initialValue : null,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.isPassword && _obscure,
      minLines: widget.isPassword ? 1 : widget.minLines,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      onTap: widget.onTap,
      textAlign: widget.textAlign,
      inputFormatters: widget.inputFormatters,
      autofillHints: widget.autofillHints,
      textCapitalization: widget.textCapitalization,
      style: style,
      cursorColor: c.brandBlue,
      decoration: clxInputDecoration(
        context,
        hint: widget.hint,
        icon: widget.icon,
        suffix: suffix,
        helper: widget.helper,
      ),
    );

    if (widget.label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [ClxFieldLabel(widget.label!, optional: widget.optional), field],
    );
  }
}

/// Campo de búsqueda con ícono de lupa y botón para limpiar.
class ClxSearchField extends StatefulWidget {
  const ClxSearchField({super.key, required this.hint, this.controller, this.onChanged, this.onSubmitted, this.autofocus = false});

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  State<ClxSearchField> createState() => _ClxSearchFieldState();
}

class _ClxSearchFieldState extends State<ClxSearchField> {
  late final TextEditingController _ctrl = widget.controller ?? TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onText);
  }

  void _onText() => setState(() {});

  @override
  void dispose() {
    _ctrl.removeListener(_onText);
    if (widget.controller == null) _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    return TextField(
      controller: _ctrl,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      textInputAction: TextInputAction.search,
      style: GoogleFonts.geist(fontSize: 15, color: c.ink),
      cursorColor: c.brandBlue,
      decoration: clxInputDecoration(
        context,
        hint: widget.hint,
        icon: LucideIcons.search,
        suffix: _ctrl.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpiar búsqueda',
                icon: Icon(LucideIcons.x, size: 16, color: c.inkSubtle),
                onPressed: () {
                  _ctrl.clear();
                  widget.onChanged?.call('');
                },
              ),
      ),
    );
  }
}

/// Opción seleccionable en forma de tarjeta (radio o casilla).
class ClxChoiceTile extends StatelessWidget {
  const ClxChoiceTile({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.icon,
    this.multi = false,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  /// Casilla (varias opciones) en lugar de radio (una opción).
  final bool multi;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final t = context.clxText;
    final indicator = multi
        ? Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: selected ? c.brandBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(ClxRadius.sm),
              border: Border.all(color: selected ? c.brandBlue : c.borderStrong, width: 1.5),
            ),
            child: selected ? Icon(LucideIcons.check, size: 14, color: c.onBrand) : null,
          )
        : Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: selected ? c.brandBlue : c.borderStrong, width: selected ? 6 : 1.5)),
          );
    return Material(
      color: selected ? c.brandBlueSoft : c.surfaceRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ClxRadius.md),
        side: BorderSide(color: selected ? c.brandBlue : c.border, width: selected ? 1.5 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: ClxSpace.s4, vertical: ClxSpace.s3),
          child: Row(
            children: [
              if (icon != null) ...[Icon(icon, size: 18, color: selected ? c.onBrandBlueSoft : c.inkMuted), const SizedBox(width: ClxSpace.s3)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: t.bodyStrong.copyWith(fontSize: 14.5)),
                    if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: t.bodySm)],
                  ],
                ),
              ),
              const SizedBox(width: ClxSpace.s3),
              indicator,
            ],
          ),
        ),
      ),
    );
  }
}

/// Selector tipo dropdown con la decoración del sistema.
class ClxDropdown<T> extends StatelessWidget {
  const ClxDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint,
    this.icon,
    this.validator,
    required this.itemLabel,
  });

  final List<T> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? hint;
  final IconData? icon;
  final String? Function(T?)? validator;
  final String Function(T) itemLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final field = DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      validator: validator,
      onChanged: onChanged,
      icon: Icon(LucideIcons.chevronDown, size: 18, color: c.inkSubtle),
      dropdownColor: c.surfaceRaised,
      borderRadius: BorderRadius.circular(ClxRadius.md),
      style: GoogleFonts.geist(fontSize: 15, color: c.ink),
      decoration: clxInputDecoration(context, hint: hint, icon: icon),
      items: items.map((e) => DropdownMenuItem<T>(value: e, child: Text(itemLabel(e), overflow: TextOverflow.ellipsis))).toList(),
    );
    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [ClxFieldLabel(label!), field],
    );
  }
}
