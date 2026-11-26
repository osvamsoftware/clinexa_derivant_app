import 'dart:async';

import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Campo de búsqueda que espera a que el usuario deje de escribir antes de
/// buscar. Usa la decoración del sistema ([clxInputDecoration]).
class DebouncedSearchField extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onSearch;
  final Duration delay;
  final String? label;
  final IconData? icon;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final String? helper;

  const DebouncedSearchField({
    super.key,
    required this.hintText,
    required this.onSearch,
    this.delay = const Duration(milliseconds: 600),
    this.label,
    this.icon,
    this.controller,
    this.suffixIcon,
    this.validator,
    this.helper,
  });

  @override
  State<DebouncedSearchField> createState() => _DebouncedSearchFieldState();
}

class _DebouncedSearchFieldState extends State<DebouncedSearchField> {
  Timer? _debounce;

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(widget.delay, () {
      widget.onSearch(value.trim());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final field = TextFormField(
      controller: widget.controller,
      onChanged: _onChanged,
      validator: widget.validator,
      textInputAction: TextInputAction.search,
      style: GoogleFonts.geist(fontSize: 15, color: c.ink),
      cursorColor: c.brandBlue,
      decoration: clxInputDecoration(
        context,
        hint: widget.hintText,
        icon: widget.icon ?? LucideIcons.search,
        suffix: widget.suffixIcon,
        helper: widget.helper,
      ),
    );
    if (widget.label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [ClxFieldLabel(widget.label!), field],
    );
  }
}
