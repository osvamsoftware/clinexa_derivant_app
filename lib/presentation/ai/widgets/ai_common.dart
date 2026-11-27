import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/data/models/ai_models.dart';
import 'package:clinexa_derivant_app/domain/ai_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/ai_status_cubit.dart';
import 'package:clinexa_derivant_app/presentation/ai/cubit/document_extraction_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Muestra [child] solo si la IA está disponible (`GET /ai/app/status`).
/// Si está apagada o el backend no tiene las rutas, no se ve nada y la
/// pantalla queda igual que antes de la IA.
class AiGate extends StatefulWidget {
  const AiGate({
    super.key,
    required this.child,
    this.placeholder = const SizedBox.shrink(),
  });

  final Widget child;
  final Widget placeholder;

  @override
  State<AiGate> createState() => _AiGateState();
}

class _AiGateState extends State<AiGate> {
  @override
  void initState() {
    super.initState();
    context.read<AiStatusCubit>().ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiStatusCubit, AiAvailability>(
      builder: (context, a) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: a == AiAvailability.enabled ? widget.child : widget.placeholder,
      ),
    );
  }
}

/// Texto para mostrar de un error de IA: el `detail` del backend tal cual
/// (ya viene en español) o un mensaje propio si no hubo respuesta.
String aiErrorText(BuildContext context, AiException? e) {
  final s = S.of(context);
  if (e == null) return s.aiGenericError;
  return switch (e.statusCode) {
    0 => s.aiNoConnection,
    DocumentExtractionCubit.tooLargeCode when e.detail == null =>
      s.aiFileTooLarge,
    DocumentExtractionCubit.unsupportedCode when e.detail == null =>
      s.aiFileUnsupported,
    _ => e.detail ?? s.aiGenericError,
  };
}

/// Aviso de error de IA con botón de reintento opcional.
class AiErrorNotice extends StatelessWidget {
  const AiErrorNotice({super.key, required this.error, this.onRetry});

  final AiException? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ClxNotice(
      key: const Key('ai_error_notice'),
      tone: ClxTone.danger,
      message: aiErrorText(context, error),
      action: onRetry == null
          ? null
          : Align(
              alignment: Alignment.centerLeft,
              child: ClxButton.secondary(
                label: s.aiRetry,
                icon: LucideIcons.rotateCw,
                size: ClxButtonSize.sm,
                expand: false,
                onPressed: onRetry,
              ),
            ),
    );
  }
}

/// Insignia de estado de un criterio (Cumple / No cumple / Falta dato).
/// Colores de estado del sistema: no es neón, es un estado clínico.
class EligibilityStatusBadge extends StatelessWidget {
  const EligibilityStatusBadge({super.key, required this.status});

  final EligibilityStatus status;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return switch (status) {
      EligibilityStatus.meets => ClxBadge(
        label: s.aiStatusMeets,
        tone: ClxTone.success,
        icon: LucideIcons.circleCheck,
      ),
      EligibilityStatus.fails => ClxBadge(
        label: s.aiStatusFails,
        tone: ClxTone.danger,
        icon: LucideIcons.circleX,
      ),
      EligibilityStatus.missing => ClxBadge(
        label: s.aiStatusMissing,
        tone: ClxTone.warning,
        icon: LucideIcons.circleHelp,
      ),
    };
  }
}

/// Encabezado de una tarjeta de IA: destello, título neón y etiqueta.
class AiCardHeader extends StatelessWidget {
  const AiCardHeader({
    super.key,
    required this.title,
    this.trailing,
    this.icon,
  });

  final String title;
  final Widget? trailing;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon == null)
          const ClxAiSpark(size: 20)
        else
          Icon(icon, size: 20, color: context.clx.accentViolet),
        const SizedBox(width: ClxSpace.s2),
        Expanded(child: ClxAiText(title, style: context.clxText.h3)),
        if (trailing != null) ...[
          const SizedBox(width: ClxSpace.s2),
          trailing!,
        ],
      ],
    );
  }
}

/// Texto legible del sexo que devuelve la API.
String aiSexLabel(BuildContext context, String? sex) {
  final s = S.of(context);
  return switch (sex) {
    'male' => s.male,
    'female' => s.female,
    'other' => s.other,
    _ => s.aiNotProvided,
  };
}

/// Fecha ISO de la IA (`2026-11-10`) como `10/11/2026`; si no se puede
/// leer, se muestra tal cual.
String aiDate(String raw) {
  final d = DateTime.tryParse(raw);
  return d == null ? raw : DateFormat('dd/MM/yyyy').format(d);
}
