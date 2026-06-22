import 'package:customer/core/debug/app_logger.dart';
import 'package:customer/core/services/booking_api_client.dart';
import 'package:customer/features/courts/schedule/cubit/court_schedule_overview_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Week schedule for a court — its lanes (venues) × time slots. Fetches the
/// week from the REST API; users multi-select open slots into a cart and book
/// them atomically. Emits a failure state when no court/api is provided or the
/// load fails.
class CourtScheduleOverviewCubit extends Cubit<CourtScheduleOverviewState> {
  CourtScheduleOverviewCubit({String? courtId, BookingApiClient? apiClient})
    : _api = apiClient,
      super(const CourtScheduleOverviewState.loading()) {
    if (courtId != null && apiClient != null) {
      _loadFromApi(courtId);
    } else {
      emit(const CourtScheduleOverviewState.failure(_emptyMessage));
    }
  }

  static const _emptyMessage = 'schedule_empty';
  static const _errorMessage = 'schedule_load';

  final BookingApiClient? _api;

  Future<void> _loadFromApi(String courtId) async {
    try {
      // Fetch the current week (today + 6) in one call.
      final response = await _api!.getCourtSchedule(
        courtId,
        weekStart: DateTime.now(),
      );
      _parseAndEmit(response);
    } on ScheduleUnavailableException catch (e, st) {
      emit(CourtScheduleOverviewState.failure(_emptyMessage, stackTrace: st));
    } catch (e, st) {
      appLogger.e(
        'CourtScheduleOverviewCubit._loadFromApi failed',
        error: e,
        stackTrace: st,
      );
      emit(CourtScheduleOverviewState.failure(_errorMessage, stackTrace: st));
    }
  }

