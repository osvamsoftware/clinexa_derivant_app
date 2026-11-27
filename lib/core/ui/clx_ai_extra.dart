// Clinexapp Design System — componentes de IA adicionales (estilo neón).
//
// Complementan clx_ai.dart: escritura animada de respuestas, onda de voz
// para el dictado, botón de micrófono y botón de ícono de IA. Mismo
// degradado (`ClxNeon`) y misma regla: solo para lo que hace la IA.
//
// Con "reducir movimiento" activado en el teléfono, nada se anima.
//
// Pensado para ser idéntico en las dos apps.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../clinexapp_tokens.dart';
import 'clx_ai.dart';
import 'clx_palette.dart';

bool _reduceMotion(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Animación continua (0..1) que se detiene con "reducir movimiento".
class _Loop extends StatefulWidget {
  const _Loop({required this.period, required this.builder});

  final Duration period;
  final Widget Function(BuildContext context, double t) builder;

  @override
  State<_Loop> createState() => _LoopState();
}

class _LoopState extends State<_Loop> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.period);

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
  Widget build(BuildContext context) => AnimatedBuilder(animation: _c, builder: (context, _) => widget.builder(context, _c.value));
}

/// Texto de una respuesta de IA que se va revelando como si se escribiera.
///
/// Con [animate] en false (mensajes ya leídos) o con "reducir movimiento",
/// se muestra completo. La velocidad se ajusta para que ningún texto tarde
/// más de [maxDuration].
class ClxAiTypewriter extends StatefulWidget {
  const ClxAiTypewriter(
    this.text, {
    super.key,
    this.style,
    this.animate = true,
    this.maxDuration = const Duration(milliseconds: 2200),
    this.onDone,
  });

  final String text;
  final TextStyle? style;
  final bool animate;
  final Duration maxDuration;
  final VoidCallback? onDone;

  @override
  State<ClxAiTypewriter> createState() => _ClxAiTypewriterState();
}

class _ClxAiTypewriterState extends State<ClxAiTypewriter> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (!widget.animate || _reduceMotion(context) || widget.text.isEmpty) {
      _c.value = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onDone?.call());
      return;
    }
    final ms = (widget.text.length * 18).clamp(300, widget.maxDuration.inMilliseconds);
    _c.duration = Duration(milliseconds: ms);
    _c.forward().whenComplete(() {
      if (mounted) widget.onDone?.call();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? context.clxText.body;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final n = (widget.text.length * _c.value).round();
        final done = n >= widget.text.length;
        // El resto del texto ocupa su lugar (transparente) para que la
        // burbuja no cambie de alto mientras se escribe.
        return Semantics(
          label: widget.text,
          excludeSemantics: true,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: widget.text.substring(0, n)),
                if (!done) ...[
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      width: 2,
                      height: (style.fontSize ?? 15) * 1.1,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(gradient: ClxNeon.gradient(_c.value), borderRadius: BorderRadius.circular(1)),
                    ),
                  ),
                  TextSpan(text: widget.text.substring(n), style: const TextStyle(color: Colors.transparent)),
                ],
              ],
            ),
            style: style,
          ),
        );
      },
    );
  }
}

/// Onda de voz neón para el dictado: barras que laten con el nivel del
/// micrófono ([level], 0..1). Sin [active] queda quieta y apagada.
class ClxAiVoiceWave extends StatelessWidget {
  const ClxAiVoiceWave({super.key, this.level = 0.4, this.active = true, this.height = 44, this.bars = 21});

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
    final phase = reduce ? 0.6 : (0.5 + 0.5 * math.sin(t * 2 * math.pi * 2 + i * 0.9));
    return min + (height - min) * env * l * (0.35 + 0.65 * phase);
  }
}

/// Botón redondo de micrófono con anillos neón que laten mientras escucha.
class ClxAiMicButton extends StatelessWidget {
  const ClxAiMicButton({super.key, required this.listening, required this.onPressed, required this.tooltip, this.size = 72, this.level = 0.5});

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
                      Builder(builder: (context) {
                        final p = (t + offset) % 1;
                        return Opacity(
                          opacity: (1 - p) * (0.35 + level.clamp(0.0, 1.0) * 0.4),
                          child: Container(
                            width: size + ring * p,
                            height: size + ring * p,
                            decoration: BoxDecoration(shape: BoxShape.circle, gradient: ClxNeon.gradient(t)),
                          ),
                        );
                      }),
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
                          child: Icon(listening ? LucideIcons.square : LucideIcons.mic, size: size * 0.36, color: Colors.white),
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
  const ClxAiIconButton({super.key, required this.icon, required this.onPressed, required this.tooltip, this.size = 44});

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
                child: Center(child: Icon(icon, size: size * 0.45, color: Colors.white)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
