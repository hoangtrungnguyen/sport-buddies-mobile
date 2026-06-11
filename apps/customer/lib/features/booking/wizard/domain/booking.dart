// Booking-wizard domain models (handoff doc 04 §2).

import 'package:customer/features/court/domain/booking_draft.dart';

enum AccessPolicy { private, open }

enum BookingStatus { pending, confirmed, declined, cancelled }

extension BookingStatusX on BookingStatus {
  /// Owner rejected / the booking can no longer become confirmed.
  bool get isTerminalNegative =>
      this == BookingStatus.declined || this == BookingStatus.cancelled;

  static BookingStatus fromRow(String? raw) => switch (raw) {
        'confirmed' => BookingStatus.confirmed,
        'declined' => BookingStatus.declined,
        'cancelled' => BookingStatus.cancelled,
        _ => BookingStatus.pending,
      };
}

/// Editable contact details — pre-filled from the profile on Step 1.
class ContactInfo {
  const ContactInfo({required this.name, required this.phone, this.note});

  final String name;
  final String phone;
  final String? note;
}

/// The confirmed/pending reservation — only exists after `createBooking`
/// returns (doc 04 §3: nothing shows "#SPB-…" before the RPC succeeds).
class Booking {
  const Booking({
    required this.id,
    required this.status,
    required this.centerId,
    required this.courtId,
    required this.slots,
    required this.access,
    required this.totalVnd,
    required this.createdAt,
    this.maxPlayers,
    this.confirmedAt,
  });

  final String id; // "SPB-08423" → displayed "#SPB-08423"
  final BookingStatus status;
  final String centerId;
  final String courtId;
  final List<SlotSelection> slots;
  final AccessPolicy access;
  final int? maxPlayers; // when access == open
  final int totalVnd;
  final DateTime createdAt; // "14:22" on the timeline
  final DateTime? confirmedAt;

  Booking copyWith({BookingStatus? status, DateTime? confirmedAt}) => Booking(
        id: id,
        status: status ?? this.status,
        centerId: centerId,
        courtId: courtId,
        slots: slots,
        access: access,
        maxPlayers: maxPlayers,
        totalVnd: totalVnd,
        createdAt: createdAt,
        confirmedAt: confirmedAt ?? this.confirmedAt,
      );
}
