import 'dart:math';

import 'package:customer/features/courts/schedule/cubit/court_schedule_overview_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Multi-court venue schedule. Mock data today — will swap to a Supabase
/// repository once the slot grid endpoint lands.
class CourtScheduleOverviewCubit extends Cubit<CourtScheduleOverviewState> {
  CourtScheduleOverviewCubit({String? courtId})
      : _courtId = courtId,
        super(const CourtScheduleOverviewState.loading()) {
    _seed();
  }

  // ignore: unused_field
  final String? _courtId;

  void _seed() {
    final today = DateTime.now();
    final dates = List<DateTime>.generate(
      14,
      (i) => DateTime(today.year, today.month, today.day + i),
    );
    emit(CourtScheduleOverviewState.loaded(
      selectedDateIndex: 0,
      selectedByDate: const {},
      dates: dates,
      hours: _mockHours,
      courts: _mockCourts,
      slotsByDate: _generateSlotsByDate(dates),
    ));
  }

  static Map<String, Map<String, ScheduleSlot>> _generateSlotsByDate(
    List<DateTime> dates,
  ) {
    final out = <String, Map<String, ScheduleSlot>>{};
    for (final d in dates) {
      out[_dateKey(d)] = _generateMockSlots();
    }
    return out;
  }

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

  // ── Mock seed ──────────────────────────────────────────────────────────────
  static const List<int> _mockHours = [6, 8, 10, 14, 16, 18, 20];

  static const List<ScheduleCourt> _mockCourts = [
    ScheduleCourt(id: 'A', name: 'Sân A', sport: 'Pickleball'),
    ScheduleCourt(id: 'B', name: 'Sân B', sport: 'Pickleball'),
    ScheduleCourt(id: 'C', name: 'Sân C', sport: 'Tennis'),
    ScheduleCourt(id: 'D', name: 'Sân D', sport: 'Tennis'),
    ScheduleCourt(id: 'E', name: 'Sân E', sport: 'Badminton'),
    ScheduleCourt(id: 'F', name: 'Sân F', sport: 'Pickleball'),
  ];

  /// Roll a fresh availability map per cubit instance. Weighted so the screen
  /// always shows a mix of open / booked / closed across the grid:
  ///   • peak hours (16+) lean booked
  ///   • off-hours (≤6, ≥22) lean closed
  ///   • mid-day leans open
  /// Prices wiggle around a sport-specific base.
  static Map<String, ScheduleSlot> _generateMockSlots() {
    final rand = Random();
    final slots = <String, ScheduleSlot>{};
    for (final court in _mockCourts) {
      final basePrice = _basePriceFor(court.sport);
      for (final hour in _mockHours) {
        final status = _randomStatus(rand, hour);
        final wiggle = rand.nextInt(5) * 20000;
        final price = status == SlotStatus.closed ? 0 : basePrice + wiggle;
        final endLabel = status == SlotStatus.closed
            ? ''
            : '${(hour + 1).toString().padLeft(2, '0')}:30';
        slots['${court.id}|$hour'] = ScheduleSlot(
          status: status,
          price: price,
          endLabel: endLabel,
        );
      }
    }
    return slots;
  }

  static int _basePriceFor(String sport) => switch (sport) {
        'Badminton' => 120000,
        'Pickleball' => 200000,
        'Tennis' => 260000,
        _ => 200000,
      };

  static SlotStatus _randomStatus(Random rand, int hour) {
    final r = rand.nextDouble();
    if (hour <= 6 || hour >= 22) {
      if (r < 0.45) return SlotStatus.closed;
      if (r < 0.75) return SlotStatus.booked;
      return SlotStatus.open;
    }
    if (hour >= 16) {
      if (r < 0.05) return SlotStatus.closed;
      if (r < 0.60) return SlotStatus.booked;
      return SlotStatus.open;
    }
    if (r < 0.08) return SlotStatus.closed;
    if (r < 0.35) return SlotStatus.booked;
    return SlotStatus.open;
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
