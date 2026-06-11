// EPIC-5 domain models — bookable slot & open-group slot (handoff doc 04 §1).

import 'court.dart';
import 'schedule.dart';

/// One bookable slot in the picker (screen 09).
class TimeSlot {
  const TimeSlot({
    required this.id,
    required this.courtId,
    required this.start,
    required this.end,
    required this.priceVnd,
    required this.status,
  });

  final String id;
  final String courtId;
  final DateTime start;
  final DateTime end;
  final int priceVnd;
  final CellStatus status;

  bool get isOpen => status == CellStatus.open;
  Duration get duration => end.difference(start);
}

/// A "Slot mở chơi ghép" row (screens 07 §8 / 09 §8).
class OpenGroupSlot {
  const OpenGroupSlot({
    required this.id,
    required this.courtLabel,
    required this.sport,
    required this.timeLabel,
    required this.joined,
    required this.max,
  });

  final String id;
  final String courtLabel; // "Sân A · Đôi nam"
  final Sport sport;
  final String timeLabel; // "Hôm nay · 19:00 – 21:00"
  final int joined;
  final int max;

  int get placesLeft => max - joined;
  bool get isFull => joined >= max;
}
