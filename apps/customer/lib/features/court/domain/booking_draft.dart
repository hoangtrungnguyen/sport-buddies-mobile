// EPIC-5 domain model — booking draft passed forward on edges E7 / E11
// (handoff doc 03 §4).

/// One picked slot, in selection order.
class SlotSelection {
  const SlotSelection({
    required this.courtId,
    required this.courtLabel,
    required this.date,
    required this.start,
    required this.end,
    required this.priceVnd,
  });

  final String courtId;
  final String courtLabel; // "Sân A · Pickleball" — for the summary rows
  final DateTime date;
  final DateTime start;
  final DateTime end;
  final int priceVnd;
}

/// The cart handed to the booking wizard. [totalVnd] is derived — never
/// stored separately (handoff ground rule §4: one source of truth).
class BookingDraft {
  const BookingDraft({required this.centerId, required this.slots});

  final String centerId;
  final List<SlotSelection> slots; // in pick order

  int get totalVnd => slots.fold(0, (sum, s) => sum + s.priceVnd);

  Duration get totalDuration =>
      slots.fold(Duration.zero, (d, s) => d + s.end.difference(s.start));
}
