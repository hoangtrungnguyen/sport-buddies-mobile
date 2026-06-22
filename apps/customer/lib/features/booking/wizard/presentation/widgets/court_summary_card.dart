// Court summary card for the confirm step — sport tile + court label/address
// (doc 02 §1.1). Extracted from step_1_confirm.dart.

import 'package:customer/features/booking/wizard/presentation/widgets/common.dart';
import 'package:customer/features/court/domain/booking_draft.dart';
import 'package:customer/features/court/theme/app_tokens.dart';
import 'package:flutter/material.dart';

class CourtSummaryCard extends StatelessWidget {
  const CourtSummaryCard({super.key, required this.draft});

  final BookingDraft draft;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: AppTokens.radiusMd,
        boxShadow: AppTokens.elev1,
      ),
      child: Row(
        children: [
          SportTile(sport: draft.sport),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(draft.courtLabel, style: text.titleSmall),
                const SizedBox(height: 2),
                Text(
                  draft.address,
                  style: text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
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