  void _parseAndEmit(Map<String, dynamic> response) {
    try {
      final venues = (response['venues'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(ScheduleVenue.fromJson)
          .toList();

      if (venues.every((v) => v.slots.isEmpty)) {
        emit(const CourtScheduleOverviewState.failure(_emptyMessage));
        return;
      }

      // The 7 day tabs start at `week_start` (single-day call echoes `date`),
      // falling back to today.
      final base = _baseDate(response['week_start'] ?? response['date']);
      final dates = List<DateTime>.generate(
        7,
        (i) => base.add(Duration(days: i)),
      );

      emit(
        CourtScheduleOverviewState.loaded(
          dates: dates,
          selectedDateIndex: 0,
          venues: venues,
          selectedSlotIds: const {},
        ),
      );
    } catch (e, st) {
      appLogger.e(
        'CourtScheduleOverviewCubit._parseAndEmit failed',
        error: e,
        stackTrace: st,
      );
      emit(CourtScheduleOverviewState.failure(_errorMessage, stackTrace: st));
    }
  }

  /// Local calendar day from a `YYYY-MM-DD` string, or today.
  static DateTime _baseDate(Object? raw) {
    if (raw is String) {
      final d = DateTime.parse(raw);
      return DateTime(d.year, d.month, d.day);
    }
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  void selectDate(int index) {
    final s = state;
    if (s is CourtScheduleOverviewLoaded) {
      // Switch the visible day without touching the multi-day selection.
      emit(s.copyWith(selectedDateIndex: index));
    }
  }

  /// Toggle a real slot id in/out of the cart.
  void toggleSlot(String slotId) {
    final s = state;
    if (s is! CourtScheduleOverviewLoaded) return;
    final next = Set<String>.from(s.selectedSlotIds);
    if (!next.add(slotId)) next.remove(slotId);
    emit(s.copyWith(selectedSlotIds: next));
  }

  void clearAll() {
    final s = state;
    if (s is CourtScheduleOverviewLoaded) {
      emit(s.copyWith(selectedSlotIds: const {}));
    }
  }

  /// Book every selected slot atomically via `POST /api/bookings/batch`.
  /// Emits [CourtScheduleOverviewBooked] on success, or re-emits the loaded
  /// state with a [bookingError] code on failure (slot taken / offline /
  /// server) for the screen to surface as a snackbar.
  Future<void> continueToBooking() async {
    final s = state;
    final api = _api;
    if (s is! CourtScheduleOverviewLoaded ||
        api == null ||
        s.submitting ||
        s.selectedSlotIds.isEmpty) {
      return;
    }

    emit(s.copyWith(submitting: true, bookingError: null));
    try {
      final result = await api.createBatchBooking(
        slotIds: s.selectedSlotIds.toList(),
      );
      emit(
        CourtScheduleOverviewState.booked(bookingIds: result.values.toList()),
      );
    } on SlotUnavailableException catch (e, st) {
      appLogger.e('continueToBooking: slot taken', error: e, stackTrace: st);
      emit(s.copyWith(submitting: false, bookingError: 'slot_taken'));
    } on NoConnectionException {
      emit(s.copyWith(submitting: false, bookingError: 'network'));
    } catch (e, st) {
      appLogger.e('continueToBooking failed', error: e, stackTrace: st);
      emit(s.copyWith(submitting: false, bookingError: 'booking_failed'));
    }
  }
}

String _hhmm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Pure helpers used by the screen — derives day-grouped view data from the
/// loaded state without leaking selection mutation back into the widget tree.
extension CourtScheduleOverviewLoadedView on CourtScheduleOverviewLoaded {
  DateTime get selectedDate => dates[selectedDateIndex];

  /// Grid for the visible day: `venueId → 'HH:mm' start → slot`. Slots' UTC
  /// `start` is converted to local (UTC+7) to bucket them into the day/column.
  Map<String, Map<String, VenueSlot>> get dayGrid {
    final out = <String, Map<String, VenueSlot>>{};
    for (final v in venues) {
      for (final s in v.slots) {
        final local = s.start.toLocal();
        if (_sameDay(local, selectedDate)) {
          (out[v.id] ??= <String, VenueSlot>{})[_hhmm(local)] = s;
        }
      }
    }
    return out;
  }

  /// Distinct, sorted start times ("HH:mm") present on the visible day — the
  /// grid's column headers.
  List<String> get times {
    final set = <String>{};
    for (final byTime in dayGrid.values) {
      set.addAll(byTime.keys);
    }
    final list = set.toList()..sort();
    return list;
  }

  /// slotId → (venue, slot), across the whole week — for cart/total lookups.
  Map<String, ({ScheduleVenue venue, VenueSlot slot})> get _slotsById {
    final out = <String, ({ScheduleVenue venue, VenueSlot slot})>{};
    for (final v in venues) {
      for (final s in v.slots) {
        out[s.id] = (venue: v, slot: s);
      }
    }
    return out;
  }

  int get totalSelectedCount => selectedSlotIds.length;

  int get grandTotal {
    final byId = _slotsById;
    return selectedSlotIds.fold<int>(
      0,
      (sum, id) => sum + (byId[id]?.slot.priceVnd ?? 0),
    );
  }

  /// Selected slots rolled up by local day, chronological — for the cart UI.
  List<CartGroup> buildCartGroups() {
    final byId = _slotsById;
    final byDay = <DateTime, List<CartItem>>{};
    for (final id in selectedSlotIds) {
      final entry = byId[id];
      if (entry == null) continue;
      final start = entry.slot.start.toLocal();
      final day = DateTime(start.year, start.month, start.day);
      (byDay[day] ??= <CartItem>[]).add(
        CartItem(
          sortKey: '${_hhmm(start)}|${entry.venue.name}',
          courtName: entry.venue.name,
          sport: entry.venue.sportType,
          timeLabel: '${_hhmm(start)} – ${_hhmm(entry.slot.end.toLocal())}',
          price: entry.slot.priceVnd,
        ),
      );
    }
    final days = byDay.keys.toList()..sort();
    return days.map((d) {
      final items = byDay[d]!..sort((a, b) => a.sortKey.compareTo(b.sortKey));
      return CartGroup(date: d, items: items);
    }).toList();
  }
}
