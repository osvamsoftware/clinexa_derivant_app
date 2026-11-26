import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:flutter/material.dart';

/// Botón heredado. Ahora delega en [ClxButton] del sistema de diseño; se
/// mantiene la firma para no romper llamadas antiguas.
///
/// - `opacity: true` → botón secundario.
/// - `backgroundColor`, `textColor`, `radius`, `fontSize` y `fontWeight` se
///   ignoran: el color y la forma los define el sistema.
/// Para código nuevo usa [ClxButton] directamente.
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool opacity;
  final double height;
  final double width;
  final double radius;
  final double fontSize;
  final FontWeight fontWeight;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.opacity = false,
    this.height = 52,
    this.radius = 40,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.width = double.infinity,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = height < 44 ? ClxButtonSize.sm : (height < 52 ? ClxButtonSize.md : ClxButtonSize.lg);
    final button = opacity
        ? ClxButton.secondary(label: text, onPressed: onPressed, icon: icon, loading: isLoading, size: size)
        : ClxButton(label: text, onPressed: onPressed, icon: icon, loading: isLoading, size: size);
    if (width == double.infinity) return button;
    return SizedBox(width: width, child: button);
  }
}
