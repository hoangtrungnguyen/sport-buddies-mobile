import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'court_availability.freezed.dart';

const Color _markerGreen = Color(0xFF2E7D32);
const Color _markerGrey = Color(0xFF9E9E9E);

/// An approved court enriched with real-time slot availability.
///
/// [openSlotCount] is the number of slots where `status = 'open'` and
/// `start_at > now()`. A value of `0` means the court is fully booked or
/// has no future slots.
@freezed
abstract class CourtAvailability with _$CourtAvailability {
  const CourtAvailability._();

  const factory CourtAvailability({
    required String courtId,
    required String name,
    required double lat,
    required double lng,
    required int openSlotCount,
    @Default('') String sportType,
  }) = _CourtAvailability;

  /// Map pin colour derived from [openSlotCount].
  Color get markerColor => openSlotCount > 0 ? _markerGreen : _markerGrey;
}
