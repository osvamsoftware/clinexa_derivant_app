import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Vista de error a pantalla completa según el código HTTP.
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

  String _getErrorTitle(S s) {
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
        return LucideIcons.triangleAlert;
      case 401:
      case 403:
        return LucideIcons.lock;
      case 404:
        return LucideIcons.searchX;
      case 408:
        return LucideIcons.timerOff;
      case 500:
      case 502:
      case 503:
        return LucideIcons.cloudOff;
      default:
        return LucideIcons.circleAlert;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ClxEmptyState(
      title: _getErrorTitle(s),
      message: s.errorGenericMessage,
      icon: _getErrorIcon(),
      tone: ClxTone.danger,
      actionLabel: onRetry != null ? s.retry : null,
      onAction: onRetry,
    );
  }
}
