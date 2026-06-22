// Step 3 · Awaiting owner — "Đang chờ xác nhận" (SPB-044, handoff doc 02 Step 3).
//
// The advance to Step 4 is NOT a button — it is the realtime status→confirmed
// event driven by the cubit. This screen only listens and shows progress.

import 'package:customer/features/booking/wizard/cubit/booking_wizard_cubit.dart';
import 'package:customer/features/booking/wizard/domain/play_session.dart';
import 'package:customer/features/booking/wizard/presentation/widgets/awaiting_ring.dart';
import 'package:customer/features/booking/wizard/presentation/widgets/awaiting_status_timeline.dart';
import 'package:customer/features/booking/wizard/presentation/widgets/common.dart';
import 'package:customer/features/booking/wizard/presentation/wizard_format.dart';
import 'package:customer/features/court/theme/app_tokens.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Step3Awaiting extends StatelessWidget {
  const Step3Awaiting({super.key, required this.state});

  final BookingWizardState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final booking = state.booking;
    if (booking == null) return const SizedBox.shrink();

    final sessions = mergeSessions(state.draft.slots);
    final declined = state.declined;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Center(
          child: declined
              ? Icon(Icons.cancel, size: 96, color: scheme.error)
              : const AwaitingRing(),
        ),
        const SizedBox(height: 20),
        Semantics(
          liveRegion: true,
          child: Text(
            declined ? l10n.wizardDeclinedTitle : l10n.wizardWaitingTitle,
            textAlign: TextAlign.center,
            style: text.headlineSmall,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            declined
                ? l10n.wizardDeclinedBody
                : l10n.wizardWaitingBody(
                    state.slotCount,
                    state.draft.courtLabel,
                  ),
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
        if (declined) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              borderRadius: AppTokens.radiusMd,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.wizardNotConfirmed,
                    style: text.bodySmall?.copyWith(
                      color: scheme.onErrorContainer,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(l10n.wizardPickAnotherTime),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        _BookingIdCard(
          idLabel: bookingIdLabel(booking.id),
          courtLabel: state.draft.courtLabel,
          slotCount: state.slotCount,
          dateDurTotal:
              '${dateLabel(l10n, state.draft.date)} · ${durationLabel(l10n, state.totalDuration)} · ${vnd(state.totalVnd)}',
          sessions: sessions,
        ),
        const SizedBox(height: 24),
        AwaitingStatusTimeline(
          sentAt: hm(booking.createdAt),
          declined: declined,
        ),
      ],
    );
  }
}

class _BookingIdCard extends StatelessWidget {
  const _BookingIdCard({
    required this.idLabel,
    required this.courtLabel,
    required this.slotCount,
    required this.dateDurTotal,
    required this.sessions,
  });

  final String idLabel;
  final String courtLabel;
  final int slotCount;
  final String dateDurTotal;
  final List<PlaySession> sessions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: AppTokens.radiusMd,
        boxShadow: AppTokens.elev1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.wizardBookingId,
                style: text.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Text(
                idLabel,
                style: text.labelLarge?.copyWith(fontFeatures: AppTokens.tnum),
              ),
            ],
          ),
          Divider(height: 24, color: scheme.outlineVariant),
          Text(
            l10n.wizardCourtSlots(courtLabel, slotCount),
            style: text.titleSmall,
          ),
          const SizedBox(height: 2),
          Text(
            dateDurTotal,
            style: text.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontFeatures: AppTokens.tnum,
            ),
          ),
          const SizedBox(height: 8),
          ...sessions.map(
            (s) => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '• ${timeRange(s.start, s.end)} · ${s.courtLabel}',
                style: text.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontFeatures: AppTokens.tnum,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          StatusBadge(
            kind: BadgeKind.pending,
            label: l10n.bookingStatusPendingHost,
          ),
        ],
      ),
    );
  }
}
