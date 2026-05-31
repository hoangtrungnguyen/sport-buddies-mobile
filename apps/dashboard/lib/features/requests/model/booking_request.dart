// Domain model for the owner "incoming booking requests" list (OWNER-27/28/29).
//
// A [BookingRequest] is one row of the `bookings` table joined to its slot and
// court. The dashboard had never read `bookings` before OWNER-27, so the exact
// column set is **assumed** here and parsed defensively. See
// [BookingRequest.fromRow] for the assumed shape and the backend follow-ups it
// implies.

import 'package:freezed_annotation/freezed_annotation.dart';

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

  /// Maps a Supabase `bookings` row to a [BookingRequest].
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
  ///     "courts": { "name": "Sân 1", "price_per_hour": 200000 }
  ///   }
  /// }
  /// ```
  ///
  /// Parsing is intentionally tolerant: a missing customer name, code, price, or
  /// phone degrades to a sensible default rather than throwing. Named `fromRow`
  /// (not `fromJson`) so json_serializable is never wired.
  ///
  /// Backend follow-ups (filed separately): confirm `bookings.customer_name`/
  /// `customer_phone` for walk-ins, the revenue column name, and that RLS
  /// scopes `bookings` to `courts.owner_id = auth.uid()`.
  factory BookingRequest.fromRow(Map<String, dynamic> row) {
    final slot = _asMap(row['slots']);
    final court = _asMap(slot['courts']);

    final start = _parseDate(slot['start_at']) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final end = _parseDate(slot['end_at']) ?? start;

    final pricePerHour = _asInt(court['price_per_hour']);
    final durationHours = end.difference(start).inMinutes / 60.0;
    // A positive explicit total is authoritative; a 0/absent total is treated
    // as "unset" and falls back to court price × duration.
    final explicitTotal =
        _asInt(row['total_price'] ?? row['price'] ?? row['amount']);
    final revenue = (explicitTotal != null && explicitTotal > 0)
        ? explicitTotal
        : (pricePerHour != null ? (pricePerHour * durationHours).round() : 0);

    return BookingRequest(
      id: row['id']?.toString() ?? '',
      slotId: (slot['id'] ?? row['slot_id'])?.toString(),
      code: _resolveCode(row),
      customerName: _resolveCustomerName(row),
      customerPhone: _resolveCustomerPhone(row),
      courtName: (court['name'] as String?)?.trim().isNotEmpty == true
          ? court['name'] as String
          : 'Sân',
      startAt: start,
      endAt: end,
      status: bookingStatusFromRaw(row['status'] as String?),
      revenue: revenue,
      isAutoApproved: (row['is_auto_approved'] as bool?) ?? false,
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
    final id = row['id']?.toString() ?? '';
    final head = id.replaceAll('-', '');
    return head.isEmpty
        ? '#—'
        : '#${head.substring(0, head.length < 6 ? head.length : 6).toUpperCase()}';
  }
}
