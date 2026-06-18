// Photo carousel for the court detail screen: swipeable hero strip, the
// painted placeholder hero (when a court has no photos) and the floating
// overlay buttons. Extracted from court_detail_screen.dart.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PhotoCarousel extends StatelessWidget {
  const PhotoCarousel({
    super.key,
    required this.photos,
    required this.controller,
    required this.currentPage,
    required this.onPageChanged,
  });

  final List<String> photos;
  final PageController controller;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final count = photos.isEmpty ? 1 : photos.length;
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 280,
          child: photos.isEmpty
              ? _PlaceholderHero()
              : PageView.builder(
                  controller: controller,
                  onPageChanged: onPageChanged,
                  itemCount: photos.length,
                  itemBuilder: (_, i) => Image.network(
                    photos[i],
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : _PlaceholderHero(),
                    errorBuilder: (_, __, ___) => _PlaceholderHero(),
                  ),
                ),
        ),
        // Back + action buttons
        Positioned(
          top: 56,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _OverlayIconBtn(
                onPressed: () => context.pop(),
                icon: Icons.arrow_back_ios_new,
              ),
              Row(
                children: [
                  _OverlayIconBtn(
                    onPressed: () {},
                    icon: Icons.favorite_border,
                  ),
                  const SizedBox(width: 8),
                  _OverlayIconBtn(onPressed: () {}, icon: Icons.share_outlined),
                ],
              ),
            ],
          ),
        ),
        // Page indicator dots
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == currentPage ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == currentPage
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(99),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _PlaceholderHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16A34A), Color(0xFF0EA5E9)],
        ),
      ),
      child: CustomPaint(painter: _CourtLinesPainter()),
    );
  }
}

class _OverlayIconBtn extends StatelessWidget {
  const _OverlayIconBtn({required this.onPressed, required this.icon});

  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF111827)),
      ),
    );
  }
}

class _CourtLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final double left = size.width * 0.1;
    final double right = size.width * 0.9;
    final double top = size.height * 0.2;
    final double bottom = size.height * 0.8;
    final double midX = size.width / 2;
    final double midY = (top + bottom) / 2;

    canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);
    canvas.drawLine(Offset(midX, top), Offset(midX, bottom), paint);
    canvas.drawCircle(Offset(midX, midY), 34, paint);
    canvas.drawRect(
      Rect.fromLTRB(left, top + 30, left + 50, bottom - 30),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTRB(right - 50, top + 30, right, bottom - 30),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
