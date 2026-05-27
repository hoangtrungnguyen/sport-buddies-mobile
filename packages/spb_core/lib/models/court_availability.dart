// Court availability model — grava-c9ca.2.1.
//
// Pairs a court's basic display info with the count of open (available) slots
// so that map markers can be coloured without requiring a separate data-join
// in the UI layer.

import 'dart:ui';

/// The green used for "has open slots" markers — SportBuddies brand green.
const Color _markerGreen = Color(0xFF2E7D32);

/// The grey used for "no open slots" / fully-booked markers.
const Color _markerGrey = Color(0xFF9E9E9E);

/// An approved court enriched with real-time slot availability.
///
/// [openSlotCount] is the number of slots where `status = 'open'` and
/// `start_time > now()`. A value of `0` means the court is fully booked or
/// has no future slots.
///
/// [markerColor] derives the correct pin colour without any UI-layer
/// conditionals — widgets simply read this property.
final class CourtAvailability {
  const CourtAvailability({
    required this.courtId,
    required this.name,
    required this.lat,
    required this.lng,
    required this.openSlotCount,
    this.sportType = '',
  });

  /// Supabase `courts.id` (UUID string).
  final String courtId;

  /// Display name shown in the bottom sheet / tooltip.
  final String name;

  /// Latitude of the court (WGS-84).
  final double lat;

  /// Longitude of the court (WGS-84).
  final double lng;

  /// Number of future open slots for this court.
  final int openSlotCount;

  /// Sport type slug (e.g. `'football'`, `'badminton'`). Empty string if
  /// the court is multi-sport or the value was not fetched.
  final String sportType;

  /// Map pin colour derived from [openSlotCount].
  ///
  /// - Green ([_markerGreen]) when the court has at least one open slot.
  /// - Grey ([_markerGrey]) when the court is fully booked or has no future
  ///   slots.
  Color get markerColor => openSlotCount > 0 ? _markerGreen : _markerGrey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourtAvailability &&
          other.courtId == courtId &&
          other.name == name &&
          other.lat == lat &&
          other.lng == lng &&
          other.openSlotCount == openSlotCount &&
          other.sportType == sportType);

  @override
  int get hashCode =>
      Object.hash(courtId, name, lat, lng, openSlotCount, sportType);

  @override
  String toString() =>
      'CourtAvailability(courtId: $courtId, name: $name, '
      'lat: $lat, lng: $lng, openSlotCount: $openSlotCount, '
      'sportType: $sportType)';
}
