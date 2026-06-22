// Per-slot confirm rows, merge notice, and total bar for the confirm step
// (doc 02 §1). Extracted from step_1_confirm.dart.

import 'package:customer/features/booking/wizard/domain/play_session.dart';
import 'package:customer/features/booking/wizard/presentation/wizard_format.dart';
import 'package:customer/features/court/domain/booking_draft.dart';
import 'package:customer/features/court/theme/app_tokens.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class SlotLine extends StatelessWidget {
  const SlotLine({super.key, required this.slot, required this.adjacent});

  final SlotSelection slot;
  final bool adjacent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final sub = [
      dateLabel(l10n, slot.date),
      slot.courtLabel,
      durationLabel(l10n, slot.duration),
      if (adjacent) l10n.wizardAdjacent,
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: AppTokens.radiusMd,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeRange(slot.start, slot.end),
                  style: text.labelLarge?.copyWith(
                    fontFeatures: AppTokens.tnum,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            vnd(slot.priceVnd),
            style: text.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: AppTokens.tnum,
            ),
          ),
        ],
      ),
    );
  }
}

class MergeNotice extends StatelessWidget {
  const MergeNotice({super.key, required this.slots});

  final List<SlotSelection> slots;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    // Derived copy — name the slots composing the first merged run.
    final session = mergeSessions(slots).firstWhere((s) => s.isMerged);
    final parts = slots
        .where(
          (s) =>
              !s.start.isBefore(session.start) && !s.end.isAfter(session.end),
        )
        .map((s) => timeRange(s.start, s.end))
        .toList();
    final names = parts.join(' ${l10n.wizardAnd} ');
    final copy = l10n.wizardMergeNotice(
      names,
      durationLabel(l10n, session.duration),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: AppTokens.radiusMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚡', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              copy,
              style: text.bodySmall?.copyWith(color: scheme.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class TotalBar extends StatelessWidget {
  const TotalBar({super.key, required this.totalVnd});

  final int totalVnd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: AppTokens.radiusMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context).bookingTotalPayment,
            style: text.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
          Text(
            vnd(totalVnd),
            style: text.headlineSmall?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: scheme.primary,
              fontFeatures: AppTokens.tnum,
            ),
          ),
        ],
      ),
    );
  }
}
