// Clinexapp Design System — estilo neón de la IA.
//
// Solo lo que hace la IA lleva este estilo, para que se distinga a simple
// vista (mismo criterio que el panel web: `ai-surface`, `ai-button`,
// `ai-text`, `ai-line` en panel-react/src/index.css).
// Degradado frío de ida y vuelta (turquesa → azul → violeta → azul →
// turquesa): al animarse y repetirse no hay salto entre tramos.
//
// Con "reducir movimiento" activado en el teléfono, nada se anima.
//
// Idéntico en las dos apps.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../clinexapp_tokens.dart';
import 'clx_palette.dart';

/// Colores y sombras del neón.
class ClxNeon {
  ClxNeon._();

  static const colors = <Color>[
    Color(0xFF00C4AC),
    Color(0xFF1FB6E0),
    Color(0xFF2B8DDB),
    Color(0xFF0875C9),
    Color(0xFF3D63E6),
    Color(0xFF5B4FF0),
    Color(0xFF3D63E6),
    Color(0xFF0875C9),
    Color(0xFF2B8DDB),
    Color(0xFF1FB6E0),
    Color(0xFF00C4AC),
  ];

  /// Fondo de los botones de IA, igual en ambos temas.
  static const ink = Color(0xFF0A1226);

  static List<BoxShadow> glow(bool dark, {bool strong = false}) {
    if (dark) {
      return [
        BoxShadow(color: const Color(0xFF7A6EFF).withValues(alpha: strong ? 0.5 : 0.35), spreadRadius: 1),
        BoxShadow(color: const Color(0xFF00E5C8).withValues(alpha: strong ? 0.75 : 0.55), blurRadius: strong ? 30 : 24, spreadRadius: strong ? -4 : -6),
        BoxShadow(color: const Color(0xFF7A6EFF).withValues(alpha: 0.6), blurRadius: strong ? 48 : 36, spreadRadius: strong ? -8 : -10),
      ];
    }
    return [
      BoxShadow(color: const Color(0xFF5B4FF0).withValues(alpha: strong ? 0.3 : 0.18), spreadRadius: 1),
      BoxShadow(color: const Color(0xFF00C4AC).withValues(alpha: strong ? 0.7 : 0.55), offset: Offset(0, strong ? 8 : 6), blurRadius: strong ? 28 : 22, spreadRadius: strong ? -6 : -8),
      BoxShadow(color: const Color(0xFF5B4FF0).withValues(alpha: 0.55), offset: Offset(0, strong ? 14 : 10), blurRadius: strong ? 40 : 30, spreadRadius: strong ? -10 : -12),
    ];
  }

  /// Degradado desplazado según [t] (0..1): el equivalente a `neon-flow`.
  static LinearGradient gradient(double t) => LinearGradient(
        colors: colors,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        tileMode: TileMode.repeated,
        transform: _Slide(t),
      );
}

class _Slide extends GradientTransform {
  const _Slide(this.t);
  final double t;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    // Inclinación de 115° como en la web y desplazamiento de un ancho completo.
    final w = bounds.width;
    return Matrix4.identity()
      ..translateByDouble(bounds.left + w * 2 * t - w, bounds.top, 0, 1)
      ..rotateZ((115 - 90) * math.pi / 180)
      ..scaleByDouble(2, 1, 1, 1)
      ..translateByDouble(-bounds.left, -bounds.top, 0, 1);
  }
}

bool _reduceMotion(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Animación continua compartida por los widgets neón.
class _NeonTicker extends StatefulWidget {
  const _NeonTicker({required this.builder, this.period = const Duration(seconds: 8)});

  final Widget Function(BuildContext context, double t) builder;
  final Duration period;

  @override
  State<_NeonTicker> createState() => _NeonTickerState();
}

class _NeonTickerState extends State<_NeonTicker> with SingleTickerProviderStateMixin {
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
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) => widget.builder(context, _c.value),
      );
}

/// Tarjeta de IA: borde degradado animado de 1.5 px y brillo suave.
class ClxAiSurface extends StatelessWidget {
  const ClxAiSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(ClxSpace.s5),
    this.radius = ClxRadius.lg,
    this.onTap,
    this.glow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final inner = BorderRadius.circular(radius - 1.5);
    return _NeonTicker(
      builder: (context, t) => Container(
        decoration: BoxDecoration(
          gradient: ClxNeon.gradient(t),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: glow ? ClxNeon.glow(c.isDark) : null,
        ),
        padding: const EdgeInsets.all(1.5),
        child: Material(
          color: c.surfaceRaised,
          borderRadius: inner,
          clipBehavior: Clip.antiAlias,
          child: onTap == null ? Padding(padding: padding, child: child) : InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
        ),
      ),
    );
  }
}

