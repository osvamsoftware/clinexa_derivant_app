import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Diálogos heredados, ahora con el estilo del sistema ([ClxDialog]).
/// Se mantienen las firmas para no tocar la lógica de las pantallas.
class CustomDialogs {
  // ============================================================
  // Cargando: tarjeta pequeña, sin logos ni texto largo.
  // ============================================================
  static Future<void> loadingDialog(BuildContext context) {
    final s = S.of(context);

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        final c = context.clx;
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: c.surfaceRaised,
            surfaceTintColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 96),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ClxRadius.xl),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: ClxSpace.s6,
                horizontal: ClxSpace.s5,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ClxLoader(size: 28),
                  const SizedBox(height: ClxSpace.s4),
                  Text(
                    s.loading,
                    style: context.clxText.bodySmStrong.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // Error: dice qué pasó; un solo botón para seguir.
  // ============================================================
  static Future<void> errorDialog(
    BuildContext context,
    String error, {
    Function()? onTap,
  }) {
    final s = S.of(context);

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => ClxDialog.body(
        title: s.errorOccurred,
        message: error,
        icon: LucideIcons.circleAlert,
        tone: ClxTone.danger,
        actions: [
          ClxButton(
            label: s.ok,
            size: ClxButtonSize.md,
            onPressed: onTap ?? () => context.pop(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Éxito
  // ============================================================
  static Future<void> successDialog({
    required BuildContext context,
    String? successMessage,
    String? title,
    String? buttonLabel,
    void Function()? onPressed,
  }) {
    final s = S.of(context);

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => ClxDialog.body(
        title: title ?? s.successTitle,
        message: successMessage,
        icon: LucideIcons.circleCheck,
        tone: ClxTone.success,
        actions: [
          ClxButton(
            label: buttonLabel ?? s.ok,
            size: ClxButtonSize.md,
            onPressed: onPressed ?? () => context.pop(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Aceptar / cancelar
  // ============================================================
  static Future<void> customAcceptOrCancel({
    required BuildContext context,
    String? bodyMessage,
    String? title,
    void Function()? onCancel,
    void Function()? onAccept,
    double height = 300,
    double width = 400,
    Widget? childWidget,
    String? acceptLabel,
  }) {
    final s = S.of(context);

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => ClxDialog.body(
        title: title ?? s.noTitle,
        message: bodyMessage,
        content: childWidget,
        actions: [
          ClxButton(
            label: acceptLabel ?? s.accept,
            size: ClxButtonSize.md,
            onPressed: onAccept ?? () => context.pop(),
          ),
          ClxButton.secondary(
            label: s.cancel,
            size: ClxButtonSize.md,
            onPressed: onCancel ?? () => context.pop(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Diálogo con contenido a medida
  // ============================================================
  static Future<void> customWidgetDialog({
    required BuildContext context,
    String? bodyMessage,
    String? title,
    double height = 300,
    double width = 400,
    Widget? childWidget,
  }) {
    final s = S.of(context);

    return showDialog(
      context: context,
      builder: (context) => ClxDialog.body(
        title: title ?? s.noTitle,
        message: bodyMessage,
        content: childWidget,
        actions: [
          ClxButton.secondary(
            label: s.close,
            size: ClxButtonSize.md,
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
