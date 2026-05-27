import 'package:flutter/material.dart';

class CourtLinesPainter extends CustomPainter {
  const CourtLinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / 390;
    final double scaleY = size.height / 220;

    final paint1 = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path1 = Path()
      ..moveTo(0 * scaleX, 200 * scaleY)
      ..lineTo(200 * scaleX, 60 * scaleY)
      ..lineTo(390 * scaleX, 140 * scaleY);
    canvas.drawPath(path1, paint1);

    final paint2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path2 = Path()
      ..moveTo(0 * scaleX, 160 * scaleY)
      ..lineTo(250 * scaleX, 30 * scaleY)
      ..lineTo(390 * scaleX, 100 * scaleY);
    canvas.drawPath(path2, paint2);

    final paintCircle1 = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(
        Offset(320 * scaleX, 40 * scaleY), 80 * scaleX, paintCircle1);

    final paintCircle2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(
        Offset(60 * scaleX, 180 * scaleY), 40 * scaleX, paintCircle2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
