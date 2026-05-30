// Domain model for a player registered in a slot (OWNER-33).
//
// A roster entry merges a `slot_participants` row (payment status) with the
// player's `bookings` row (booking status + walk-in name). Player name/avatar
// for app users live on `customers` but are NOT readable by the owner under
// current RLS (see BCORE bug), so names degrade to the walk-in name or an
// anonymous fallback until that backend policy lands.

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../requests/model/booking_request.dart';

part 'slot_player.freezed.dart';

/// Per-player payment state from `slot_participants.payment_status`
/// (`paid | unpaid | partial`). [unknown] = no participant row / unrecognized.
enum PaymentStatus { paid, unpaid, partial, unknown }

PaymentStatus paymentStatusFromRaw(String? raw) {
  switch ((raw ?? '').trim().toLowerCase()) {
    case 'paid':
      return PaymentStatus.paid;
    case 'unpaid':
      return PaymentStatus.unpaid;
    case 'partial':
      return PaymentStatus.partial;
    default:
      return PaymentStatus.unknown;
  }
}

/// One player in a slot's roster (OWNER-33).
@freezed
abstract class SlotPlayer with _$SlotPlayer {
  const SlotPlayer._();

  const factory SlotPlayer({
    /// Stable list key (participant id, else booking id, else user id).
    required String id,

    /// Display name (`Khách / Người chơi` fallback when unknown).
    required String name,

    /// The player's user id, when known.
    String? userId,

    /// Profile avatar URL — null under current owner RLS (BCORE bug).
    String? avatarUrl,

    /// Booking status badge source; null when the player has no booking row.
    BookingStatus? bookingStatus,

    @Default(PaymentStatus.unknown) PaymentStatus paymentStatus,

    /// Payment method from `slot_participants.payment_method`
    /// (`cash | transfer | app_wallet`); null when unknown or not recorded.
    String? paymentMethod,

    /// Expected amount for this player from `bookings.total_price`; null when
    /// the booking row carries no price (e.g. owner-slot, walk-in without price).
    int? expectedPrice,
  }) = _SlotPlayer;

  /// True only when the player has actually paid (drives the paid badge).
  bool get hasPaid => paymentStatus == PaymentStatus.paid;

  /// First letter for the fallback avatar.
  String get initial =>
      name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}
