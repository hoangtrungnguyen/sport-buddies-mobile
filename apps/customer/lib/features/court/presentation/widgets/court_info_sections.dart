// Lower court-detail sections: amenities, about and the schedule entry card.
// Extracted from court_detail_page.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/court.dart';
import '../../theme/app_tokens.dart';

class AmenitySection extends StatelessWidget {
  const AmenitySection({super.key, required this.amenities});

  final List<String> amenities;

  static const _emoji = <String, String>{
    'Có mái che': '🏠',
    'Đèn đêm': '💡',
    'Thuê vợt': '🎾',
    'Wifi': '📶',
    'Đồ uống': '🥤',
    'Bãi giữ xe': '🅿️',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).courtDetailAmenities,
          style: text.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in amenities)
              Container(
                height: AppTokens.chipHeight,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: AppTokens.radiusSm,
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _emoji[a] ?? '•',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      a,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ── §6 About ─────────────────────────────────────────────────────────────────

class AboutSection extends StatelessWidget {
  const AboutSection({super.key, required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).courtDetailAbout,
          style: text.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

// ── §7 Schedule entry card → 08 (edge E3) ────────────────────────────────────

class ScheduleEntryCard extends StatelessWidget {
  const ScheduleEntryCard({super.key, required this.court});

  final Court court;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.courtDetailScheduleTitle, style: text.titleMedium),
        const SizedBox(height: 10),
        Material(
          color: scheme.primaryContainer,
          borderRadius: AppTokens.radiusLg,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () =>
                context.push('/browse/center/${court.centerId}/schedule'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calendar_month,
                      size: 24,
                      color: scheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.courtDetailViewAllCourts,
                          style: text.labelLarge?.copyWith(
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.courtDetailScheduleSubtitle,
                          style: text.bodySmall?.copyWith(
                            color: scheme.onPrimaryContainer.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: scheme.onPrimaryContainer),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
