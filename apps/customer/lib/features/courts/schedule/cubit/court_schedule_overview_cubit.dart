import 'package:customer/core/debug/app_logger.dart';
import 'package:customer/core/services/booking_api_client.dart';
import 'package:customer/features/courts/schedule/cubit/court_schedule_overview_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Multi-court venue schedule. Fetches from the REST API for the given sports
/// center; emits a failure state when no center is provided or the load fails.
class CourtScheduleOverviewCubit extends Cubit<CourtScheduleOverviewState> {
  CourtScheduleOverviewCubit({
    String? sportsCenterId,
    BookingApiClient? apiClient,
  })  : _api = apiClient,
        super(const CourtScheduleOverviewState.loading()) {
    if (sportsCenterId != null && apiClient != null) {
      _loadFromApi(sportsCenterId);
    } else {
      emit(const CourtScheduleOverviewState.failure(_emptyMessage));
    }
  }

  static const _emptyMessage = 'Không có lịch sân cho địa điểm này.';
  static const _errorMessage = 'Không tải được lịch sân. Vui lòng thử lại.';

  final BookingApiClient? _api;

  Future<void> _loadFromApi(String scId) async {
    try {
      final response = await _api!.getSportsCenterSchedule(scId);
      _parseAndEmit(response);
    } catch (e, st) {
      appLogger.e('CourtScheduleOverviewCubit._loadFromApi failed',
          error: e, stackTrace: st);
      emit(CourtScheduleOverviewState.failure(_errorMessage, stackTrace: st));
    }
  }

  void _parseAndEmit(Map<String, dynamic> response) {
    try {
      // Parse dates from response
      final datesList = response['dates'] as List<dynamic>? ?? [];
      final dates = datesList
          .map((d) => DateTime.parse(d as String))
          .toList();

      if (dates.isEmpty) {
        emit(const CourtScheduleOverviewState.failure(_emptyMessage));
        return;
      }

      // Parse courts from response
      final courtsList = response['courts'] as List<dynamic>? ?? [];
      final courts = courtsList
          .map((c) => c is Map<String, dynamic>
              ? ScheduleCourt(
                  id: c['id'] as String? ?? '',
                  name: c['name'] as String? ?? 'Unknown',
                  sport: c['sport'] as String? ?? 'Unknown',
                )
              : null)
          .whereType<ScheduleCourt>()
          .toList();

      // Parse slots by date
      final slotsData = response['slots'] as Map<String, dynamic>? ?? {};
      final slotsByDate = <String, Map<String, ScheduleSlot>>{};

      slotsData.forEach((dateKey, daySlots) {
        if (daySlots is Map<String, dynamic>) {
          final slotMap = <String, ScheduleSlot>{};
          daySlots.forEach((slotKey, slotData) {
            if (slotData is Map<String, dynamic>) {
              final status = _parseSlotStatus(slotData['status'] as String?);
              slotMap[slotKey] = ScheduleSlot(
                status: status,
                price: slotData['price'] as int? ?? 0,
                endLabel: slotData['endLabel'] as String? ?? '',
              );
            }
          });
          slotsByDate[dateKey] = slotMap;
        }
      });

      // Extract hours from slots (assume all dates have same hours)
      final hours = <int>{};
      slotsByDate.forEach((_, daySlots) {
        daySlots.forEach((key, __) {
          final parts = key.split('|');
          if (parts.length == 2) {
            final hour = int.tryParse(parts[1]);
            if (hour != null) hours.add(hour);
          }
        });
      });
      final sortedHours = hours.toList()..sort();

      emit(CourtScheduleOverviewState.loaded(
        selectedDateIndex: 0,
        selectedByDate: const {},
        dates: dates,
        hours: sortedHours,
        courts: courts,
        slotsByDate: slotsByDate,
      ));
    } catch (e, st) {
      appLogger.e('CourtScheduleOverviewCubit._parseAndEmit failed',
          error: e, stackTrace: st);
      emit(CourtScheduleOverviewState.failure(_errorMessage, stackTrace: st));
    }
  }

