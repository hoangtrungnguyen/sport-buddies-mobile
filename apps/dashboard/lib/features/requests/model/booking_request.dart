// Domain model for the owner "incoming booking requests" list (OWNER-27/28/29).
//
// A [BookingRequest] is a lean projection of the shared [Booking] (spb_core)
// onto exactly the fields the owner queue card needs. The Supabase row is first
// parsed into a canonical [Booking] (see [BookingRequest._coreFromRow], which
// holds the defensive join-resolution), then extracted via
// [BookingRequest.fromCore]. The dashboard had never read `bookings` before
// OWNER-27, so the exact column set is **assumed** here and parsed defensively.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spb_core/spb_core.dart' show Booking, Slot;

part 'booking_request.freezed.dart';

/// The three request states the owner queue distinguishes (OWNER-27 AC):
/// yellow = [pending] (Chờ xác nhận), green = [confirmed] (Đã xác nhận),
/// gray = [cancelled] (Đã huỷ).
enum BookingStatus { pending, confirmed, cancelled }

/// Maps a raw `bookings.status` string to a [BookingStatus].
///
/// The backend's exact vocabulary is not pinned in this repo, so synonyms are
/// folded conservatively: `confirmed`/`booked`/`approved` → [confirmed],
/// `cancelled`/`canceled`/`rejected` → [cancelled], and anything else
/// (`pending`, `awaiting`, unknown) → [pending] (the safe "needs attention"
/// bucket so a stray value never silently disappears from the queue).
BookingStatus bookingStatusFromRaw(String? raw) {
  switch ((raw ?? '').trim().toLowerCase()) {
    case 'confirmed':
    case 'booked':
    case 'approved':
    case 'completed': // a finished booking reads as a confirmed/honored one
      return BookingStatus.confirmed;
    case 'cancelled':
    case 'canceled':
    case 'rejected':
    case 'declined':
      return BookingStatus.cancelled;
    default:
      return BookingStatus.pending;
  }
}

/// One incoming booking request as shown on the owner's daily queue.
///
/// [startAt]/[endAt] are stored UTC instants (parsed from the slot row); render
/// them with `.toLocal()`. [revenue] is the already-resolved VND amount.
@freezed
abstract class BookingRequest with _$BookingRequest {
  const BookingRequest._();

  const factory BookingRequest({
    /// Raw `bookings.id` (UUID) — the stable key.
    required String id,

    /// Short, human-facing order code shown on the card (e.g. `#A1B2C3`).
    required String code,

    /// Display name of the customer (`Khách lẻ` when anonymous).
    required String customerName,

    /// Name of the booked court.
    required String courtName,

    /// Slot start (UTC). Render `.toLocal()`.
    required DateTime startAt,

    /// Slot end (UTC). Render `.toLocal()`.
    required DateTime endAt,

    required BookingStatus status,

    /// Resolved VND revenue (explicit total if > 0, else court price ×
    /// duration; `0` when neither is known).
    required int revenue,

    /// Linked `slots.id`, when the join provided it — needed to free the slot
    /// on reject (OWNER-29).
    String? slotId,

    /// Customer phone. Per OWNER-28 it is only surfaced on the card **after**
    /// approval — see [revealedPhone], which gates on [status].
    String? customerPhone,

    /// Whether this booking was auto-approved by the system (OWNER-45).
    /// Shown as a "Tự động" chip on confirmed cards.
    @Default(false) bool isAutoApproved,

    /// Sport type from the venue (OWNER-213). Empty string when unavailable.
    @Default('') String sportType,

    /// Name of the specific venue (playable area) within the court (OWNER-226).
    /// Empty string when unavailable (e.g. court has no venues yet).
    @Default('') String venueName,
  }) = _BookingRequest;

  bool get isCancelled => status == BookingStatus.cancelled;
  bool get isPending => status == BookingStatus.pending;
  bool get isConfirmed => status == BookingStatus.confirmed;

