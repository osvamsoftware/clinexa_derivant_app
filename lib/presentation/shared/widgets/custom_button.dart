import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // 🔹 Ahora es opcional

  // Opcionales
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
    this.onPressed, // 🔹 Puede venir null
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
    final Color defaultBackground = backgroundColor ?? const Color(0xFF2962FF);

    final Color defaultTextColor = textColor ?? Colors.white;

    final Color finalBackground = opacity
        ? defaultBackground.withValues(alpha: .3)
        : defaultBackground;

    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // 🔹 Disable on loading
        style: ElevatedButton.styleFrom(
          backgroundColor: finalBackground,
          disabledBackgroundColor: finalBackground.withValues(
            alpha: 0.4,
          ), // 🔹 Disabled
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(defaultTextColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: defaultTextColor.withValues(
                        alpha: onPressed == null ? 0.5 : 1,
                      ),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: defaultTextColor.withValues(
                        alpha: onPressed == null ? 0.5 : 1,
                      ),
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
