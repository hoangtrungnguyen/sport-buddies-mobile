import 'package:customer/core/mixins/app_exception_mixin.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'court_schedule_overview_state.freezed.dart';

enum SlotStatus { open, booked, closed }

class ScheduleCourt {
  const ScheduleCourt({
    required this.id,
    required this.name,
    required this.sport,
  });

  final String id;
  final String name;
  final String sport;
}

class ScheduleSlot {
  const ScheduleSlot({
    required this.status,
    required this.price,
    required this.endLabel,
  });

  final SlotStatus status;
  final int price;
  final String endLabel;
}

/// A lane within a court ("Sân A" / "Sân B") — one schedule grid row.
/// Maps a backend `venues[]` item from `GET /api/courts/{id}/schedule`.
class ScheduleVenue {
  const ScheduleVenue({
    required this.id,
    required this.name,
    required this.sportType,
    required this.slots,
  });

  final String id;
  final String name;
  final String sportType;
  final List<VenueSlot> slots;

  factory ScheduleVenue.fromJson(Map<String, dynamic> json) => ScheduleVenue(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    sportType: json['sport_type'] as String? ?? '',
    slots: (json['slots'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(VenueSlot.fromJson)
        .toList(),
  );
}

/// A real, bookable time slot from the court schedule API.
class VenueSlot {
  const VenueSlot({
    required this.id,
    required this.start,
    required this.end,
    required this.displayState,
    required this.priceVnd,
    required this.playerCount,
    this.capacity,
  });

  /// Slot UUID — passed to the booking flow.
  final String id;

  /// Slot bounds (UTC instants; convert to local for display / day grouping).
  final DateTime start;
  final DateTime end;

  /// Raw server state: empty | fixed | private | pending | confirmed | locked.
  final String displayState;

  /// Quoted price to book this slot, in VND.
  final int priceVnd;

  /// Currently joined players.
  final int playerCount;

  /// Max players for the slot, or null.
  final int? capacity;

  /// Only `empty` slots are bookable; any other/unknown state is greyed
  /// (so new server states default to not-tappable).
  bool get bookable => displayState == 'empty';

  factory VenueSlot.fromJson(Map<String, dynamic> json) => VenueSlot(
    id: json['id'] as String,
    start: DateTime.parse(json['start_at'] as String),
    end: DateTime.parse(json['end_at'] as String),
    displayState: json['display_state'] as String? ?? '',
    priceVnd: (json['total_price'] as num?)?.toInt() ?? 0,
    playerCount: (json['player_count'] as num?)?.toInt() ?? 0,
    capacity: (json['capacity'] as num?)?.toInt(),
  );
}

class CartItem {
  const CartItem({
    required this.sortKey,
    required this.courtName,
    required this.sport,
    required this.timeLabel,
    required this.price,
  });

  final String sortKey;
  final String courtName;
  final String sport;
  final String timeLabel;
  final int price;
}

class CartGroup {
  const CartGroup({required this.date, required this.items});

  final DateTime date;
  final List<CartItem> items;

  int get groupTotal => items.fold<int>(0, (s, e) => s + e.price);
}

@freezed
sealed class CourtScheduleOverviewState with _$CourtScheduleOverviewState {
  /// Initial / fetch in progress.
  const factory CourtScheduleOverviewState.loading() =
      CourtScheduleOverviewLoading;

  /// Schedule + selection ready to render.
  ///
  /// [selectedByDate] keys are ISO date strings (`YYYY-MM-DD`); values are the
  /// `'courtId|hour'` keys picked for that day. Persists across date-tab
  /// switches so the user can build a multi-day cart.
  ///
  /// [slotsByDate] is the availability grid per day, keyed the same way. Each
  /// inner map is `'courtId|hour' → ScheduleSlot`.
  const factory CourtScheduleOverviewState.loaded({
    required int selectedDateIndex,
    required Map<String, Set<String>> selectedByDate,
    required List<DateTime> dates,
    required List<int> hours,
    required List<ScheduleCourt> courts,
    required Map<String, Map<String, ScheduleSlot>> slotsByDate,
  }) = CourtScheduleOverviewLoaded;

  /// Unrecoverable load error.
  @With<AppExceptionMixin>()
  const factory CourtScheduleOverviewState.failure(
    String message, {
    StackTrace? stackTrace,
  }) = CourtScheduleOverviewFailure;
}
