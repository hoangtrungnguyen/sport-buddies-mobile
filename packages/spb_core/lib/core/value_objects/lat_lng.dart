import 'dart:math' as math;

/// Immutable geographic point expressed as decimal-degrees latitude /
/// longitude (WGS-84).
///
/// Per tech-plan §4.3: pure-Dart, no map-library dependency — adapters in
/// `apps/customer` convert to/from the rendering library's `LatLng`.
class LatLng {
  const LatLng(this.lat, this.lng);

  final double lat;
  final double lng;

  /// Default map center used when the user has not granted location yet:
  /// Ho Chi Minh City core (≈ Nguyen Hue walking street).
  static const LatLng hcmcDefault = LatLng(10.776, 106.701);

  /// Earth's mean radius in kilometers.
  static const double _earthRadiusKm = 6371.0;

  /// Calculates the great-circle distance to [other] using the Haversine
  /// formula, returning the distance in kilometers.
  ///
  /// The Haversine formula computes the shortest distance over the Earth's
  /// surface, assuming a spherical Earth (radius 6371 km).
  double distanceTo(LatLng other) {
    final dLat = _toRadians(other.lat - lat);
    final dLon = _toRadians(other.lng - lng);

    final a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_toRadians(lat)) *
            math.cos(_toRadians(other.lat)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2));

    final c = 2 * math.asin(math.sqrt(a));
    return _earthRadiusKm * c;
  }

  /// Returns true if [other] is within [radiusKm] kilometers of this point.
  bool isWithinRadius(LatLng other, double radiusKm) {
    return distanceTo(other) <= radiusKm;
  }

  double _toRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LatLng && other.lat == lat && other.lng == lng);

  @override
  int get hashCode => Object.hash(lat, lng);

  @override
  String toString() => 'LatLng($lat, $lng)';
}
