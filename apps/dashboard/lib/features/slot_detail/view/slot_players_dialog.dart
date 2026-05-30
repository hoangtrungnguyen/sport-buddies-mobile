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
  /// Primary sport type label, e.g. "Tennis" (AC#1 OWNER-36).
  String? sportType,
  /// Optional slot note — shown if non-empty (AC#2 OWNER-36). In practice
  /// this is `OwnerSlot.blockedReason`; slots have no dedicated notes column.
  String? notes,
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
        sportType: sportType,
        notes: notes,
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
    this.sportType,
    this.notes,
  });
  final String courtName;
  final DateTime startLocal;
  final DateTime endLocal;
  final int? capacity;
  final String? sportType;
  final String? notes;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Semantics(
          label: 'slot-players-dialog',
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // OWNER-36 slot detail header — court, sport, date/time, duration.
                _SlotDetailHeader(
                  courtName: courtName,
                  startLocal: startLocal,
                  endLocal: endLocal,
                  sportType: sportType,
                  notes: notes,
                  onClose: () => Navigator.of(context).pop(),
                  // AC#3: pop all dialogs to return to the schedule calendar.
                  // Dialogs don't have a route name; pop until a named route.
                  onViewSchedule: () => Navigator.of(context)
                      .popUntil((route) => route.settings.name != null),
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

// ---------------------------------------------------------------------------
// OWNER-36 slot detail header
// ---------------------------------------------------------------------------

class _SlotDetailHeader extends StatelessWidget {
  const _SlotDetailHeader({
    required this.courtName,
    required this.startLocal,
    required this.endLocal,
    required this.onClose,
    required this.onViewSchedule,
    this.sportType,
    this.notes,
  });
  final String courtName;
  final DateTime startLocal;
  final DateTime endLocal;
  final String? sportType;
  final String? notes;
  final VoidCallback onClose;
  final VoidCallback onViewSchedule;

  @override
  Widget build(BuildContext context) {
    final f = DateFormat('HH:mm');
    final fd = DateFormat('dd/MM/yyyy');
    final durationMin = endLocal.difference(startLocal).inMinutes;
    final durationLabel = durationMin >= 60
        ? '${durationMin ~/ 60}h${durationMin % 60 == 0 ? '' : '${durationMin % 60}p'}'
        : '${durationMin}p';
    final note = notes?.trim();
    return Semantics(
      label: 'slot-detail-header',
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.event_rounded,
                    size: 22, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courtName,
                      style: GoogleFonts.sora(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutral900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (sportType != null && sportType!.isNotEmpty)
                      Text(
                        sportType!,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5, color: AppColors.neutral500),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                color: AppColors.neutral500,
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Date + time + duration chips.
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _InfoChip(icon: Icons.calendar_today_rounded,
                  label: fd.format(startLocal)),
              _InfoChip(icon: Icons.schedule_rounded,
                  label: '${f.format(startLocal)} – ${f.format(endLocal)}'),
              _InfoChip(icon: Icons.timelapse_rounded, label: durationLabel),
            ],
          ),
          // Notes (AC#2) — shown when non-empty.
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Semantics(
              label: 'slot-detail-notes',
              container: true,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notes_rounded,
                        size: 15, color: AppColors.neutral400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.neutral700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          // "Xem lịch" back-link (AC#3) — closes all dialogs to the calendar.
          const SizedBox(height: 10),
          Semantics(
            label: 'slot-detail-view-schedule-btn',
            button: true,
            child: TextButton.icon(
              icon: const Icon(Icons.calendar_view_week_rounded, size: 15),
              label: const Text('Xem lịch sân'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: onViewSchedule,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.neutral100,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.neutral500),
        const SizedBox(width: 5),
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: AppColors.neutral700,
                fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------

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
