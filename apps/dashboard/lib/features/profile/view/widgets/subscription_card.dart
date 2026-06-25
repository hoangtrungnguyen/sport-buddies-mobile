import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../subscription/model/subscription.dart';
import '../../util/profile_format.dart';

/// "Gói dịch vụ" subscription card — `primaryContainer`, radius 16, with the
/// plan name, days-left line, a progress bar, and an inverted "Nâng cấp" button.
/// Driven by the shared [SubscriptionCubit] — same source as the drawer banner.
class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({
    super.key,
    required this.plan,
    required this.onUpgrade,
  });

  final Subscription plan;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onContainer = scheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: onContainer.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(Symbols.workspace_premium,
                size: 24, fill: 1, color: onContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: onContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                // Open-ended plan (free) has no window → no countdown/bar.
                Text(
                  plan.hasWindow
                      ? 'Còn ${plan.daysLeft} ngày · hết hạn '
                          '${dayMonthYear(plan.expiresAt!)}'
                      : 'Không giới hạn thời gian',
                  style: theme.textTheme.bodySmall?.copyWith(color: onContainer),
                ),
                if (plan.hasWindow) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: plan.progress,
                      minHeight: 6,
                      backgroundColor: onContainer.withValues(alpha: 0.16),
                      valueColor: AlwaysStoppedAnimation(
                        onContainer.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          FilledButton.icon(
            onPressed: onUpgrade,
            icon: const Icon(Symbols.arrow_upward, size: 18),
            label: const Text('Nâng cấp'),
            style: FilledButton.styleFrom(
              backgroundColor: onContainer,
              foregroundColor: scheme.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
