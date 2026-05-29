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
//     "session_number": 3,
//     "total_sessions": 10,
//     "slots": {
//       "id": "...",
//       "start_time": "2026-06-15T10:00:00+07:00",
//       "end_time":   "2026-06-15T11:00:00+07:00",
//       "courts": { "id": "...", "name": "Sân A" }
//     }
//   }

import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_model.freezed.dart';
part 'booking_model.g.dart';

@freezed
abstract class Court with _$Court {
  const factory Court({
    required String id,
    required String name,
  }) = _Court;

  factory Court.fromJson(Map<String, dynamic> json) => _$CourtFromJson(json);
}

@freezed
abstract class Slot with _$Slot {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Slot({
    required String id,
    required DateTime startTime,
    required DateTime endTime,
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
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
}
