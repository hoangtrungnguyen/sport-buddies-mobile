// Step 4 · Done — "Hoàn tất" (SPB-047, handoff doc 02 Step 4).

import 'package:customer/features/booking/wizard/cubit/booking_wizard_cubit.dart';
import 'package:customer/features/booking/wizard/domain/booking.dart';
import 'package:customer/features/booking/wizard/domain/play_session.dart';
import 'package:customer/features/booking/wizard/presentation/widgets/common.dart';
import 'package:customer/features/booking/wizard/presentation/wizard_format.dart';
import 'package:customer/features/court/theme/app_tokens.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class Step4Done extends StatelessWidget {
  const Step4Done({super.key, required this.state});

  final BookingWizardState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final booking = state.booking;
    if (booking == null) return const SizedBox.shrink();
    final isOpen = booking.access == AccessPolicy.open;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const Center(child: _SuccessCheck()),
        const SizedBox(height: 20),
        Text(
          l10n.wizardSuccessTitle,
          textAlign: TextAlign.center,
          style: text.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(
          l10n.wizardSuccessBody(state.draft.courtLabel),
          textAlign: TextAlign.center,
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        _ReceiptCard(state: state, idLabel: bookingIdLabel(booking.id)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            StatusBadge(
              kind: BadgeKind.confirmed,
              label: l10n.bookingStatusConfirmed,
            ),
            if (isOpen)
              StatusBadge(kind: BadgeKind.access, label: l10n.wizardOpen),
          ],
        ),
        const SizedBox(height: 14),
        CashNotice(
          title: l10n.wizardBringCash,
          subtitle: l10n.wizardBringCashBody(
            vnd(state.totalVnd),
            state.slotCount,
          ),
        ),
      ],
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.state, required this.idLabel});

  final BookingWizardState state;
  final String idLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final draft = state.draft;
    final sessions = mergeSessions(draft.slots);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: AppTokens.radiusMd,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
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
          SummaryRow(label: l10n.wizardLabelCourt, value: draft.courtLabel),
          SummaryRow(
            label: l10n.wizardLabelDate,
            value: dateLabel(l10n, draft.date),
          ),
          SummaryRow(
            label: l10n.wizardLabelSlots,
            value: countLabel(l10n, state.slotCount, state.totalDuration),
          ),
          const SizedBox(height: 8),
          ...sessions.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '• ${timeRange(s.start, s.end)}'
                '${s.isMerged ? l10n.wizardMergedSuffix(s.slotCount) : ''}',
                style: text.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontFeatures: AppTokens.tnum,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          CustomPaint(
            size: const Size(double.infinity, 1),
            painter: _DashedLinePainter(scheme.outlineVariant),
          ),
          SummaryRow(
            label: l10n.wizardLabelTotal,
            value: vnd(state.totalVnd),
            bold: true,
            divider: false,
          ),
        ],
      ),
    );
  }
}

class _SuccessCheck extends StatelessWidget {
  const _SuccessCheck();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reduced = MediaQuery.disableAnimationsOf(context);

    final hero = Container(
      width: 120,
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          size: 44,
          color: scheme.onPrimary,
          weight: 700,
        ),
      ),
    );

    if (reduced) return hero;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
      child: hero,
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dash = 4.0;
    const gap = 3.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}
