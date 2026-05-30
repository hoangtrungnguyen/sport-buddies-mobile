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