  /// Slot length in (possibly fractional) hours.
  double get durationHours => endAt.difference(startAt).inMinutes / 60.0;

  /// The phone to show on the card, or null when it must stay hidden. OWNER-28:
  /// the customer's number is revealed only once the booking is [confirmed].
  String? get revealedPhone {
    final p = customerPhone?.trim();
    return (isConfirmed && p != null && p.isNotEmpty) ? p : null;
  }

  /// Extracts the owner-queue subset from a canonical [Booking].
  ///
  /// Timing/slot come from the booking's first slot; the queue is one card per
  /// booking and the dashboard read only ever joins a single slot per row.
  /// The shared [Booking.status] string is re-folded through
  /// [bookingStatusFromRaw] into the three-state queue enum.
  factory BookingRequest.fromCore(Booking core) {
    final slot = core.slots.isNotEmpty ? core.slots.first : null;
    final start =
        slot?.startTime ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final end = slot?.endTime ?? start;
    return BookingRequest(
      id: core.id,
      slotId: slot?.id,
      code: core.code ?? _codeFromId(core.id),
      customerName: (core.customerName?.trim().isNotEmpty == true)
          ? core.customerName!.trim()
          : 'Khách lẻ',
      customerPhone: core.customerPhone,
      courtName: (core.courtName?.trim().isNotEmpty == true)
          ? core.courtName!.trim()
          : 'Sân',
      startAt: start,
      endAt: end,
      status: bookingStatusFromRaw(core.status),
      revenue: core.totalPrice,
      isAutoApproved: core.isAutoApproved,
      sportType: core.sportType ?? '',
      venueName: core.venueName ?? '',
    );
  }

  /// Maps a Supabase `bookings` row to a [BookingRequest] by way of the shared
  /// [Booking] model — see [_coreFromRow] for the assumed join shape and the
  /// backend follow-ups it implies. Named `fromRow` (not `fromJson`) so
  /// json_serializable is never wired.
  factory BookingRequest.fromRow(Map<String, dynamic> row) =>
      BookingRequest.fromCore(_coreFromRow(row));

  /// Parses a Supabase `bookings` row (joined with `slots` → `courts` →
  /// `venues`) into a canonical [Booking].
  ///
  /// **Assumed join shape** (matches the verified customer read path
  /// `bookings.select('*, slots(*, courts(*))')`, extended for the owner queue):
  ///
  /// ```json
  /// {
  ///   "id": "uuid",
  ///   "status": "pending" | "confirmed" | "cancelled",
  ///   "code": "A1B2C3",                 // optional human order code
  ///   "customer_name": "Nguyễn Văn A",  // walk-ins (created via Django)
  ///   "customer_phone": "+8490…",       // walk-ins; else profiles.phone
  ///   "total_price": 300000,            // optional explicit total (VND)
  ///   "profiles": { "full_name": "…", "phone": "…" }, // app-user bookings
  ///   "slots": {
  ///     "id": "uuid",
  ///     "start_at": "2026-05-29T11:00:00Z",
  ///     "end_at":   "2026-05-29T12:30:00Z",
  ///     "courts": {
  ///       "name": "Sân 1", "price_per_hour": 200000,
  ///       "venues": { "name": "Sân A", "sport_type": "football", "price_per_hour": 250000 }
  ///     }
  ///   }
  /// }
  /// ```
  ///
  /// Parsing is intentionally tolerant: a missing customer name, code, price, or
  /// phone degrades to a sensible default rather than throwing.
  ///
  /// Backend follow-ups (filed separately): confirm `bookings.customer_name`/
  /// `customer_phone` for walk-ins, the revenue column name, and that RLS
  /// scopes `bookings` to `courts.owner_id = auth.uid()`.
  static Booking _coreFromRow(Map<String, dynamic> row) {
    final slotRow = _asMap(row['slots']);
    // Schema: slots → courts → venues (venues.court_id FK, traversed in reverse).
    final court = _asMap(slotRow['courts']);
    final venue = _asMap(court['venues']);

    final start = _parseDate(slotRow['start_at']) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final end = _parseDate(slotRow['end_at']) ?? start;

    // Revenue: explicit total wins; fallback to venue price × duration.
    final pricePerHour =
        _asInt(venue['price_per_hour']) ?? _asInt(court['price_per_hour']);
    final durationHours = end.difference(start).inMinutes / 60.0;
    final explicitTotal =
        _asInt(row['total_price'] ?? row['price'] ?? row['amount']);
    final revenue = (explicitTotal != null && explicitTotal > 0)
        ? explicitTotal
        : (pricePerHour != null ? (pricePerHour * durationHours).round() : 0);

    final id = row['id']?.toString() ?? '';
    final sportType = (venue['sport_type'] as String?) ?? '';
    final courtName = (court['name'] as String?)?.trim().isNotEmpty == true
        ? court['name'] as String
        : 'Sân';
    final slotId = (slotRow['id'] ?? row['slot_id'])?.toString();

    return Booking(
      id: id,
      code: _resolveCode(row),
      status: (row['status'] as String?) ?? 'pending',
      courtName: courtName,
      venueName: (venue['name'] as String?)?.trim() ?? '',
      sportType: sportType,
      totalPrice: revenue,
      customerName: _resolveCustomerName(row),
      customerPhone: _resolveCustomerPhone(row),
      isAutoApproved: (row['is_auto_approved'] as bool?) ?? false,
      slots: slotId == null
          ? const <Slot>[]
          : [
              Slot(
                id: slotId,
                startTime: start,
                endTime: end,
                courtId: (court['id'] ?? '').toString(),
                courtName: courtName,
                sportType: sportType,
              ),
            ],
    );
  }

