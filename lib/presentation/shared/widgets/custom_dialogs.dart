import 'package:clinexa_derivant_app/core/constants/paths.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class CustomDialogs {
  // ============================================================
  // 🔹 LOADING DIALOG
  // ============================================================
  static Future<void> loadingDialog(BuildContext context) {
    final s = S.of(context);

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          height: 190,
          width: 50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(paths.iconLogoSvg, height: 40),
                  const SizedBox(width: 8),
                  SvgPicture.asset(paths.nameLogoSvg, height: 30),
                ],
              ),
              const SizedBox.square(
                dimension: 25,
                child: CircularProgressIndicator.adaptive(),
              ),
              Text(
                s.loading, // 🔵 traducido
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🔹 ERROR DIALOG
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
                Text(
                  s.errorOccurred, // 🔵 traducido
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(paths.iconLogoSvg, height: 40),
                    const SizedBox(width: 8),
                    SvgPicture.asset(paths.nameLogoSvg, height: 30),
                  ],
                ),
                Text(
                  error,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onTap ?? () => context.pop(),
                  child: Text(s.ok), // 🔵 traducido
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🔹 SUCCESS DIALOG
  // ============================================================
  static Future<void> successDialog({
    required BuildContext context,
    String? successMessage,
    void Function()? onPressed,
  }) {
    final s = S.of(context);

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          height: 230,
          width: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(paths.iconLogoSvg, height: 40),
                  const SizedBox(width: 8),
                  SvgPicture.asset(paths.nameLogoSvg, height: 30),
                ],
              ),
              const SizedBox(height: 10),
              if (successMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    successMessage,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: CustomButton(
                  text: s.ok,
                  onPressed: onPressed ?? () => context.pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🔹 ACCEPT / CANCEL DIALOG
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
  }) {
    final s = S.of(context);

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          height: height,
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(paths.iconLogoSvg, height: 40),
                  const SizedBox(width: 8),
                  SvgPicture.asset(paths.nameLogoSvg, height: 30),
                ],
              ),
              Text(
                title ?? s.noTitle, // 🔵 traducido
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              if (bodyMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    bodyMessage,
                    style: const TextStyle(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              childWidget ?? const SizedBox(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    onPressed: onCancel ?? () => context.pop(),
                    text: s.cancel,
                    width: 130,
                  ),
                  const SizedBox(width: 30),
                  CustomButton(
                    onPressed: onAccept ?? () => context.pop(),
                    text: s.accept,
                    width: 130,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🔹 CUSTOM WIDGET DIALOG
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          height: height,
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title ?? s.noTitle, // 🔵 traducido
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(paths.iconLogoSvg, height: 40),
                  const SizedBox(width: 8),
                  SvgPicture.asset(paths.nameLogoSvg, height: 30),
                ],
              ),
              if (bodyMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    bodyMessage,
                    style: const TextStyle(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              childWidget ?? const SizedBox(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
