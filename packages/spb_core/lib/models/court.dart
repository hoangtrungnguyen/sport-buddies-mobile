import 'package:freezed_annotation/freezed_annotation.dart';

part 'court.freezed.dart';
part 'court.g.dart';

@freezed
abstract class Court with _$Court {
  const factory Court({
    required String id,
    required String name,
    required double lat,
    required double lng,
  }) = _Court;

  factory Court.fromJson(Map<String, dynamic> json) => _$CourtFromJson(json);
}