  static Map<String, dynamic> _asMap(Object? v) =>
      v is Map ? v.cast<String, dynamic>() : const <String, dynamic>{};

  static int? _asInt(Object? v) => v is num ? v.round() : null;

  static DateTime? _parseDate(Object? v) =>
      v is String ? DateTime.tryParse(v) : null;

  /// Prefers a recorded walk-in name, then a joined app-user profile name,
  /// then the anonymous fallback.
  static String _resolveCustomerName(Map<String, dynamic> row) {
    final direct = (row['customer_name'] as String?)?.trim();
    if (direct != null && direct.isNotEmpty) return direct;
    final profile = _asMap(row['profiles']);
    final full = (profile['full_name'] ?? profile['name']) as String?;
    final ft = full?.trim();
    if (ft != null && ft.isNotEmpty) return ft;
    return 'Khách lẻ';
  }

  /// Walk-in phone (`customer_phone`) or a joined app-user profile phone, else
  /// null. Display is still gated on approval by [revealedPhone].
  static String? _resolveCustomerPhone(Map<String, dynamic> row) {
    final direct = (row['customer_phone'] as String?)?.trim();
    if (direct != null && direct.isNotEmpty) return direct;
    final profile = _asMap(row['profiles']);
    final p = (profile['phone'] ?? profile['phone_number']) as String?;
    final pt = p?.trim();
    return (pt != null && pt.isNotEmpty) ? pt : null;
  }

  /// Uses an explicit order code when present, else derives a short `#`-prefixed
  /// code from the first 6 hex chars of the UUID.
  static String _resolveCode(Map<String, dynamic> row) {
    final explicit = (row['code'] ?? row['reference']) as String?;
    final e = explicit?.trim();
    if (e != null && e.isNotEmpty) return e.startsWith('#') ? e : '#$e';
    return _codeFromId(row['id']?.toString() ?? '');
  }

  /// Derives a short `#`-prefixed code from the first 6 hex chars of a UUID.
  static String _codeFromId(String id) {
    final head = id.replaceAll('-', '');
    return head.isEmpty
        ? '#—'
        : '#${head.substring(0, head.length < 6 ? head.length : 6).toUpperCase()}';
  }
}
