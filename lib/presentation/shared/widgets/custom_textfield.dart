import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:flutter/material.dart';

/// Campo de texto heredado. Delega en [ClxTextField] (rótulo visible arriba,
/// borde `border-strong`, foco con anillo). Para código nuevo usa
/// [ClxTextField] directamente.
class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final bool isPassword;
  final IconData? icon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final int minLines;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextAlign textAlign;
  final int? maxLength;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.isPassword = false,
    this.icon,
    this.controller,
    this.validator,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.minLines = 1,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.textAlign = TextAlign.start,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return ClxTextField(
      label: label,
      hint: hint,
      isPassword: isPassword,
      icon: icon,
      controller: controller,
      validator: validator,
      focusNode: focusNode,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      textAlign: textAlign,
      maxLength: maxLength,
    );
  }
}
