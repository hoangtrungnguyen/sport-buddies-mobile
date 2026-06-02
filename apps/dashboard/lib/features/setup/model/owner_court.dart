import 'package:freezed_annotation/freezed_annotation.dart';

part 'owner_court.freezed.dart';
part 'owner_court.g.dart';

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

bool _activeFromStatus(String? s) => s != 'inactive';
String _statusFromActive(bool a) => a ? 'approved' : 'inactive';

@freezed
abstract class OwnerCourt with _$OwnerCourt {
  const OwnerCourt._();

  const factory OwnerCourt({
    required String id,
    required String name,

    /// `courts.status` mapped to a bool — 'inactive' → false, anything else → true.
    @JsonKey(name: 'status', fromJson: _activeFromStatus, toJson: _statusFromActive)
    required bool isActive,

    /// `courts.operating_hours  jsonb` — `{"open": 6, "close": 22}`.
    /// Use [openHour] / [closeHour] getters for typed access.
    @JsonKey(name: 'operating_hours')
    Map<String, dynamic>? operatingHours,

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
    @Default(false)
    @JsonKey(name: 'auto_approve_single')
    bool autoApproveSingle,

    /// `courts.additional_info  jsonb` — arbitrary key/value metadata.
    /// Known keys: `google_maps_url`.
    @Default({})
    @JsonKey(name: 'additional_info')
    Map<String, dynamic> additionalInfo,
  }) = _OwnerCourt;

  factory OwnerCourt.fromJson(Map<String, dynamic> json) =>
      _$OwnerCourtFromJson(json);

  int get openHour => (operatingHours?['open'] as num?)?.toInt() ?? 6;
  int get closeHour => (operatingHours?['close'] as num?)?.toInt() ?? 22;

  /// Shortcut for `additional_info.google_maps_url`.
  String? get googleMapsUrl =>
      additionalInfo['google_maps_url'] as String?;
}
