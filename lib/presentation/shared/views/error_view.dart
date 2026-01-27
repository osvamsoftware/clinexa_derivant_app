import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final int? errorCode;
  final VoidCallback? onRetry;
  final double iconSize;
  final double logoSize;

  const ErrorView({
    super.key,
    this.errorCode,
    this.onRetry,
    this.iconSize = 72,
    this.logoSize = 100,
  });

  String _getErrorTitle(BuildContext context) {
    final s = S.of(context);
    switch (errorCode) {
      case 400:
        return s.error400;
      case 401:
        return s.error401;
      case 403:
        return s.error403;
      case 404:
        return s.error404;
      case 408:
        return s.error408;
      case 500:
        return s.error500;
      case 502:
      case 503:
        return s.error503;
      default:
        return s.errorUnknown;
    }
  }

  IconData _getErrorIcon() {
    switch (errorCode) {
      case 400:
        return Icons.warning_amber_rounded;
      case 401:
      case 403:
        return Icons.lock_outline_rounded;
      case 404:
        return Icons.search_off_rounded;
      case 408:
        return Icons.timer_off_rounded;
      case 500:
      case 502:
      case 503:
        return Icons.cloud_off_rounded;
      default:
        return Icons.error_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // // 🔹 Logo Clinexa
            // Image.asset(paths.logoPng, height: logoSize),
            // const SizedBox(height: 24),

            // 🔹 Ícono principal
            Icon(_getErrorIcon(), size: iconSize, color: AppColors.primary50),
            const SizedBox(height: 24),

            // 🔹 Título
            Text(
              _getErrorTitle(context),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // 🔹 Botón de acción (si se pasa callback)
            if (onRetry != null)
              CustomButton(
                text: s.retry,
                icon: Icons.refresh_rounded,
                onPressed: onRetry ?? () {},
                backgroundColor: colorScheme.primary,
                textColor: colorScheme.onPrimary,
              ),
          ],
        ),
      ),
    );
  }
}