/// Botón de IA: fondo tinta, borde neón animado, texto claro y destello.
class ClxAiButton extends StatefulWidget {
  const ClxAiButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = LucideIcons.sparkles,
    this.loading = false,
    this.loadingLabel,
    this.expand = true,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool loading;

  /// Texto mientras la IA trabaja ("Analizando…").
  final String? loadingLabel;
  final bool expand;

  /// Versión baja (40 px) para tarjetas y barras.
  final bool compact;

  @override
  State<ClxAiButton> createState() => _ClxAiButtonState();
}

class _ClxAiButtonState extends State<ClxAiButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final enabled = widget.onPressed != null && !widget.loading;
    final height = widget.compact ? 40.0 : 52.0;
    final radius = BorderRadius.circular(ClxRadius.md);

    final label = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.loading)
          const ClxAiSpark(size: 18)
        else
          Icon(widget.icon, size: widget.compact ? 16 : 18, color: Colors.white),
        const SizedBox(width: ClxSpace.s2),
        Flexible(
          child: Text(
            widget.loading ? (widget.loadingLabel ?? widget.label) : widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.geist(fontSize: widget.compact ? 14 : 15, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ],
    );

    final button = _NeonTicker(
      period: const Duration(seconds: 6),
      builder: (context, t) => AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            gradient: ClxNeon.gradient(t),
            borderRadius: radius,
            boxShadow: enabled || widget.loading ? ClxNeon.glow(c.isDark, strong: _pressed || widget.loading) : null,
          ),
          padding: const EdgeInsets.all(1.5),
          child: Material(
            color: ClxNeon.ink,
            borderRadius: BorderRadius.circular(ClxRadius.md - 1.5),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: enabled ? widget.onPressed : null,
              onHighlightChanged: (v) => setState(() => _pressed = v),
              splashColor: const Color(0x335B4FF0),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.compact ? ClxSpace.s3 : ClxSpace.s5),
                child: Center(widthFactor: 1, child: label),
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled || widget.loading ? 1 : 0.5,
        child: widget.expand ? SizedBox(width: double.infinity, child: button) : button,
      ),
    );
  }
}

/// Texto con el degradado neón animado (títulos y cifras de IA, 18 px o más).
class ClxAiText extends StatelessWidget {
  const ClxAiText(this.text, {super.key, this.style, this.textAlign, this.maxLines});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final base = style ?? context.clxText.h2;
    return _NeonTicker(
      builder: (context, t) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (rect) => ClxNeon.gradient(t).createShader(rect),
        child: Text(text, style: base.copyWith(color: Colors.white), textAlign: textAlign, maxLines: maxLines),
      ),
    );
  }
}

/// Línea fina de degradado. Con [indeterminate] es una barra de progreso.
class ClxAiLine extends StatelessWidget {
  const ClxAiLine({super.key, this.height = 3, this.value});

  final double height;

  /// Progreso 0..1; null = solo la línea animada.
  final double? value;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    return ClipRRect(
      borderRadius: BorderRadius.circular(ClxRadius.pill),
      child: Container(
        height: height,
        color: c.surfaceSunken,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value?.clamp(0.0, 1.0) ?? 1,
          child: _NeonTicker(
            period: const Duration(seconds: 3),
            builder: (context, t) => DecoratedBox(decoration: BoxDecoration(gradient: ClxNeon.gradient(t))),
          ),
        ),
      ),
    );
  }
}

/// Destello de IA que gira y late (se usa mientras la IA trabaja).
class ClxAiSpark extends StatefulWidget {
  const ClxAiSpark({super.key, this.size = 20});
  final double size;

  @override
  State<ClxAiSpark> createState() => _ClxAiSparkState();
}

