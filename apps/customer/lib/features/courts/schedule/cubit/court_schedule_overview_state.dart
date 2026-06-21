import 'package:customer/core/mixins/app_exception_mixin.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'court_schedule_overview_state.freezed.dart';

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
  /// [dates] are the 7 local day tabs; [venues] holds every lane of the court
  /// with its slots for the whole week (grouped by day client-side via the
  /// view extension). [selectedSlotIds] are the real slot ids picked across all
  /// days, so the cart persists when switching the visible day.
  /// [submitting] is true while the batch booking call is in flight (CTA
  /// spinner). [bookingError] is a transient error *code* (resolved via the
  /// shared error mapper) surfaced as a snackbar after a failed booking;
  /// cleared when the user retries.
  const factory CourtScheduleOverviewState.loaded({
    required List<DateTime> dates,
    required int selectedDateIndex,
    required List<ScheduleVenue> venues,
    required Set<String> selectedSlotIds,
    @Default(false) bool submitting,
    String? bookingError,
  }) = CourtScheduleOverviewLoaded;

  /// Batch booking succeeded — carries the created booking ids. The screen
  /// navigates away on this state.
  const factory CourtScheduleOverviewState.booked({
    required List<String> bookingIds,
  }) = CourtScheduleOverviewBooked;

  /// Unrecoverable load error.
  @With<AppExceptionMixin>()
  const factory CourtScheduleOverviewState.failure(
    String message, {
    StackTrace? stackTrace,
  }) = CourtScheduleOverviewFailure;
}
