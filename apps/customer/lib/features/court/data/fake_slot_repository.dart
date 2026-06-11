// EPIC-5 fake SlotRepository — prototype grid matrix, Sân A slot list and
// open-group slots, plus edge datasets (handoff doc 04 §3).

import '../domain/court.dart';
import '../domain/schedule.dart';
import '../domain/time_slot.dart';
import 'court_repository.dart';
import 'fake_court_repository.dart';

class FakeSlotRepository implements SlotRepository {
  FakeSlotRepository({this.dataset = FakeDataset.normal});

  final FakeDataset dataset;

  static const _delay = Duration(milliseconds: 450);

  static const _hourLabels = [
    '06:00', '08:00', '10:00', '14:00', '16:00', '18:00', '20:00',
  ];

  // Prototype matrix (status only; demo selection ignored). doc 04 §3.
  static const _matrix = <String, List<CellStatus>>{
    'court-a': [_o, _o, _b, _x, _o, _b, _o],
    'court-b': [_b, _o, _o, _o, _b, _o, _o],
    'court-c': [_x, _x, _o, _o, _o, _o, _b],
  };

  static const _o = CellStatus.open;
  static const _b = CellStatus.booked;
  static const _x = CellStatus.blocked;

  // Sân A slot list: (start, end, price, status). doc 04 §3.
  static const _slotRows = <_Row>[
    _Row('06:00', '07:30', 150000, CellStatus.open),
    _Row('07:30', '09:00', 150000, CellStatus.booked),
    _Row('09:00', '10:30', 180000, CellStatus.open),
    _Row('10:30', '12:00', 180000, CellStatus.open),
    _Row('14:00', '15:30', 200000, CellStatus.blocked),
    _Row('15:30', '17:00', 200000, CellStatus.open),
    _Row('17:00', '18:30', 250000, CellStatus.booked),
    _Row('18:30', '20:00', 250000, CellStatus.open),
    _Row('20:00', '21:30', 250000, CellStatus.open),
  ];

  @override
  Future<ScheduleDay> getCenterSchedule(String centerId, DateTime date) async {
    await Future.delayed(_delay);
    final allBooked = dataset == FakeDataset.noOpenSlots;
    final rows = _matrix.map((courtId, statuses) => MapEntry(
          courtId,
          allBooked
              ? List.filled(statuses.length, CellStatus.booked)
              : statuses,
        ));
    return ScheduleDay(date: date, hourLabels: _hourLabels, rows: rows);
  }

  @override
  Future<List<TimeSlot>> getSlots(String courtId, DateTime date) async {
    await Future.delayed(_delay);
    final allBooked = dataset == FakeDataset.noOpenSlots;
    return [
      for (var i = 0; i < _slotRows.length; i++)
        TimeSlot(
          id: '$courtId-slot-$i',
          courtId: courtId,
          start: _at(date, _slotRows[i].start),
          end: _at(date, _slotRows[i].end),
          priceVnd: _slotRows[i].price,
          status: allBooked ? CellStatus.booked : _slotRows[i].status,
        ),
    ];
  }

  @override
  Future<List<OpenGroupSlot>> getOpenGroupSlots(String courtId) async {
    await Future.delayed(_delay);
    if (dataset == FakeDataset.noGroupSlots) return const [];
    return const [
      OpenGroupSlot(
        id: 'g1',
        courtLabel: 'Sân A · Đôi nam',
        sport: Sport.pickleball,
        timeLabel: 'Hôm nay · 19:00 – 21:00',
        joined: 3,
        max: 4,
      ),
      OpenGroupSlot(
        id: 'g2',
        courtLabel: 'Sân B · Giao lưu',
        sport: Sport.pickleball,
        timeLabel: 'Mai · 08:00 – 10:00',
        joined: 1,
        max: 4,
      ),
      OpenGroupSlot(
        id: 'g3',
        courtLabel: 'Sân C · Đánh đơn',
        sport: Sport.tennis,
        timeLabel: 'Mai · 17:30 – 19:00',
        joined: 1,
        max: 2,
      ),
    ];
  }

  static DateTime _at(DateTime date, String hhmm) {
    final parts = hhmm.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}

class _Row {
  const _Row(this.start, this.end, this.price, this.status);
  final String start;
  final String end;
  final int price;
  final CellStatus status;
}
