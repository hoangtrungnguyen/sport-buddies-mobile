import 'package:freezed_annotation/freezed_annotation.dart';

part 'venue.freezed.dart';

@freezed
abstract class Venue with _$Venue {
  const Venue._();

  const factory Venue({
    required String id,
    required String courtId,
    required String name,
    required String sportType,
    required int capacity,
    required int pricePerHour,
    required bool isActive,
    @Default(false) bool indoor,
  }) = _Venue;

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'] as String,
      courtId: json['court_id'] as String,
      name: json['name'] as String,
      sportType: json['sport_type'] as String? ?? '',
      // capacity/price_per_hour arrive as JSON numbers from Supabase reads but
      // as decimal STRINGS from the backend API (OpenAPI types price_per_hour
      // as `string`/`decimal`) — parse both shapes defensively.
      capacity: _toInt(json['capacity'], 1),
      pricePerHour: _toInt(json['price_per_hour'], 0),
      isActive: (json['status'] as String?) != 'inactive',
      indoor: (json['indoor'] as bool?) ?? false,
    );
  }

  /// Coerces a num, a numeric String (e.g. "120000.00"), or null into an int.
  static int _toInt(Object? value, int fallback) {
    if (value is num) return value.toInt();
    if (value is String) return num.tryParse(value)?.toInt() ?? fallback;
    return fallback;
  }
}