  static SlotStatus _parseSlotStatus(String? status) => switch (status) {
        'open' => SlotStatus.open,
        'booked' => SlotStatus.booked,
        'closed' => SlotStatus.closed,
        _ => SlotStatus.closed,
      };

  void selectDate(int index) {
    final s = state;
    if (s is CourtScheduleOverviewLoaded) {
      // Switch the visible day without touching selections from other days.
      emit(s.copyWith(selectedDateIndex: index));
    }
  }

  void toggleSlot(String hourKey) {
    final s = state;
    if (s is! CourtScheduleOverviewLoaded) return;
    final dateKey = _dateKey(s.dates[s.selectedDateIndex]);
    final next = Map<String, Set<String>>.from(s.selectedByDate);
    final daySet = Set<String>.from(next[dateKey] ?? const <String>{});
    if (!daySet.add(hourKey)) daySet.remove(hourKey);
    if (daySet.isEmpty) {
      next.remove(dateKey);
    } else {
      next[dateKey] = daySet;
    }
    emit(s.copyWith(selectedByDate: next));
  }

  void clearAll() {
    final s = state;
    if (s is CourtScheduleOverviewLoaded) {
      emit(s.copyWith(selectedByDate: const {}));
    }
  }

  static String _dateKey(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$dd';
  }
}

/// Pure helpers used by the screen — builds derived view data from the loaded
/// state without leaking selection mutation back into the widget tree.
extension CourtScheduleOverviewLoadedView on CourtScheduleOverviewLoaded {
  /// 'courtId|hour' keys picked for the currently visible date — used by the
  /// grid to render selected cells.
  Set<String> get currentDateSelection {
    final dateKey = _dateKeyOf(dates[selectedDateIndex]);
    return selectedByDate[dateKey] ?? const <String>{};
  }

  /// Availability map for the currently visible date — used by the grid to
  /// render each cell's status.
  Map<String, ScheduleSlot> get currentSlots {
    final dateKey = _dateKeyOf(dates[selectedDateIndex]);
    return slotsByDate[dateKey] ?? const {};
  }

  int get totalSelectedCount =>
      selectedByDate.values.fold<int>(0, (sum, set) => sum + set.length);

  int get grandTotal {
    var sum = 0;
    selectedByDate.forEach((dateKey, hourKeys) {
      final daySlots = slotsByDate[dateKey] ?? const <String, ScheduleSlot>{};
      for (final key in hourKeys) {
        sum += daySlots[key]?.price ?? 0;
      }
    });
    return sum;
  }

  /// Selections rolled up by date, chronological. Each group is a date header
  /// plus its sorted line-items for the cart UI.
  List<CartGroup> buildCartGroups() {
    final dateKeys = selectedByDate.keys.toList()..sort();
    return dateKeys.map((dateKey) {
      final date = DateTime.parse(dateKey);
      final daySlots = slotsByDate[dateKey] ?? const <String, ScheduleSlot>{};
      final items = (selectedByDate[dateKey] ?? const <String>{})
          .map((hourKey) {
            final parts = hourKey.split('|');
            final courtId = parts[0];
            final hour = int.parse(parts[1]);
            final court = courts.firstWhere((c) => c.id == courtId);
            final slot = daySlots[hourKey]!;
            return CartItem(
              sortKey: '${court.id}|${hour.toString().padLeft(2, '0')}',
              courtName: court.name,
              sport: court.sport,
              timeLabel:
                  '${hour.toString().padLeft(2, '0')}:00 – ${slot.endLabel}',
              price: slot.price,
            );
          })
          .toList()
        ..sort((a, b) => a.sortKey.compareTo(b.sortKey));
      return CartGroup(date: date, items: items);
    }).toList();
  }

  static String _dateKeyOf(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$dd';
  }
}
