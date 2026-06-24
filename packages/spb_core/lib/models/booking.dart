import 'package:freezed_annotation/freezed_annotation.dart';

import 'slot.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

/// Canonical reservation entity shared across apps.
///
/// Superset of the customer wizard booking, the customer bookings DTO, and the
/// dashboard booking request. Each app should construct/extract only the fields
/// it needs from this model (e.g. via a mapper into a lighter view-model), not
/// duplicate the shape. Status fields are strings (not enums) to tolerate
/// backend values an app doesn't know about yet — use the getters below for
/// safe checks, or [BookingStatusX.fromRaw] to normalize raw values.
@freezed
abstract class Booking with _$Booking {
  const Booking._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Booking({
    required String id,

    /// Human-facing reference code (e.g. dashboard request code). Optional.
    String? code,

    /// Owner of the booking (customer user id).
    String? userId,

    /// `pending` | `confirmed` | `declined` | `cancelled` | `completed`.
    @Default('pending') String status,

    /// `private` | `open` — who may join the booked slots.
    @Default('private') String accessPolicy,
    String? courtId,
    String? courtName,
    String? venueName,
    String? sportType,
    @Default(<Slot>[]) List<Slot> slots,

    /// Total price in VND.
    @Default(0) int totalPrice,
    @Default(1) int maxPlayers,

    /// Contact details, mainly for the owner-facing dashboard.
    String? customerName,
    String? customerPhone,
    String? note,

    /// `oneOff` | `recurring`.
    @Default('oneOff') String bookingType,
    int? sessionNumber,
    int? totalSessions,
    @Default(false) bool isAutoApproved,
    DateTime? createdAt,
    DateTime? confirmedAt,
  }) = _Booking;

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled' || status == 'declined';
  bool get isOpen => accessPolicy == 'open';
  bool get isRecurring => bookingType == 'recurring';

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);
}

/// Canonical booking status values used across apps.
enum BookingStatus { pending, confirmed, declined, cancelled, completed }

extension BookingStatusX on BookingStatus {
  /// Normalize a raw backend string into a [BookingStatus].
  /// Unknown / null values fall back to [BookingStatus.pending].
  static BookingStatus fromRaw(String? raw) {
    switch (raw?.trim().toLowerCase()) {
      case 'confirmed':
      case 'booked':
      case 'approved':
        return BookingStatus.confirmed;
      case 'completed':
        return BookingStatus.completed;
      case 'declined':
      case 'rejected':
        return BookingStatus.declined;
      case 'cancelled':
      case 'canceled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }

  String get wireValue => name;

  bool get isTerminalNegative =>
      this == BookingStatus.declined || this == BookingStatus.cancelled;
}

/// Who may join the booked slots.
enum AccessPolicy { private, open }

extension AccessPolicyX on AccessPolicy {
  static AccessPolicy fromRaw(String? raw) =>
      raw?.trim().toLowerCase() == 'open' ? AccessPolicy.open : AccessPolicy.private;

  String get wireValue => name;
}
