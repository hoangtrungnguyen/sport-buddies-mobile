// Shared constants and helpers for the multi-court venue schedule.
// Extracted from court_schedule_overview_screen.dart.

import 'package:customer/l10n/app_localizations.dart';

/// Venue name shown in the schedule header and threaded into booking payloads.
const kVenueName = 'Pickle Hub Sài Gòn';

/// Full localized weekday name for ISO weekday [w] (1=Mon … 7=Sun).
String fullWeekday(AppLocalizations l10n, int w) => switch (w) {
  1 => l10n.weekdayMonday,
  2 => l10n.weekdayTuesday,
  3 => l10n.weekdayWednesday,
  4 => l10n.weekdayThursday,
  5 => l10n.weekdayFriday,
  6 => l10n.weekdaySaturday,
  _ => l10n.weekdaySunday,
};