class _ClxAiSparkState extends State<ClxAiSpark> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

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
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        final pulse = 0.85 + 0.15 * math.sin(t * 2 * math.pi);
        return Transform.rotate(
          angle: t * 2 * math.pi * 0.25,
          child: Transform.scale(
            scale: pulse,
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (rect) => ClxNeon.gradient(t).createShader(rect),
              child: Icon(LucideIcons.sparkles, size: widget.size, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}

/// Estado "la IA está trabajando": destello animado, mensajes que rotan y
/// línea neón. Úsalo en lugar de un spinner en cualquier espera de IA.
class ClxAiThinking extends StatefulWidget {
  const ClxAiThinking({super.key, required this.messages, this.title = 'La IA está trabajando'});

  final String title;

  /// Pasos que se van mostrando ("Leyendo criterios…", "Comparando con el caso…").
  final List<String> messages;

  @override
  State<ClxAiThinking> createState() => _ClxAiThinkingState();
}

class _ClxAiThinkingState extends State<ClxAiThinking> {
  int _i = 0;
  late final Stream<int> _ticks = Stream.periodic(const Duration(milliseconds: 2200), (i) => i + 1);

  @override
  Widget build(BuildContext context) {
    final t = context.clxText;
    return ClxAiSurface(
      child: StreamBuilder<int>(
        stream: _ticks,
        builder: (context, snap) {
          if (snap.hasData && widget.messages.isNotEmpty) _i = snap.data! % widget.messages.length;
          final msg = widget.messages.isEmpty ? '' : widget.messages[_i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const ClxAiSpark(size: 22),
                  const SizedBox(width: ClxSpace.s3),
                  Expanded(child: ClxAiText(widget.title, style: t.h3)),
                ],
              ),
              const SizedBox(height: ClxSpace.s3),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(anim), child: child),
                ),
                child: Text(msg, key: ValueKey(msg), style: t.bodySm),
              ),
              const SizedBox(height: ClxSpace.s4),
              const ClxAiLine(),
            ],
          );
        },
      ),
    );
  }
}

/// Insignia neón "IA" (o el texto que se indique) para marcar contenido de IA.
class ClxAiTag extends StatelessWidget {
  const ClxAiTag({super.key, this.label = 'Sugerido por IA'});
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    return _NeonTicker(
      builder: (context, t) => Container(
        padding: const EdgeInsets.all(1.2),
        decoration: BoxDecoration(gradient: ClxNeon.gradient(t), borderRadius: BorderRadius.circular(ClxRadius.pill)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(color: c.surfaceRaised, borderRadius: BorderRadius.circular(ClxRadius.pill)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.sparkles, size: 12, color: c.accentViolet),
              const SizedBox(width: 5),
              Text(label, style: GoogleFonts.geist(fontSize: 12, fontWeight: FontWeight.w600, color: c.accentViolet)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Aviso fijo bajo cualquier resultado de IA.
class ClxAiDisclaimer extends StatelessWidget {
  const ClxAiDisclaimer({super.key, this.text = 'Sugerencia de la IA. Revísala: la decisión es tuya.'});
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: 2), child: Icon(LucideIcons.info, size: 14, color: c.inkSubtle)),
        const SizedBox(width: ClxSpace.s2),
        Expanded(child: Text(text, style: context.clxText.bodySm.copyWith(fontSize: 12.5, color: c.inkSubtle))),
      ],
    );
  }
}

/// Aparición escalonada de resultados de IA (desvanecido + leve subida).
class ClxAiReveal extends StatelessWidget {
  const ClxAiReveal({super.key, required this.child, this.index = 0});

  final Widget child;

  /// Posición en la lista: cada elemento entra 70 ms después del anterior.
  final int index;

  @override
  Widget build(BuildContext context) {
    if (_reduceMotion(context)) return child;
    final delay = (index * 70).clamp(0, 700);
    final total = 320 + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delay / total, 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 12), child: child),
      ),
    );
  }
}

/// Indicador circular de ajuste (0-100) con arco neón animado al aparecer.
class ClxAiScore extends StatelessWidget {
  const ClxAiScore({super.key, required this.score, this.size = 72, this.label = 'ajuste'});

  final int score;
  final double size;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final reduce = _reduceMotion(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduce ? score / 100 : 0, end: score.clamp(0, 100) / 100),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(size: Size.square(size), painter: _ScorePainter(v, c.surfaceSunken)),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${(v * 100).round()}', style: context.clxText.dataLg.copyWith(fontSize: size * 0.3, height: 1)),
                Text(label, style: context.clxText.bodySm.copyWith(fontSize: 10.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScorePainter extends CustomPainter {
  _ScorePainter(this.value, this.track);
  final double value;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 6.0;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    canvas.drawArc(arcRect, 0, 2 * math.pi, false, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [Color(0xFF00C4AC), Color(0xFF0875C9), Color(0xFF5B4FF0), Color(0xFF00C4AC)],
        transform: GradientRotation(-math.pi / 2),
      ).createShader(rect);
    canvas.drawArc(arcRect, -math.pi / 2, 2 * math.pi * value, false, paint);
  }

  @override
  bool shouldRepaint(_ScorePainter old) => old.value != value || old.track != track;
}
