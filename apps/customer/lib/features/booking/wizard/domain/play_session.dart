// Adjacency-merge rule — derived display only (handoff doc 04 §5).
//
// Consecutive selected slots on the SAME court with `end == next.start`
// collapse into one [PlaySession]. The booking still holds the individual
// slots; this is purely for the Step-1 ⚡ notice, the Step-3 bullets, and the
// Step-4 "(gộp n khung)" lines.

import 'package:customer/features/court/domain/booking_draft.dart';

/// A run of adjacent slots merged into one display session.
class PlaySession {
  const PlaySession({
    required this.start,
    required this.end,
    required this.courtLabel,
    required this.slotCount,
  });

  final DateTime start; // "09:00"
  final DateTime end; // "12:00"
  final String courtLabel; // "Sân B"
  final int slotCount; // 2 → "(gộp 2 khung)"

  bool get isMerged => slotCount > 1;
  Duration get duration => end.difference(start);
}

/// Pure function — collapses adjacent same-court slots into sessions.
///
/// Slots are processed in [draftSlots] order. A slot extends the current
/// session when it is on the same court and its `start` equals the running
/// session `end`; otherwise it opens a new session.
List<PlaySession> mergeSessions(List<SlotSelection> draftSlots) {
  if (draftSlots.isEmpty) return const [];

  final sessions = <PlaySession>[];
  var start = draftSlots.first.start;
  var end = draftSlots.first.end;
  var courtId = draftSlots.first.courtId;
  var label = draftSlots.first.courtLabel;
  var count = 1;

  void flush() => sessions.add(PlaySession(
        start: start,
        end: end,
        courtLabel: label,
        slotCount: count,
      ));

  for (final s in draftSlots.skip(1)) {
    final adjacent = s.courtId == courtId && s.start == end;
    if (adjacent) {
      end = s.end;
      count++;
    } else {
      flush();
      start = s.start;
      end = s.end;
      courtId = s.courtId;
      label = s.courtLabel;
      count = 1;
    }
  }
  flush();
  return sessions;
}

/// True when at least one run of ≥2 adjacent slots merges — drives whether
/// the Step-1 ⚡ notice shows at all (doc 02 §1.3).
bool hasMerge(List<SlotSelection> slots) =>
    mergeSessions(slots).any((s) => s.isMerged);
