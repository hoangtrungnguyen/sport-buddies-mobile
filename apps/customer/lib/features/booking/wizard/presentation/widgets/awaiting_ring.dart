// 140px animated clock progress ring shown while a booking awaits owner
// confirmation (doc 02 §3.1). Extracted from step_3_awaiting.dart.

import 'dart:math' as math;

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// 140px clock progress ring — tertiary on tertiaryContainer (doc 02 §3.1).
class AwaitingRing extends StatefulWidget {
  const AwaitingRing({super.key});

  @override
  State<AwaitingRing> createState() => _AwaitingRingState();
}

class _AwaitingRingState extends State<AwaitingRing>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (reduced) {
      _ctrl?.dispose();
      _ctrl = null;
    } else {
      _ctrl ??= AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const size = 140.0;

    final clock = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // outer disc
          Container(
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              shape: BoxShape.circle,
            ),
          ),
          // inner disc with clock glyph
          Container(
            width: size - 36,
            height: size - 36,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              shape: BoxShape.circle,
            ),
            child: CustomPaint(painter: _ClockPainter(scheme.tertiary)),
          ),
          // 12 o'clock orbiting dot
          _ctrl == null
              ? _topDot(scheme)
              : AnimatedBuilder(
                  animation: _ctrl!,
                  builder: (_, child) => Transform.rotate(
                    angle: _ctrl!.value * 2 * math.pi,
                    child: child,
                  ),
                  child: _topDot(scheme),
                ),
        ],
      ),
    );

    return Semantics(
      liveRegion: true,
      label: AppLocalizations.of(context).wizardAwaitingSemantic,
      child: clock,
    );
  }

  Widget _topDot(ColorScheme scheme) => Align(
    alignment: Alignment.topCenter,
    child: Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: scheme.tertiary, shape: BoxShape.circle),
    ),
  );
}

class _ClockPainter extends CustomPainter {
  _ClockPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width * 0.28;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, r, paint);
    // hands
    canvas.drawLine(center, center + Offset(0, -r * 0.6), paint);
    canvas.drawLine(center, center + Offset(r * 0.45, 0), paint);
  }

  @override
  bool shouldRepaint(_ClockPainter old) => old.color != color;
}
