import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import 'day_grid_metrics.dart';

/// In-flight drag-to-block on one venue column.
class DayDrag {
  DayDrag({
    required this.venueId,
    required this.startHour,
    required this.currentHour,
  });

  final String venueId;
  final double startHour;
  double currentHour;
}

/// 1px n-100 hairline at the bottom of every 60px hour row — the
/// `repeating-linear-gradient` background of `.day-col`.
class HourLinesPainter extends CustomPainter {
  const HourLinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neutral100
      ..strokeWidth = 1;
    for (var row = 1; row <= kRowCount; row++) {
      final y = row * kHourPx - 0.5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(HourLinesPainter oldDelegate) => false;
}

/// `.drag-band` paint: 45° indigo stripes (`rgba(99,102,241,.18)`/`.3`, 6px
/// bands) inside an 8px rounded rect with a 1.5px dashed `#6366F1` border.
class DragBandPainter extends CustomPainter {
  const DragBandPainter();

  static const Color _stripeA = Color(0x2E6366F1); // rgba(99,102,241,.18)
  static const Color _stripeB = Color(0x4D6366F1); // rgba(99,102,241,.30)
  static const Color _borderColor = Color(0xFF6366F1);
  static const double _bandWidth = 6;
  static const double _dashLength = 4;
  static const double _gapLength = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));

    // Base coat + 45° darker bands (same construction as the slot stripes).
    canvas
      ..save()
      ..clipRRect(rrect)
      ..drawRect(rect, Paint()..color = _stripeA)
      ..translate(rect.center.dx, rect.center.dy)
      // CSS angle is clockwise from north; canvas rotation is from +x.
      ..rotate((45 - 90) * math.pi / 180);
    final reach = size.longestSide;
    const period = _bandWidth * 2;
    final bandPaint = Paint()..color = _stripeB;
    for (var x = -(reach / period).ceil() * period; x < reach; x += period) {
      canvas.drawRect(
        Rect.fromLTRB(x + _bandWidth, -reach, x + period, reach),
        bandPaint,
      );
    }
    canvas.restore();

    // 1.5px dashed border.
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = _borderColor;
    final source = Path()..addRRect(rrect.deflate(0.75));
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(
            distance,
            math.min(distance + _dashLength, metric.length),
          ),
          borderPaint,
        );
        distance += _dashLength + _gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(DragBandPainter oldDelegate) => false;
}
