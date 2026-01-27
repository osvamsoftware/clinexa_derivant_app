import 'dart:async';
import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:flutter/material.dart';

class DebouncedSearchField extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onSearch;
  final Duration delay;
  final String? label;
  final IconData? icon;
  final TextEditingController? controller;

  const DebouncedSearchField({
    super.key,
    required this.hintText,
    required this.onSearch,
    this.delay = const Duration(milliseconds: 600),
    this.label,
    this.icon,
    this.controller,
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
    widget.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ------------------------------
        // 🔹 LABEL SUPERIOR
        // ------------------------------
        if (widget.label != null)
          Text(
            widget.label!,
            style: TextStyle(
              color: isDark ? AppColors.neutral90 : AppColors.neutral10,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

        if (widget.label != null) const SizedBox(height: 8),

        // ------------------------------
        // 🔹 SEARCH INPUT
        // ------------------------------
        TextField(
          controller: widget.controller,
          onChanged: _onChanged,
          style: TextStyle(
            color: isDark ? AppColors.neutral95 : AppColors.neutral20,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? AppColors.neutral20 : AppColors.primary95,
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: isDark
                  ? AppColors.neutral60
                  : AppColors.primary60.withValues(alpha: .8),
              fontSize: 15,
            ),

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),

            // 🔹 Icono de búsqueda
            prefixIcon: Icon(
              widget.icon ?? Icons.search_rounded,
              color: isDark ? AppColors.neutral60 : AppColors.neutral40,
              size: 22,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppColors.primary40,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
