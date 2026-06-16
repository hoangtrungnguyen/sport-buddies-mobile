import 'package:dashboard/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../bloc/slot_players_bloc.dart';
import '../repository/slot_players_repository.dart';
import 'widgets/slot_detail_header.dart';
import 'widgets/slot_roster.dart';

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
                SlotDetailHeader(
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
                      Roster(players: players, capacity: capacity),
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
