// Clinexapp Design System — piezas de IA agregadas desde la app Investigador
// (receptor): texto que se escribe solo, acceso a una función de IA y
// sugerencias de preguntas. Complementan clx_ai.dart con el mismo estilo
// neón. Son genéricas: si la app Derivante las necesita, copia este archivo
// tal cual y expórtalo desde clx_ui.dart.
//
// Desde la app Derivante se agregan la onda de voz y el botón de
// micrófono del dictado y el botón de ícono de IA.
//
// Con "reducir movimiento" activado en el teléfono, nada se anima.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../clinexapp_tokens.dart';
import 'clx_ai.dart';
import 'clx_palette.dart';

bool _reduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Texto de una respuesta de IA que se va revelando, como si se escribiera.
///
/// Reserva desde el principio el alto del texto completo (no hay saltos de
/// diseño mientras se escribe) y los lectores de pantalla leen el texto
/// entero. Con [animate] en false, o con "reducir movimiento", se muestra
/// completo de inmediato.
class ClxAiTypewriter extends StatefulWidget {
  const ClxAiTypewriter(
    this.text, {
    super.key,
    this.style,
    this.animate = true,
    this.onDone,
    this.charDuration = const Duration(milliseconds: 14),
    this.maxDuration = const Duration(milliseconds: 2200),
  });

  final String text;
  final TextStyle? style;
  final bool animate;

  /// Se llama una vez, cuando el texto quedó completo.
  final VoidCallback? onDone;

  /// Tiempo por carácter, con tope total [maxDuration].
  final Duration charDuration;
  final Duration maxDuration;

  @override
  State<ClxAiTypewriter> createState() => _ClxAiTypewriterState();
}

