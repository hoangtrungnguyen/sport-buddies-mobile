/// Extracts coordinates from a Google Maps place URL.
///
/// Two coordinate sources appear in a typical share URL:
///   - the place pin — `…!3d10.7699787!4d106.6660344` (precise location)
///   - the viewport center — `…/@10.7699682,106.6516615,3736m/…`
///
/// The pin is preferred; the viewport center is the fallback. Returns null when
/// no usable pair is found.
({double lat, double lng})? extractLatLngFromMapsUrl(String url) {
  // Place pin: !3d<lat>!4d<lng>
  final pin = RegExp(r'!3d(-?\d+(?:\.\d+)?)!4d(-?\d+(?:\.\d+)?)').firstMatch(url);
  if (pin != null) {
    final coords = _parse(pin.group(1), pin.group(2));
    if (coords != null) return coords;
  }
  // Viewport center: @<lat>,<lng>
  final at = RegExp(r'@(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)').firstMatch(url);
  if (at != null) {
    final coords = _parse(at.group(1), at.group(2));
    if (coords != null) return coords;
  }
  return null;
}

({double lat, double lng})? _parse(String? latStr, String? lngStr) {
  final lat = double.tryParse(latStr ?? '');
  final lng = double.tryParse(lngStr ?? '');
  if (lat == null || lng == null) return null;
  if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;
  return (lat: lat, lng: lng);
}
