import 'package:dashboard/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../../requests/model/booking_request.dart';
import '../../requests/requests_logic.dart' show formatVnd, statusLabel;
import '../bloc/slot_players_bloc.dart';
import '../model/slot_player.dart';
import '../repository/slot_players_repository.dart';
import '../slot_roster_logic.dart';

/// Opens the slot player-list (OWNER-33): "X/Y players", each with name,
/// avatar, booking-status badge, and a paid / not-paid chip. [capacity] is the
/// court capacity (null → count shown without a denominator).
Future<void> showSlotPlayersDialog(
  BuildContext context, {
  required String slotId,
  required String courtName,
  required DateTime startLocal,
  required DateTime endLocal,
  int? capacity,
  SlotPlayersRepository? repository,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => BlocProvider(
      create: (_) => SlotPlayersBloc(
        repository: repository ?? sl<SlotPlayersRepository>(),
        slotId: slotId,
      )..add(const SlotPlayersEvent.started()),
      child: _SlotPlayersDialog(
        courtName: courtName,
        startLocal: startLocal,
        endLocal: endLocal,
        capacity: capacity,
      ),
    ),
  );
}

class _SlotPlayersDialog extends StatelessWidget {
  const _SlotPlayersDialog({
    required this.courtName,
    required this.startLocal,
    required this.endLocal,
    required this.capacity,
  });
  final String courtName;
  final DateTime startLocal;
  final DateTime endLocal;
  final int? capacity;

  @override
  Widget build(BuildContext context) {
    final f = DateFormat('HH:mm');
    final subtitle = '$courtName · ${f.format(startLocal)} – ${f.format(endLocal)}';
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Semantics(
          label: 'slot-players-dialog',
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.groups_rounded,
                          size: 20, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Người chơi',
                            style: GoogleFonts.sora(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.neutral900),
                          ),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13, color: AppColors.neutral500),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: AppColors.neutral500,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                BlocBuilder<SlotPlayersBloc, SlotPlayersState>(
                  builder: (context, state) => switch (state) {
                    SlotPlayersInitial() || SlotPlayersLoading() => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary)),
                      ),
                    SlotPlayersFailure(:final message) =>
                      _Failure(message: message),
                    SlotPlayersLoaded(:final players) =>
                      _Roster(players: players, capacity: capacity),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Roster extends StatelessWidget {
  const _Roster({required this.players, required this.capacity});
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
                children: [for (final p in players) _PlayerRow(player: p)],
              ),
            ),
          ),
      ],
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player});
  final SlotPlayer player;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'slot-player-${player.id}',
      container: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Row(
          children: [
            _Avatar(player: player),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                  if (player.bookingStatus != null) ...[
                    const SizedBox(height: 4),
                    _BookingBadge(status: player.bookingStatus!),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            _PaymentChip(player: player),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.player});
  final SlotPlayer player;

  @override
  Widget build(BuildContext context) {
    final url = player.avatarUrl;
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark]),
      ),
      clipBehavior: Clip.antiAlias,
      child: (url != null)
          ? Image.network(url, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initial())
          : _initial(),
    );
  }

  Widget _initial() => Center(
        child: Text(
          player.initial,
          style: GoogleFonts.sora(
              fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      );
}

class _BookingBadge extends StatelessWidget {
  const _BookingBadge({required this.status});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      BookingStatus.pending => (AppColors.warningBg, const Color(0xFF854D0E)),
      BookingStatus.confirmed => (AppColors.successBg, const Color(0xFF166534)),
      BookingStatus.cancelled => (AppColors.neutral100, AppColors.neutral500),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(
        statusLabel(status),
        style: GoogleFonts.plusJakartaSans(
            fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  const _PaymentChip({required this.player});
  final SlotPlayer player;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (player.paymentStatus) {
      PaymentStatus.paid => (
          AppColors.successBg,
          const Color(0xFF166534),
          Icons.check_circle_rounded,
        ),
      PaymentStatus.partial => (
          AppColors.warningBg,
          const Color(0xFF854D0E),
          Icons.timelapse_rounded,
        ),
      // AC#1 OWNER-35: Unpaid = yellow (warningBg).
      PaymentStatus.unpaid => (
          AppColors.warningBg,
          const Color(0xFF854D0E),
          Icons.schedule_rounded,
        ),
      PaymentStatus.unknown => (
          AppColors.neutral100,
          AppColors.neutral400,
          Icons.help_outline_rounded,
        ),
    };
    final methodLabel = paymentMethodLabel(player.paymentMethod);
    return Semantics(
      label: 'slot-player-payment-${player.id}',
      value: player.paymentStatus.name,
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 5),
            Text(
              // Show payment method alongside the status when recorded (AC#4).
              methodLabel.isNotEmpty
                  ? '${paymentLabel(player.paymentStatus)} · $methodLabel'
                  : paymentLabel(player.paymentStatus),
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5, fontWeight: FontWeight.w700, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

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

class _Failure extends StatelessWidget {
  const _Failure({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 32, color: AppColors.danger),
          const SizedBox(height: 10),
          Text(message,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5, color: AppColors.neutral600)),
          const SizedBox(height: 12),
          Semantics(
            label: 'slot-players-retry-btn',
            button: true,
            child: OutlinedButton(
              onPressed: () =>
                  context.read<SlotPlayersBloc>().add(const SlotPlayersEvent.started()),
              child: const Text('Thử lại'),
            ),
          ),
        ],
      ),
    );
  }
}
