// EPIC-5 domain model — booking draft passed forward on edges E7 / E11
// (handoff doc 03 §4 · booking-wizard doc 04 §1).

import 'court.dart';

/// One picked slot, in selection order.
class SlotSelection {
  const SlotSelection({
    required this.slotId,
    required this.courtId,
    required this.courtLabel,
    required this.date,
    required this.start,
    required this.end,
    required this.priceVnd,
  });

  /// Backend slot id — needed to claim the slot via the booking API.
  final String slotId;
  final String courtId;
  final String courtLabel; // "Sân A" — for the summary rows
  final DateTime date;
  final DateTime start;
  final DateTime end;
  final int priceVnd;

  Duration get duration => end.difference(start);
}

/// The cart handed to the booking wizard. [totalVnd] / [totalDuration] are
/// derived — never stored separately (handoff ground rule §4: one source of
/// truth for money & duration).
class BookingDraft {
  const BookingDraft({
    required this.centerId,
    required this.courtId,
    required this.courtLabel,
    required this.address,
    required this.sport,
    required this.date,
    required this.slots,
  });

  final String centerId;
  final String courtId;
  final String courtLabel; // "Pickle Hub Q1 · Sân B" — for summary cards
  final String address; // "123 Nguyễn Du, Q.1"
  final Sport sport; // for the summary-tile pictogram
  final DateTime date; // "Thứ tư, 14/05"
  final List<SlotSelection> slots; // in pick order

  int get totalVnd => slots.fold(0, (sum, s) => sum + s.priceVnd);

  Duration get totalDuration =>
      slots.fold(Duration.zero, (d, s) => d + s.end.difference(s.start));
}
