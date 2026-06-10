// Bookings feature — domain models.
//
// Supabase join shape expected:
//   bookings.select('*, slots(*, courts(*))')
//
// JSON structure:
//   {
//     "id": "...",
//     "user_id": "...",
//     "status": "confirmed",
//     "total_price": 150000,
//     "session_number": 3,
//     "total_sessions": 10,
//     "slots": {
//       "id": "...",
//       "start_at": "2026-06-15T10:00:00+07:00",
//       "end_at":   "2026-06-15T11:00:00+07:00",
//       "courts": { "id": "...", "name": "Sân A", "sport_types": ["pickleball"] }
//     }
//   }

// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_model.freezed.dart';
part 'booking_model.g.dart';

@freezed
abstract class Court with _$Court {
  const factory Court({
    required String id,
    required String name,
    @JsonKey(name: 'sport_types') @Default(<String>[]) List<String> sportTypes,
  }) = _Court;

  factory Court.fromJson(Map<String, dynamic> json) => _$CourtFromJson(json);
}

@freezed
abstract class Slot with _$Slot {
  const factory Slot({
    required String id,
    @JsonKey(name: 'start_at') required DateTime startTime,
    @JsonKey(name: 'end_at') required DateTime endTime,
    @JsonKey(name: 'courts') required Court court,
  }) = _Slot;

  factory Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);
}

@freezed
abstract class Booking with _$Booking {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Booking({
    required String id,
    required String userId,
    required String status,
    @JsonKey(name: 'slots') required Slot slot,
    @Default('one_off') String bookingType,
    int? sessionNumber,
    int? totalSessions,
    double? totalPrice,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
}

/// A play-together join request the current player has made on an open slot.
///
/// Supabase shape: `slot_join_requests.select('id, status, requested_at,
/// slots(*, courts(*))')`.
@freezed
abstract class JoinedSlotRequest with _$JoinedSlotRequest {
  const factory JoinedSlotRequest({
    required String id,
    required String status, // pending | approved | rejected
    @JsonKey(name: 'slots') required Slot slot,
    @JsonKey(name: 'requested_at') DateTime? requestedAt,
  }) = _JoinedSlotRequest;

  factory JoinedSlotRequest.fromJson(Map<String, dynamic> json) =>
      _$JoinedSlotRequestFromJson(json);
}