class _ClxAiTypewriterState extends State<ClxAiTypewriter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this);
  bool _started = false;
  bool _notified = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (!widget.animate || _reduceMotion(context) || widget.text.isEmpty) {
      _c.value = 1;
      _done();
      return;
    }
    final ms = (widget.charDuration.inMilliseconds * widget.text.length).clamp(
      300,
      widget.maxDuration.inMilliseconds,
    );
    _c.duration = Duration(milliseconds: ms);
    _c.forward().whenComplete(_done);
  }

  void _done() {
    if (_notified) return;
    _notified = true;
    final cb = widget.onDone;
    if (cb != null) WidgetsBinding.instance.addPostFrameCallback((_) => cb());
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? context.clxText.body;
    return Semantics(
      label: widget.text,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final n = (widget.text.length * _c.value).round();
            final shown = widget.text.substring(0, n);
            final typing = n < widget.text.length;
            return Stack(
              children: [
                // Ocupa el lugar del texto completo.
                Text(
                  widget.text,
                  style: style.copyWith(color: Colors.transparent),
                ),
                Text.rich(
                  TextSpan(
                    text: shown,
                    style: style,
                    children: [
                      if (typing)
                        TextSpan(
                          text: ' ▍',
                          style: style.copyWith(
                            color: context.clx.accentViolet,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Acceso a una función de IA: superficie neón con destello, título,
/// descripción y flecha. Para tarjetas de entrada ("Pregúntale a la IA").
class ClxAiEntryCard extends StatelessWidget {
  const ClxAiEntryCard({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.icon = LucideIcons.sparkles,
    this.glow = true,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final IconData icon;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final t = context.clxText;
    return Semantics(
      button: true,
      label: subtitle == null ? title : '$title. $subtitle',
      excludeSemantics: true,
      child: ClxAiSurface(
        glow: glow,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: ClxSpace.s4,
          vertical: ClxSpace.s3,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ClxNeon.ink,
                borderRadius: BorderRadius.circular(ClxRadius.md),
              ),
              alignment: Alignment.center,
              child: icon == LucideIcons.sparkles
                  ? const ClxAiSpark(size: 20)
                  : Icon(icon, size: 20, color: Colors.white),
            ),
            const SizedBox(width: ClxSpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClxAiText(title, style: t.h3, maxLines: 1),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: t.bodySm),
                  ],
                ],
              ),
            ),
            const SizedBox(width: ClxSpace.s2),
            Icon(LucideIcons.chevronRight, size: 18, color: c.inkSubtle),
          ],
        ),
      ),
    );
  }
}

/// Pregunta sugerida por la IA (o inicial): píldora con borde violeta.
class ClxAiSuggestion extends StatelessWidget {
  const ClxAiSuggestion({
    super.key,
    required this.label,
    required this.onTap,
    this.icon = LucideIcons.messageCircleQuestion,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final radius = BorderRadius.circular(ClxRadius.lg);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: c.accentVioletSoft,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(
              horizontal: ClxSpace.s3,
              vertical: ClxSpace.s2,
            ),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: c.accentViolet.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15, color: c.accentViolet),
                const SizedBox(width: ClxSpace.s2),
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.geist(
                      fontSize: 13.5,
                      height: 18 / 13.5,
                      fontWeight: FontWeight.w500,
                      color: c.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Animación continua (0..1) que se detiene con "reducir movimiento".
class _Loop extends StatefulWidget {
  const _Loop({required this.period, required this.builder});

  final Duration period;
  final Widget Function(BuildContext context, double t) builder;

  @override
  State<_Loop> createState() => _LoopState();
}

class _LoopState extends State<_Loop> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reduceMotion(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (context, _) => widget.builder(context, _c.value),
  );
}

/// Onda de voz neón para el dictado: barras que laten con el nivel del
/// micrófono ([level], 0..1). Sin [active] queda quieta y apagada.
class ClxAiVoiceWave extends StatelessWidget {
  const ClxAiVoiceWave({
    super.key,
    this.level = 0.4,
    this.active = true,
    this.height = 44,
    this.bars = 21,
  });

  final double level;
  final bool active;
  final double height;
  final int bars;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    return _Loop(
      period: const Duration(milliseconds: 1400),
      builder: (context, t) {
        final reduce = _reduceMotion(context);
        final l = active ? (0.25 + level.clamp(0.0, 1.0) * 0.75) : 0.0;
        return SizedBox(
          height: height,
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (rect) => ClxNeon.gradient(t).createShader(rect),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < bars; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: _barHeight(i, t, l, reduce),
                    decoration: BoxDecoration(
                      color: active ? Colors.white : c.borderStrong,
                      borderRadius: BorderRadius.circular(ClxRadius.pill),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _barHeight(int i, double t, double l, bool reduce) {
    const min = 4.0;
    if (l == 0) return min;
    // Envolvente: más alta al centro.
    final center = (bars - 1) / 2;
    final env = 1 - ((i - center).abs() / (center + 1)) * 0.65;
    final phase = reduce
        ? 0.6
        : (0.5 + 0.5 * math.sin(t * 2 * math.pi * 2 + i * 0.9));
    return min + (height - min) * env * l * (0.35 + 0.65 * phase);
  }
}

/// Botón redondo de micrófono con anillos neón que laten mientras escucha.
class ClxAiMicButton extends StatelessWidget {
  const ClxAiMicButton({
    super.key,
    required this.listening,
    required this.onPressed,
    required this.tooltip,
    this.size = 72,
    this.level = 0.5,
  });

  final bool listening;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;
  final double level;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    return Semantics(
      button: true,
      label: tooltip,
      excludeSemantics: true,
      child: Tooltip(
        message: tooltip,
        child: _Loop(
          period: const Duration(milliseconds: 1800),
          builder: (context, t) {
            final ring = size * 0.5;
            return SizedBox(
              width: size + ring,
              height: size + ring,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (listening)
                    for (final offset in const [0.0, 0.5])
                      Builder(
                        builder: (context) {
                          final p = (t + offset) % 1;
                          return Opacity(
                            opacity:
                                (1 - p) * (0.35 + level.clamp(0.0, 1.0) * 0.4),
                            child: Container(
                              width: size + ring * p,
                              height: size + ring * p,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: ClxNeon.gradient(t),
                              ),
                            ),
                          );
                        },
                      ),
                  Container(
                    width: size,
                    height: size,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: ClxNeon.gradient(t),
                      boxShadow: ClxNeon.glow(c.isDark, strong: listening),
                    ),
                    child: Material(
                      color: ClxNeon.ink,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: onPressed,
                        child: Center(
                          child: Icon(
                            listening ? LucideIcons.square : LucideIcons.mic,
                            size: size * 0.36,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Botón de ícono de IA (44 × 44) con borde neón, para barras y cabeceras.
class ClxAiIconButton extends StatelessWidget {
  const ClxAiIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.size = 44,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    return Semantics(
      button: true,
      label: tooltip,
      excludeSemantics: true,
      child: Tooltip(
        message: tooltip,
        child: _Loop(
          period: const Duration(seconds: 6),
          builder: (context, t) => Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              gradient: ClxNeon.gradient(t),
              borderRadius: BorderRadius.circular(ClxRadius.md),
              boxShadow: ClxNeon.glow(c.isDark),
            ),
            child: Material(
              color: ClxNeon.ink,
              borderRadius: BorderRadius.circular(ClxRadius.md - 1.5),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onPressed,
                child: Center(
                  child: Icon(icon, size: size * 0.45, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
