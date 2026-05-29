// Pure, framework-free helpers for the incoming-requests queue (OWNER-27).
//
// Kept separate from the bloc/repository/screen so grouping, the summary math,
// pagination, and label formatting can be unit-tested without Supabase or
// Flutter. Operates only on the [BookingRequest] domain model, so none of this
// depends on the (assumed) Supabase column contract.

import 'model/booking_request.dart';

/// Page size for the request list (OWNER-27 AC: "Paginated (4 per page)").
const int kRequestsPerPage = 4;

/// Vietnamese short weekday labels, Monday-first (T2..CN). `DateTime.weekday`
/// is 1 (Mon)..7 (Sun).
const List<String> kViWeekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

// ---------------------------------------------------------------------------
// Sorting
// ---------------------------------------------------------------------------

/// Returns [items] sorted ascending by start time (OWNER-27 default sort),
/// tie-broken by court name then code for a stable, deterministic order.
List<BookingRequest> sortByStartAsc(List<BookingRequest> items) {
  final out = [...items];
  out.sort((a, b) {
    final t = a.startAt.compareTo(b.startAt);
    if (t != 0) return t;
    final c = a.courtName.compareTo(b.courtName);
    return c != 0 ? c : a.code.compareTo(b.code);
  });
  return out;
}

// ---------------------------------------------------------------------------
// Summary bar
// ---------------------------------------------------------------------------

/// Aggregate figures for the summary bar (OWNER-27): total bookings, pending
/// count, and expected revenue for the day.
class RequestsSummary {
  const RequestsSummary({
    required this.total,
    required this.pending,
    required this.expectedRevenue,
  });

  final int total;
  final int pending;

  /// Sum of [BookingRequest.revenue] across all **non-cancelled** bookings —
  /// the revenue the owner can still expect once pending requests resolve.
  final int expectedRevenue;
}

RequestsSummary computeSummary(List<BookingRequest> items) {
  var pending = 0;
  var revenue = 0;
  for (final b in items) {
    if (b.isPending) pending++;
    if (!b.isCancelled) revenue += b.revenue;
  }
  return RequestsSummary(
    total: items.length,
    pending: pending,
    expectedRevenue: revenue,
  );
}

// ---------------------------------------------------------------------------
// Pagination
// ---------------------------------------------------------------------------

/// Number of pages needed for [total] items. Always ≥ 1 (an empty list still
/// renders a single, empty page).
int pageCount(int total, {int perPage = kRequestsPerPage}) =>
    total <= 0 ? 1 : ((total + perPage - 1) ~/ perPage);

/// Clamps [page] into `[0, pageCount-1]`.
int clampPage(int page, int total, {int perPage = kRequestsPerPage}) {
  final last = pageCount(total, perPage: perPage) - 1;
  if (page < 0) return 0;
  return page > last ? last : page;
}

/// The slice of [sorted] visible on (zero-based) [page]. Out-of-range pages
/// return an empty list.
List<BookingRequest> pageSlice(
  List<BookingRequest> sorted,
  int page, {
  int perPage = kRequestsPerPage,
}) {
  final start = page * perPage;
  if (start < 0 || start >= sorted.length) return const [];
  final end = start + perPage;
  return sorted.sublist(start, end > sorted.length ? sorted.length : end);
}

/// Record-count label: "Hiển thị X trong Y đơn", where Y is the total for the
/// day and X is the number shown **through** the current page (cumulative upper
/// bound), so it reads as a progress indicator across pages.
String recordCountLabel(int page, int total, {int perPage = kRequestsPerPage}) {
  if (total <= 0) return 'Hiển thị 0 trong 0 đơn';
  final shownThrough = (page + 1) * perPage;
  final x = shownThrough > total ? total : shownThrough;
  return 'Hiển thị $x trong $total đơn';
}

// ---------------------------------------------------------------------------
// Grouping by slot time
// ---------------------------------------------------------------------------

/// A run of requests that share the same start instant — the "slot time" group
/// the queue lists under one time header (OWNER-27: "grouped by slot time").
class BookingGroup {
  const BookingGroup({required this.startAt, required this.items});
  final DateTime startAt;
  final List<BookingRequest> items;

  /// Header label for the group, e.g. `11:00` (local).
  String get label => hhmm(startAt.toLocal());
}

/// Groups an already-sorted [sortedItems] into [BookingGroup]s by start instant,
/// preserving the incoming order. Adjacent items with an equal [startAt] share a
/// group; the grouping operates on whatever (already-paginated) slice it's given.
List<BookingGroup> groupBySlotTime(List<BookingRequest> sortedItems) {
  final groups = <BookingGroup>[];
  for (final item in sortedItems) {
    if (groups.isNotEmpty &&
        groups.last.startAt.isAtSameMomentAs(item.startAt)) {
      groups.last.items.add(item);
    } else {
      groups.add(BookingGroup(startAt: item.startAt, items: [item]));
    }
  }
  return groups;
}

// ---------------------------------------------------------------------------
// Labels & formatting
// ---------------------------------------------------------------------------

/// Localized Vietnamese status label for a [BookingStatus] (OWNER-27 badges).
String statusLabel(BookingStatus status) => switch (status) {
      BookingStatus.pending => 'Chờ xác nhận',
      BookingStatus.confirmed => 'Đã xác nhận',
      BookingStatus.cancelled => 'Đã huỷ',
    };

/// `HH:mm` for a local instant (zero-padded, 24h).
String hhmm(DateTime local) =>
    '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';

/// `HH:mm – HH:mm` time range for a booking card. Pass **local** instants.
String timeRange(DateTime startLocal, DateTime endLocal) =>
    '${hhmm(startLocal)} – ${hhmm(endLocal)}';

/// Day heading for the date picker, e.g. `T6, 29/05/2026`. Pass a local date.
String dayHeading(DateTime localDay) {
  final wd = kViWeekdays[localDay.weekday - DateTime.monday];
  final d = localDay.day.toString().padLeft(2, '0');
  final m = localDay.month.toString().padLeft(2, '0');
  return '$wd, $d/$m/${localDay.year}';
}

/// Formats a whole-VND [amount] with `.` thousands separators and a trailing
/// `đ`, e.g. `1.200.000đ`. Done by hand (not `intl`) so it needs no locale data
/// and stays trivially testable.
String formatVnd(int amount) {
  final neg = amount < 0;
  final digits = amount.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
    buf.write(digits[i]);
  }
  return '${neg ? '-' : ''}$buf' 'đ';
}

// ---------------------------------------------------------------------------
// Date helpers
// ---------------------------------------------------------------------------

/// Local midnight of [d]'s calendar day.
DateTime dayStartLocal(DateTime d) => DateTime(d.year, d.month, d.day);

/// [d] shifted by [days] whole calendar days, always landing on local midnight.
/// Uses date-component arithmetic (which `DateTime` normalizes) rather than
/// `Duration(days:)` so a DST transition can't leave it at 23:00/01:00.
DateTime addDays(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);

/// True when [a] and [b] fall on the same calendar day.
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
