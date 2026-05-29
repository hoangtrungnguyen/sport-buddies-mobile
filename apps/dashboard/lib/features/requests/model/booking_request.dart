// Domain model for the owner "incoming booking requests" list (OWNER-27).
//
// A [BookingRequest] is one row of the `bookings` table joined to its slot and
// court. The dashboard had never read `bookings` before this story, so the
// exact column set is **assumed** here and parsed defensively — mirroring how
// `OwnerSlot.fromRow` documents its slot contract. See [BookingRequest.fromRow]
// for the assumed shape and the backend follow-ups it implies.

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
/// them with `.toLocal()`. [revenue] is the already-resolved VND amount for this
/// booking (see [fromRow]).
class BookingRequest {
  const BookingRequest({
    required this.id,
    required this.code,
    required this.customerName,
    required this.courtName,
    required this.startAt,
    required this.endAt,
    required this.status,
    required this.revenue,
  });

  /// Raw `bookings.id` (UUID) — the stable key.
  final String id;

  /// Short, human-facing order code shown on the card (e.g. `#A1B2C3`).
  final String code;

  /// Display name of the customer. Falls back to `Khách lẻ` for an anonymous
  /// walk-in with no recorded name.
  final String customerName;

  /// Name of the booked court.
  final String courtName;

  /// Slot start (UTC). Render `.toLocal()`.
  final DateTime startAt;

  /// Slot end (UTC). Render `.toLocal()`.
  final DateTime endAt;

  final BookingStatus status;

  /// Resolved VND revenue for this booking (explicit total if the row carried
  /// one, otherwise court price-per-hour × duration). `0` when neither is known.
  final int revenue;

  bool get isCancelled => status == BookingStatus.cancelled;
  bool get isPending => status == BookingStatus.pending;
  bool get isConfirmed => status == BookingStatus.confirmed;

  /// Slot length in (possibly fractional) hours.
  double get durationHours => endAt.difference(startAt).inMinutes / 60.0;

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
  ///   "total_price": 300000,            // optional explicit total (VND)
  ///   "profiles": { "full_name": "…" }, // app-user bookings (joined)
  ///   "slots": {
  ///     "start_at": "2026-05-29T11:00:00Z",
  ///     "end_at":   "2026-05-29T12:30:00Z",
  ///     "courts": { "name": "Sân 1", "price_per_hour": 200000 }
  ///   }
  /// }
  /// ```
  ///
  /// Parsing is intentionally tolerant: a missing customer name, code, or price
  /// degrades to a sensible default rather than throwing, so one odd row can't
  /// blank the whole queue. Named `fromRow` (not `fromJson`) so freezed/
  /// json_serializable is never wired — the dashboard does not depend on it.
  ///
  /// Backend follow-ups (filed separately): confirm `bookings.customer_name`
  /// exists for walk-ins, confirm the revenue column name, and confirm RLS
  /// scopes `bookings` to `courts.owner_id = auth.uid()`.
  factory BookingRequest.fromRow(Map<String, dynamic> row) {
    final slot = _asMap(row['slots']);
    final court = _asMap(slot['courts']);

    final start = _parseDate(slot['start_at']) ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final end = _parseDate(slot['end_at']) ?? start;

    final pricePerHour = _asInt(court['price_per_hour']);
    final durationHours = end.difference(start).inMinutes / 60.0;
    // Treat a positive explicit total as authoritative; a 0/absent total is
    // taken as "unset" and falls back to court price × duration (a `0` is far
    // more likely a missing column than a genuinely free booking).
    final explicitTotal = _asInt(row['total_price'] ?? row['price'] ?? row['amount']);
    final revenue = (explicitTotal != null && explicitTotal > 0)
        ? explicitTotal
        : (pricePerHour != null ? (pricePerHour * durationHours).round() : 0);

    return BookingRequest(
      id: row['id']?.toString() ?? '',
      code: _resolveCode(row),
      customerName: _resolveCustomerName(row),
      courtName: (court['name'] as String?)?.trim().isNotEmpty == true
          ? court['name'] as String
          : 'Sân',
      startAt: start,
      endAt: end,
      status: bookingStatusFromRaw(row['status'] as String?),
      revenue: revenue,
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

  /// Uses an explicit order code when present, else derives a short `#`-prefixed
  /// code from the first 6 hex chars of the UUID.
  static String _resolveCode(Map<String, dynamic> row) {
    final explicit = (row['code'] ?? row['reference']) as String?;
    final e = explicit?.trim();
    if (e != null && e.isNotEmpty) return e.startsWith('#') ? e : '#$e';
    final id = row['id']?.toString() ?? '';
    final head = id.replaceAll('-', '');
    return head.isEmpty ? '#—' : '#${head.substring(0, head.length < 6 ? head.length : 6).toUpperCase()}';
  }
}
