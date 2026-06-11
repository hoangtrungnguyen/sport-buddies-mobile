import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_theme.dart';

/// Court lifecycle status, drives the overlaid status chip on cards/forms.
enum CourtChipStatus { active, pending, draft, inactive }

/// M3 status chip — 26px tall, radius 8, never wraps. Color role + icon per the
/// handoff: active → primaryContainer + check_circle; pending → warnContainer +
/// hourglass_top; draft → surfaceContainerHighest + edit_note.
class CourtStatusChip extends StatelessWidget {
  const CourtStatusChip({super.key, required this.status, this.elevated = false});

  final CourtChipStatus status;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final snb = Theme.of(context).extension<SnbColors>()!;

    final (Color bg, Color fg, IconData icon, String label) = switch (status) {
      CourtChipStatus.active => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          Symbols.check_circle,
          'Đang hoạt động',
        ),
      CourtChipStatus.pending => (
          snb.warnContainer,
          snb.onWarnContainer,
          Symbols.hourglass_top,
          'Chờ duyệt',
        ),
      CourtChipStatus.draft => (
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
          Symbols.edit_note,
          'Bản nháp',
        ),
      CourtChipStatus.inactive => (
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
          Symbols.pause_circle,
          'Tạm ngưng',
        ),
    };

    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg, fill: 1),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: fg,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Flat form section header: 22px primary icon + titleMedium + optional
/// bodySmall subtitle.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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

/// The AI "spark" avatar tile — a primaryContainer→tertiaryContainer 135°
/// gradient with [Symbols.auto_awesome]. Used everywhere AI entry appears.
class AiSparkTile extends StatelessWidget {
  const AiSparkTile({super.key, this.size = 40, this.radius = 12});

  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primaryContainer, scheme.tertiaryContainer],
        ),
      ),
      child: Icon(
        Symbols.auto_awesome,
        size: size * 0.5,
        color: scheme.onTertiaryContainer,
        fill: 1,
      ),
    );
  }
}

/// Striped placeholder for a court photo (45° bands of surfaceContainer /
/// surfaceContainerHigh + stadium glyph). Swap for a real photo when available.
class StripedPhotoPlaceholder extends StatelessWidget {
  const StripedPhotoPlaceholder({super.key, this.height = 140, this.caption});

  final double height;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _StripePainter(
          base: scheme.surfaceContainer,
          stripe: scheme.surfaceContainerHigh,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Symbols.stadium,
                  size: 28, color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
              if (caption != null) ...[
                const SizedBox(height: 4),
                Text(
                  caption!,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  _StripePainter({required this.base, required this.stripe});

  final Color base;
  final Color stripe;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = base);
    final paint = Paint()..color = stripe;
    const band = 10.0;
    canvas.save();
    canvas.clipRect(rect);
    // 45° diagonal bands.
    for (double x = -size.height; x < size.width; x += band * 2) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + size.height, 0)
        ..lineTo(x + size.height + band, 0)
        ..lineTo(x + band, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StripePainter oldDelegate) =>
      oldDelegate.base != base || oldDelegate.stripe != stripe;
}
