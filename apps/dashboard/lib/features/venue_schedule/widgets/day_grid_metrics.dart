import '../model/models.dart';

// Day-grid geometry — handoff "Spacing": 60px/hour, 64px gutter, hours 6–22.

/// Grid geometry (handoff "Spacing": 60px per hour, 64px gutter, hours 6–22).
const double kHourPx = 60;
const double kGutterWidth = 64;
const int kFirstHour = 6;
const int kLastHour = 22;
const int kRowCount = kLastHour - kFirstHour + 1; // 17 rows: 06:00..22:00
const double kBodyHeight = kRowCount * kHourPx; // 1020

/// Below 1024px the grid scrolls horizontally with this minimum width.
const double kHScrollBreakpoint = 1024;
const double kMinGridWidth = 720;

/// Header `<N> slot` counts actual bookings, not blocks/empties — mirrors the
/// prototype's `['confirmed','pending','fixed','public','private']`.
const Set<SlotState> kBookedStates = {
  SlotState.confirmed,
  SlotState.pending,
  SlotState.fixed,
  SlotState.open,
  SlotState.private,
};
