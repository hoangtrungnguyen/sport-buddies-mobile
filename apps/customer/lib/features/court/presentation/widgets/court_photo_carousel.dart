// Court detail photo carousel: paged hero with placeholder court-lines art,
// page dots and floating back/favorite/share buttons. Extracted from
// court_detail_page.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_tokens.dart';

class PhotoCarousel extends StatelessWidget {
  const PhotoCarousel({
    super.key,
    required this.photoCount,
    required this.index,
    required this.isFavorite,
    required this.onIndex,
    required this.onFavorite,
  });

  final int photoCount;
  final int index;
  final bool isFavorite;
  final ValueChanged<int> onIndex;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: photoCount,
            onPageChanged: onIndex,
            itemBuilder: (_, i) => _CourtPhotoPlaceholder(
              label: AppLocalizations.of(
                context,
              ).courtDetailPhoto(i + 1, photoCount),
            ),
          ),
          Positioned(
            top: top + 12,
            left: 12,
            right: 12,
            child: Row(
              children: [
                _FloatingIconButton(
                  icon: Icons.arrow_back,
                  tooltip: l10n.commonBack,
                  onTap: () => context.pop(),
                ),
                const Spacer(),
                _FloatingIconButton(
                  icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                  tooltip: l10n.courtDetailFavorite,
                  onTap: onFavorite,
                ),
                const SizedBox(width: 8),
                _FloatingIconButton(
                  icon: Icons.ios_share,
                  tooltip: l10n.courtDetailShare,
                  onTap: () {},
                ),
              ],
            ),
          ),
          if (photoCount > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < photoCount; i++)
                    AnimatedContainer(
                      duration: AppTokens.motionMed,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: i == index ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: i == index ? 1 : 0.6,
                        ),
                        borderRadius: AppTokens.radiusFull,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CourtPhotoPlaceholder extends StatelessWidget {
  const _CourtPhotoPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16A34A), Color(0xFF0EA5E9)],
        ),
      ),
      child: CustomPaint(
        painter: _CourtLinesPainter(),
        child: Center(
          child: Text(
            '[ $label ]',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}

class _CourtLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final r = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.21,
      size.width * 0.8,
      size.height * 0.6,
    );
    canvas.drawRect(r, p);
    canvas.drawLine(
      Offset(r.center.dx, r.top),
      Offset(r.center.dx, r.bottom),
      p,
    );
    canvas.drawCircle(r.center, size.height * 0.12, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FloatingIconButton extends StatelessWidget {
  const _FloatingIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: tooltip,
      child: Material(
        color: scheme.surfaceContainerLow,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 20, color: scheme.onSurface),
          ),
        ),
      ),
    );
  }
}
