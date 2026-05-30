import 'package:freezed_annotation/freezed_annotation.dart';

part 'court.freezed.dart';
part 'court.g.dart';

@freezed
abstract class Court with _$Court {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Court({
    required String id,
    required String name,
    @Default(0.0) double lat,
    @Default(0.0) double lng,
    @Default(<String>[]) List<String> sportTypes,
    String? address,
    double? pricePerHour,
    String? description,
    @Default(<String>[]) List<String> amenities,
    @Default(<String>[]) List<String> photos,
  }) = _Court;

  factory Court.fromJson(Map<String, dynamic> json) => _$CourtFromJson(json);
}
