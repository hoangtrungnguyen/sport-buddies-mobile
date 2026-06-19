/// Pure, state-free logic for [VenueScheduleBloc] — no `emit`, no service, no
/// bloc state. Extracted so the fiddly filter-toggle + month/date arithmetic
/// rules are unit-testable in isolation from the bloc's I/O.
library;

/// Prototype `toggleSet` semantics for the live filter chips: every chip
/// starts ACTIVE (an empty stored set ≡ "all"), a tap removes/adds one, and a
/// set that grows back to the full list normalises to empty ("all") so the
/// chips render exactly like the jsx.
///
/// [current] is the stored filter (empty = all selected), [item] the toggled
/// value, [allValues] every possible value (e.g. `SportType.values`).
Set<T> toggleFilterSet<T>(Set<T> current, T item, List<T> allValues) {
  final next = current.isEmpty ? allValues.toSet() : Set<T>.of(current);
  next.contains(item) ? next.remove(item) : next.add(item);
  // A full set ≡ "all" ≡ empty — normalise so the chips match the prototype.
  if (next.length == allValues.length) next.clear();
  return next;
}

/// Midnight of [d] — strips the time so focused-date comparisons are stable.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Steps [d] by [delta] months, clamping the day-of-month so e.g. Jan 31
/// +1 month lands on Feb 28/29 instead of overflowing into March.
DateTime stepMonth(DateTime d, int delta) {
  final first = DateTime(d.year, d.month + delta);
  final lastDay = DateTime(first.year, first.month + 1, 0).day;
  return DateTime(first.year, first.month, d.day > lastDay ? lastDay : d.day);
}
