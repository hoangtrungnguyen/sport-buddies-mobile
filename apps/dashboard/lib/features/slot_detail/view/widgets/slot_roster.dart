import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../../../requests/requests_logic.dart' show formatVnd;
import '../../model/slot_player.dart';
import '../../slot_roster_logic.dart';
import 'roster_player_row.dart';

class Roster extends StatelessWidget {
  const Roster({super.key, required this.players, required this.capacity});
  final List<SlotPlayer> players;
  final int? capacity;

  @override
  Widget build(BuildContext context) {
    final summary = computePaymentSummary(players);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Count vs capacity — e.g. "3/4 người chơi".
        Semantics(
          label: 'slot-players-count',
          value: playerCountLabel(players.length, capacity),
          container: true,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_rounded,
                    size: 14, color: AppColors.neutral600),
                const SizedBox(width: 6),
                Text(
                  playerCountLabel(players.length, capacity),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Payment summary bar (AC#2 OWNER-35).
        if (players.isNotEmpty) ...[
          _PaymentSummaryBar(summary: summary),
          const SizedBox(height: 14),
        ],
        if (players.isEmpty)
          Semantics(
            label: 'slot-players-empty',
            container: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'Chưa có người chơi nào trong khung giờ này.',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5, color: AppColors.neutral500),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: SingleChildScrollView(
              child: Column(
                children: [for (final p in players) RosterPlayerRow(player: p)],
              ),
            ),
          ),
      ],
    );
  }
}

class _PaymentSummaryBar extends StatelessWidget {
  const _PaymentSummaryBar({required this.summary});
  final PaymentSummary summary;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'slot-payment-summary',
      container: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Row(
          children: [
            Expanded(
              child: _SummaryCell(
                label: 'Đã thu',
                value: formatVnd(summary.totalCollected),
                fg: const Color(0xFF166534),
              ),
            ),
            Container(width: 1, height: 36, color: AppColors.neutral200,
                margin: const EdgeInsets.symmetric(horizontal: 12)),
            Expanded(
              child: _SummaryCell(
                label: 'Dự kiến',
                value: formatVnd(summary.totalExpected),
                fg: AppColors.neutral700,
              ),
            ),
            Container(width: 1, height: 36, color: AppColors.neutral200,
                margin: const EdgeInsets.symmetric(horizontal: 12)),
            Expanded(
              child: _SummaryCell(
                label: 'Chưa thu',
                value: summary.unpaidCount.toString(),
                fg: summary.unpaidCount > 0 ? const Color(0xFF854D0E) : AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({required this.label, required this.value, required this.fg});
  final String label;
  final String value;
  final Color fg;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.neutral500)),
      const SizedBox(height: 3),
      Text(value, style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w800, color: fg)),
    ],
  );
}
