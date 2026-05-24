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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LatLng && other.lat == lat && other.lng == lng);

  @override
  int get hashCode => Object.hash(lat, lng);

  @override
  String toString() => 'LatLng($lat, $lng)';
}
