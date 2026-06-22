import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../model/profile_models.dart';

/// Gold used for review stars across the app — a fixed accent, not a theme role.
const _starGold = Color(0xFFE8A700);

/// The 4-up business stat tiles (2-up below 720px). Read-only, server-derived.
class ProfileStatTiles extends StatelessWidget {
  const ProfileStatTiles({super.key, required this.stats});

  final ProfileStats stats;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      _Tile(value: '${stats.clusters}', label: 'Cụm sân'),
      _Tile(value: '${stats.venues}', label: 'Sân con'),
      _Tile(
        value: _trimDouble(stats.rating),
        label: '${stats.ratingCount} đánh giá',
        star: true,
      ),
      _Tile(value: '${stats.monthlyBookings}', label: 'Lượt đặt / tháng'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 720 ? 2 : 4;
        const gap = 12.0;
        final tileWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final t in tiles) SizedBox(width: tileWidth, child: t),
          ],
        );
      },
    );
  }

  static String _trimDouble(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
}

class _Tile extends StatelessWidget {
  const _Tile({required this.value, required this.label, this.star = false});
  final String value;
  final String label;
  final bool star;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              if (star) ...[
                const SizedBox(width: 4),
                const Icon(Symbols.star, size: 20, fill: 1, color: _starGold),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
