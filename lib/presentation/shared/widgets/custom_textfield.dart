import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
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
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Label superior
        Text(
          widget.label,
          style: const TextStyle(
            color: AppColors.neutral10,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        // 🔹 Campo de texto
        TextFormField(
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          controller: widget.controller,
          validator: widget.validator,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.isPassword ? _obscure : false,
          style: const TextStyle(color: AppColors.neutral20, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.primary95, // Fondo azul MUY suave Clinexa
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: AppColors.primary60.withValues(alpha: .8),
              fontSize: 15,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),

            // 🔹 Icono opcional
            prefixIcon: widget.icon != null
                ? Icon(widget.icon, color: AppColors.neutral40, size: 22)
                : null,

            // 🔹 Toggle de contraseña
            suffixIcon: widget.isPassword
                ? GestureDetector(
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.neutral40,
                    ),
                  )
                : null,

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppColors.primary40, // Azul Clinexa
                width: 1.4,
              ),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.danger40),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppColors.danger40,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
