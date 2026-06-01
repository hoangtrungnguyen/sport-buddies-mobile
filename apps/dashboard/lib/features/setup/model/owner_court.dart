import 'package:freezed_annotation/freezed_annotation.dart';

part 'owner_court.freezed.dart';

const kSportTypes = [
  'Bóng đá 5v5',
  'Bóng đá 7v7',
  'Bóng đá 11v11',
  'Pickleball',
  'Tennis',
  'Cầu lông',
  'Bóng rổ',
  'Đa năng',
];

const kAmenities = [
  'Bãi đậu xe',
  'Phòng thay đồ',
  'Nhà vệ sinh',
  'Căng tin',
  'Thuê thiết bị',
  'WiFi',
  'Đèn chiếu sáng',
  'Mái che',
];

@freezed
abstract class OwnerCourt with _$OwnerCourt {
  const OwnerCourt._();

  const factory OwnerCourt({
    required String id,
    required String name,

    /// `courts.sport_types  text[]`
    required List<String> sportTypes,

    required int capacity,

    /// From `courts.operating_hours  jsonb` as {"open":6,"close":22}
    required int openHour,
    required int closeHour,

    /// `courts.price_per_hour  numeric`
    required int pricePerHour,

    /// `courts.status != 'inactive'`
    required bool isActive,

    /// `courts.address`
    String? address,

    /// `courts.description`
    String? description,

    /// `courts.amenities  text[]`
    @Default([]) List<String> amenities,

    /// `courts.lat` / `courts.lng`
    double? lat,
    double? lng,

    /// `courts.auto_approve_single` — OWNER-44/45
    @Default(false) bool autoApproveSingle,
  }) = _OwnerCourt;

  factory OwnerCourt.fromJson(Map<String, dynamic> json) {
    final sports = (json['sport_types'] as List?)
            ?.map((e) => e as String)
            .toList() ??
        [];
    final amenities = (json['amenities'] as List?)
            ?.map((e) => e as String)
            .toList() ??
        [];
    final hours = json['operating_hours'] as Map<String, dynamic>?;
    return OwnerCourt(
      id: json['id'] as String,
      name: json['name'] as String,
      sportTypes: sports,
      capacity: (json['capacity'] as num?)?.toInt() ?? 2,
      openHour: (hours?['open'] as num?)?.toInt() ?? 6,
      closeHour: (hours?['close'] as num?)?.toInt() ?? 22,
      pricePerHour: (json['price_per_hour'] as num?)?.toInt() ?? 0,
      isActive: (json['status'] as String?) != 'inactive',
      address: json['address'] as String?,
      description: json['description'] as String?,
      amenities: amenities,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      autoApproveSingle: (json['auto_approve_single'] as bool?) ?? false,
    );
  }

  String get primarySport => sportTypes.isNotEmpty ? sportTypes.first : '';
}
