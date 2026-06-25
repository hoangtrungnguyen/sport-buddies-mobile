import 'package:flutter/material.dart';

/// Deterministic faux QR (squares + three finder patterns) standing in for a
/// real VietQR/MoMo code — a 1:1 port of the handoff's `FauxQR`. Replace with a
/// real generated QR once the gateway provides a payload.
class FauxQr extends StatelessWidget {
  const FauxQr({super.key, this.size = 132, this.seed = 8, required this.color});

  final double size;
  final int seed;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.square(size),
        isComplex: true,
        painter: _FauxQrPainter(seed: seed, color: color),
      );
}

class _FauxQrPainter extends CustomPainter {
  _FauxQrPainter({required this.seed, required this.color});

  final int seed;
  final Color color;

  static const int _n = 25;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / _n;
    final fill = Paint()..color = color;
    final white = Paint()..color = const Color(0xFFFFFFFF);

    canvas.drawRect(Offset.zero & size, white);

    // Same LCG + threshold as the prototype so the pattern matches exactly.
    var s = seed * 1000 + 7;
    double rnd() {
      s = (s * 9301 + 49297) % 233280;
      return s / 233280;
    }

    bool isFinder(int r, int c) =>
        (r < 7 && c < 7) ||
        (r < 7 && c >= _n - 7) ||
        (r >= _n - 7 && c < 7);

    for (var r = 0; r < _n; r++) {
      for (var c = 0; c < _n; c++) {
        if (isFinder(r, c)) continue; // finder cells skip the rng draw
        if (rnd() > 0.52) {
          canvas.drawRect(Rect.fromLTWH(c * cell, r * cell, cell, cell), fill);
        }
      }
    }

    void finder(double gx, double gy) {
      canvas.drawRect(Rect.fromLTWH(gx, gy, cell * 7, cell * 7), fill);
      canvas.drawRect(
          Rect.fromLTWH(gx + cell, gy + cell, cell * 5, cell * 5), white);
      canvas.drawRect(
          Rect.fromLTWH(gx + cell * 2, gy + cell * 2, cell * 3, cell * 3), fill);
    }

    finder(0, 0);
    finder(cell * (_n - 7), 0);
    finder(0, cell * (_n - 7));
  }

  @override
  bool shouldRepaint(_FauxQrPainter old) =>
      old.seed != seed || old.color != color;
}
