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
  }) = _Venue;

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'] as String,
      courtId: json['court_id'] as String,
      name: json['name'] as String,
      sportType: json['sport_type'] as String? ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 1,
      pricePerHour: (json['price_per_hour'] as num?)?.toInt() ?? 0,
      isActive: (json['status'] as String?) != 'inactive',
    );
  }
}
