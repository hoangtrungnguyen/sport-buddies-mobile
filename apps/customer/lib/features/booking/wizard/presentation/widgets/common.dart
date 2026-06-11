// Shared wizard atoms (handoff doc 02 / doc 01 §5).

import 'package:customer/features/booking/wizard/presentation/wizard_format.dart';
import 'package:customer/features/court/domain/court.dart';
import 'package:customer/features/court/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// 56×56 gradient sport tile (doc 02 §1.1).
class SportTile extends StatelessWidget {
  const SportTile({super.key, required this.sport, this.size = 56});

  final Sport sport;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF15803D), Color(0xFF4ADE80)],
        ),
        borderRadius: AppTokens.radiusMd,
      ),
      child: Text(sportEmoji(sport), style: TextStyle(fontSize: size * 0.5)),
    );
  }
}

/// Key/value row with a hairline underline (doc 02 §1.4 / §4.3).
class SummaryRow extends StatelessWidget {
  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
    this.divider = true,
  });

  final String label;
  final String value;
  final bool bold;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: divider
          ? BoxDecoration(
              border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(label,
                style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            textAlign: TextAlign.right,
            style: bold
                ? text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: AppTokens.tnum,
                  )
                : text.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontFeatures: AppTokens.tnum,
                  ),
          ),
        ],
      ),
    );
  }
}

/// h24 tonal pill — "n khung · 4 giờ" (doc 01 §5 count badge).
class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      height: 24,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: AppTokens.radiusFull,
      ),
      child: Text(
        label,
        style: text.labelMedium?.copyWith(
          color: scheme.onPrimaryContainer,
          fontFeatures: AppTokens.tnum,
        ),
      ),
    );
  }
}

enum BadgeKind { pending, confirmed, access }

/// h24 status/access pill with a leading dot (doc 01 §5).
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.kind, required this.label});

  final BadgeKind kind;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final (Color bg, Color fg, Color? dot) = switch (kind) {
      BadgeKind.pending => (
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
          scheme.tertiary
        ),
      BadgeKind.confirmed => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          scheme.primary
        ),
      BadgeKind.access => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          null
        ),
    };

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: bg, borderRadius: AppTokens.radiusFull),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(label,
              style: text.labelMedium?.copyWith(color: fg)),
        ],
      ),
    );
  }
}

/// Full-width amber cash chip/reminder (doc 02 §1.6 / §4.4).
class CashNotice extends StatelessWidget {
  const CashNotice({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: AppTokens.radiusMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💵', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: (subtitle == null ? text.bodySmall : text.labelLarge)
                      ?.copyWith(
                    color: scheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: text.bodySmall
                        ?.copyWith(color: scheme.onTertiaryContainer),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
