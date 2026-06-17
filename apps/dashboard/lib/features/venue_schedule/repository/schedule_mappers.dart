import '../model/models.dart';

/// Pure `slots`/`courts`/`bookings` row → feature-model mapping for the
/// schedule repository. No I/O — every function takes a decoded row Map and
/// returns a model, so the subtle status/label/price rules are unit-testable
/// in isolation.

/// Venue dot palette (design handoff) — assigned to courts by stable index
/// (courts are ordered by name, so the colour is consistent across loads).
const List<int> kPalette = [
  0xFF16A34A,
  0xFF0EA5E9,
  0xFFF97316,
  0xFFA855F7,
  0xFFEC4899,
];

/// `slots.status` literals (Postgres enum:
/// `open | booked | pending | owner | blocked | maintenance`).
const String kStatusOpen = 'open';
const String kStatusBooked = 'booked';
const String kStatusPending = 'pending';
const String kStatusOwner = 'owner';
const String kStatusBlocked = 'blocked';
const String kStatusMaintenance = 'maintenance';

/// DB → display state. `fixed`/`open`/`private` never occur from real data
/// (no DB representation yet — see [kMatchmakingEnabled]).
///
/// NOTE: the slot-sync trigger (`trg_sync_slot_status_from_booking`,
/// snb-backend-core migration 0017) marks a slot `booked` as soon as a
/// booking is INSERTED — even while the booking is still pending — so a
/// literal `pending` slot status is not expected from the backend. The
/// mapping keeps the branch defensively; the authoritative pending detection
/// happens in [applyBooking] from `bookings.status`.
SlotState stateFromStatus(String status) => switch (status) {
      kStatusBooked => SlotState.confirmed,
      kStatusPending => SlotState.pending,
      kStatusOwner => SlotState.owner,
      kStatusBlocked => SlotState.locked,
      kStatusMaintenance => SlotState.maintenance,
      _ => SlotState.empty, // 'open' — bookable, no customer yet
    };

/// Vietnamese state-label fallback when no real customer name exists — same
/// vocabulary as the legacy schedule screen; never a fabricated name.
const Map<SlotState, String> kFallbackLabels = {
  SlotState.empty: 'Slot trống',
  SlotState.confirmed: 'Đã đặt',
  SlotState.pending: 'Chờ duyệt',
  SlotState.owner: 'Sân của tôi',
  SlotState.maintenance: 'Bảo trì',
  SlotState.locked: 'Đã khoá',
};

/// Maps one `slots` row to the feature's [Slot]. Times are converted to LOCAL
/// for the decimal-hour grid; `weekday` is 0=Mon..6=Sun of the local date.
/// `players`/`price`/`payment`/`bookingCode` start null — the DB has no such
/// slot columns ([applyBooking] may fill label/price).
Slot slotFromRow(Map<String, dynamic> row) {
  final start = DateTime.parse(row['start_at'] as String).toLocal();
  final end = DateTime.parse(row['end_at'] as String).toLocal();
  final state = stateFromStatus(row['status'] as String? ?? kStatusOpen);
  final date = DateTime(start.year, start.month, start.day);
  final blockedReason = (row['blocked_reason'] as String?)?.trim();
  return Slot(
    id: row['id'] as String,
    venueId: row['court_id'] as String,
    state: state,
    startHour: start.hour + start.minute / 60.0,
    durationHours: end.difference(start).inMinutes / 60.0,
    date: date,
    weekday: date.weekday - 1,
    // The owner's reason on a locked hour, else the state label.
    label: (state == SlotState.locked &&
            blockedReason != null &&
            blockedReason.isNotEmpty)
        ? blockedReason
        : kFallbackLabels[state]!,
    capacity: (row['max_players'] as num?)?.toInt(),
  );
}

/// Whether a bookings row is the live one behind its slot (vs. e.g. a leftover
/// 'completed' row of an earlier booking).
bool isActiveBooking(Map<String, dynamic> row) =>
    row['status'] == 'pending' || row['status'] == 'confirmed';

/// Applies one bookings row onto its slot — same defensive parsing as
/// `BookingRequest.fromRow` (`customer_name` for walk-ins; explicit
/// `total_price`/`price`/`amount` only — no derived price math).
///
/// `bookings.status` overrides the display state: a pending booking shows
/// "Chờ duyệt" even though the trigger already flipped the slot to `booked`.
Slot applyBooking(Slot slot, Map<String, dynamic>? booking) {
  if (booking == null) return slot;
  final state = switch (booking['status']) {
    'pending' => SlotState.pending,
    'confirmed' => SlotState.confirmed,
    _ => slot.state,
  };
  final name = (booking['customer_name'] as String?)?.trim();
  final total =
      asInt(booking['total_price'] ?? booking['price'] ?? booking['amount']);
  return slot.copyWith(
    state: state,
    label: (name != null && name.isNotEmpty)
        ? name
        // Re-derive the state label when the override changed the state
        // (the row label was computed from slots.status).
        : (state == slot.state ? slot.label : kFallbackLabels[state]!),
    price: (total != null && total > 0) ? total : null,
  );
}

/// Maps one `courts` row to the feature's [Venue] — every field derived from
/// real columns; nothing invented. [index] drives the palette colour.
Venue venueFromCourt(
  Map<String, dynamic> row,
  int index, {
  int? openHour,
  int? closeHour,
}) {
  final name = (row['name'] as String?)?.trim() ?? '';
  final sportTypes = venueSportTypes(row['venues']);
  return Venue(
    id: row['id'] as String,
    name: name,
    shortCode: shortCode(name),
    // The enum is non-null: derive it from the court's venues' sport_type
    // strings; football is the neutral default (it only drives the "MÔN"
    // chips — sportLabel below is the displayed text and stays real).
    sport: sportFromLabels(sportTypes),
    sportLabel: sportTypes.join(' · '),
    colorValue: kPalette[index % kPalette.length],
    pricePerHour: asInt(row['price_per_hour']) ?? 0,
    // Raw parsed values (no 06–22 fallback) — consumers decide their own
    // fallback so an absent operating window is never presented as real.
    openHour: openHour,
    closeHour: closeHour,
  );
}

/// Distinct `venues.sport_type` strings of a court's embedded venues. Tolerates
/// both PostgREST shapes (list for one-to-many, map when single).
List<String> venueSportTypes(Object? venues) {
  final list = venues is List ? venues : (venues is Map ? [venues] : const []);
  final out = <String>[];
  for (final v in list) {
    if (v is! Map) continue;
    final s = (v['sport_type'] as String?)?.trim();
    if (s != null && s.isNotEmpty && !out.contains(s)) out.add(s);
  }
  return out;
}

SportType sportFromLabels(List<String> labels) {
  final joined = labels.join(' ').toLowerCase();
  if (joined.contains('pickle')) return SportType.pickleball;
  if (joined.contains('tennis')) return SportType.tennis;
  return SportType.football;
}

/// "Sân 1" → "S1", "Pickleball A" → "PA", single word → first two letters.
String shortCode(String name) {
  final words = name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return '';
  if (words.length == 1) {
    final w = words.first;
    return w.substring(0, w.length < 2 ? w.length : 2).toUpperCase();
  }
  return words.map((w) => w[0]).take(3).join().toUpperCase();
}

int? asInt(Object? v) => v is num ? v.round() : null;
