// EPIC-5 domain models — schedule grid (handoff doc 04 §1).

enum CellStatus { open, booked, blocked }

/// One day of the center grid (screen 08): rows = courts, columns = hours.
class ScheduleDay {
  const ScheduleDay({
    required this.date,
    required this.hourLabels,
    required this.rows,
  });

  final DateTime date;

  /// e.g. ["06:00", "08:00", … "20:00"].
  final List<String> hourLabels;

  /// courtId → one [CellStatus] per hour column (same length as [hourLabels]).
  final Map<String, List<CellStatus>> rows;
}
