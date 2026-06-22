// Step 1 · Confirm — "Xác nhận đặt sân" (SPB-042, handoff doc 02 Step 1).

import 'package:customer/features/booking/wizard/cubit/booking_wizard_cubit.dart';
import 'package:customer/features/booking/wizard/domain/play_session.dart';
import 'package:customer/features/booking/wizard/presentation/widgets/common.dart';
import 'package:customer/features/booking/wizard/presentation/widgets/confirm_slot_views.dart';
import 'package:customer/features/booking/wizard/presentation/widgets/contact_form.dart';
import 'package:customer/features/booking/wizard/presentation/widgets/court_summary_card.dart';
import 'package:customer/features/booking/wizard/presentation/wizard_format.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class Step1Confirm extends StatelessWidget {
  const Step1Confirm({super.key, required this.state});

  final BookingWizardState state;

  @override
  Widget build(BuildContext context) {
    final draft = state.draft;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final merged = hasMerge(draft.slots);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        CourtSummaryCard(draft: draft),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.bookingSelectedSlot, style: text.titleMedium),
            CountBadge(
              label: countLabel(l10n, state.slotCount, draft.totalDuration),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...List.generate(draft.slots.length, (i) {
          final s = draft.slots[i];
          final adjacent =
              i > 0 &&
              draft.slots[i - 1].courtId == s.courtId &&
              draft.slots[i - 1].end == s.start;
          return Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
            child: SlotLine(slot: s, adjacent: adjacent),
          );
        }),
        if (merged) ...[
          const SizedBox(height: 10),
          MergeNotice(slots: draft.slots),
        ],
        const SizedBox(height: 16),
        SummaryRow(
          label: l10n.bookingTotalDuration,
          value: durationLabel(l10n, draft.totalDuration),
        ),
        SummaryRow(label: l10n.wizardTotalRent, value: vnd(draft.totalVnd)),
        SummaryRow(label: l10n.bookingServiceFee, value: l10n.bookingFree),
        const SizedBox(height: 12),
        TotalBar(totalVnd: draft.totalVnd),
        const SizedBox(height: 10),
        CashNotice(title: l10n.bookingCashAtCourt),
        const SizedBox(height: 24),
        Text(l10n.bookingContactInfo, style: text.titleMedium),
        const SizedBox(height: 10),
        ContactForm(contact: state.contact),
        const SizedBox(height: 8),
        // soft hint to anchor the bottom on short drafts
        Text(
          l10n.wizardContactHint,
          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
