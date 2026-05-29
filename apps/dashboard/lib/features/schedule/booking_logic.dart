// Pure, framework-free helpers for the manual walk-in booking flow (OWNER-20).
//
// Kept separate from the repository/dialog so phone normalization, the
// request-payload shape, and the timezone guard can be unit-tested without
// Dio, Supabase, or Flutter.

import 'package:intl/intl.dart';

import 'schedule_logic.dart';

/// E.164 phone shape required by the backend (`^\+[1-9]\d{6,14}$`).
final RegExp _kE164 = RegExp(r'^\+[1-9]\d{6,14}$');

/// True when [phone] is already a valid E.164 number (e.g. `+84901234567`).
bool isValidE164(String phone) => _kE164.hasMatch(phone);

/// Normalizes a Vietnamese-entered phone number to E.164 (`+84…`), or returns
/// `null` when [raw] is empty or cannot be coerced into a valid E.164 number.
///
/// Accepts the formats counter staff actually type:
/// - local `0901234567`        → `+84901234567`
/// - spaced `090 123 4567`     → `+84901234567`
/// - country-coded `84901…`    → `+84901…`
/// - already-international `+84901…` → unchanged
///
/// The backend ([ManualBookingRepository]) requires strict E.164, so the form
/// runs every entered number through this before sending (per the OWNER-20
/// decision to normalize `0` → `+84` client-side).
String? normalizeVietnamPhone(String raw) {
  // Strip spaces, dashes, dots and parentheses — common manual separators.
  var s = raw.replaceAll(RegExp(r'[\s\-.()]'), '');
  if (s.isEmpty) return null;

  if (s.startsWith('+')) {
    // Already international — validate as-is below.
  } else if (s.startsWith('0')) {
    s = '+84${s.substring(1)}';
  } else if (s.startsWith('84')) {
    s = '+$s';
  } else {
    // Bare local digits missing the leading 0 (e.g. "901234567").
    s = '+84$s';
  }

  return isValidE164(s) ? s : null;
}

/// The manual-booking endpoint takes a single `date` plus `start_time`/
/// `end_time` and interprets them as **UTC** wall-clock. A local window whose
/// UTC start and UTC end land on different calendar dates therefore cannot be
/// expressed by that contract, so the form blocks it client-side.
///
/// For HCMC (UTC+7) this only bites the very edge of the operating window — a
/// 06:00 local start lasting ≥1h crosses UTC midnight (23:00Z → 00:00Z).
bool crossesUtcDateBoundary(DateTime startAtLocal, DateTime endAtLocal) {
  final us = startAtLocal.toUtc();
  final ue = endAtLocal.toUtc();
  return us.year != ue.year || us.month != ue.month || us.day != ue.day;
}

final DateFormat _kDate = DateFormat('yyyy-MM-dd');
final DateFormat _kTime = DateFormat('HH:mm');

/// Builds the JSON body for `POST /api/bookings/manual`.
///
/// [startAtLocal]/[endAtLocal] are the wall-clock instants the owner picked in
/// their own time zone. The endpoint treats the sent `date`/`start_time`/
/// `end_time` as UTC, so we send the **UTC** components of those instants —
/// preserving the true moment (and keeping the booking aligned with the
/// schedule grid, which stores `.toUtc()` and renders `.toLocal()`).
///
/// Optional fields are omitted entirely when blank so the server applies its
/// own defaults. [customerPhone] should already be normalized (see
/// [normalizeVietnamPhone]); pass `null` to omit it.
Map<String, dynamic> buildManualBookingPayload({
  required String courtId,
  required DateTime startAtLocal,
  required DateTime endAtLocal,
  String? customerName,
  String? customerPhone,
  String? notes,
  int? pricePerHourOverride,
}) {
  final us = startAtLocal.toUtc();
  final ue = endAtLocal.toUtc();
  final body = <String, dynamic>{
    'court_id': courtId,
    'date': _kDate.format(us),
    'start_time': _kTime.format(us),
    'end_time': _kTime.format(ue),
  };

  final name = customerName?.trim();
  if (name != null && name.isNotEmpty) body['customer_name'] = name;
  if (customerPhone != null && customerPhone.isNotEmpty) {
    body['customer_phone'] = customerPhone;
  }
  final note = notes?.trim();
  if (note != null && note.isNotEmpty) body['notes'] = note;
  if (pricePerHourOverride != null) {
    body['price_per_hour_override'] = pricePerHourOverride;
  }
  return body;
}

/// Localized confirmation copy shown after a walk-in booking is confirmed
/// (OWNER-23), e.g. `Đã xác nhận đặt sân cho Minh · T6 29/05 18:00–19:30`.
/// Pass **local** instants; [customerName] is included only when non-blank.
String confirmedBookingMessage({
  required DateTime startAtLocal,
  required DateTime endAtLocal,
  String? customerName,
}) {
  final name = customerName?.trim();
  final who = (name != null && name.isNotEmpty) ? ' cho $name' : '';
  final day = kDayLabels[startAtLocal.weekday - DateTime.monday];
  return 'Đã xác nhận đặt sân$who · $day '
      '${DateFormat('dd/MM').format(startAtLocal)} '
      '${_kTime.format(startAtLocal)}–${_kTime.format(endAtLocal)}';
}
