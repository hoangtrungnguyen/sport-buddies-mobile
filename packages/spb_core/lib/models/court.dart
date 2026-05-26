/// Represents a sports court in the SportBuddies marketplace.
///
/// Only carries the fields needed for map display (id, name, lat, lng).
/// Additional fields (address, sport type, pricing) are loaded lazily by the
/// court-detail feature — keeping this lean speeds up the map query.
class Court {
  const Court({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
  });

  /// Supabase row identifier (UUID as string).
  final String id;

  /// Display name of the court.
  final String name;

  /// WGS-84 latitude in decimal degrees.
  final double lat;

  /// WGS-84 longitude in decimal degrees.
  final double lng;

  /// Deserialises a Supabase-style JSON row returned by:
  ///   `select('id, name, lat, lng').eq('status', 'approved')`
  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'] as String,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Court &&
          other.id == id &&
          other.name == name &&
          other.lat == lat &&
          other.lng == lng);

  @override
  int get hashCode => Object.hash(id, name, lat, lng);

  @override
  String toString() => 'Court(id: $id, name: $name, lat: $lat, lng: $lng)';
}
