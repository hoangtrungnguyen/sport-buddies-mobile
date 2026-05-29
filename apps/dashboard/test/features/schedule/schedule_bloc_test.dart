import 'package:dashboard/features/schedule/bloc/schedule_bloc.dart';
import 'package:dashboard/features/schedule/model/manual_booking_result.dart';
import 'package:dashboard/features/schedule/model/owner_slot.dart';
import 'package:dashboard/features/schedule/repository/manual_booking_repository.dart';
import 'package:dashboard/features/schedule/repository/owner_slot_repository.dart';
import 'package:dashboard/features/setup/model/owner_court.dart';
import 'package:flutter_test/flutter_test.dart';

OwnerCourt _court(String id, String name) => OwnerCourt(
      id: id,
      name: name,
      sportTypes: const ['Tennis'],
      capacity: 4,
      openHour: 6,
      closeHour: 22,
      pricePerHour: 100000,
      isActive: true,
    );

/// In-memory [OwnerSlotRepository]. Records calls and grows its slot list on
/// create so the bloc's post-create reload reflects the write.
class _FakeSlotRepo implements OwnerSlotRepository {
  _FakeSlotRepo({List<OwnerSlot> initial = const []}) : _slots = [...initial];

  List<OwnerSlot> _slots;
  int fetchCalls = 0;
  String? lastCourtId;
  DateTime? lastWeekStart;
  final List<OwnerSlot> created = [];

  @override
  Future<List<OwnerSlot>> fetchWeekSlots({
    required String courtId,
    required DateTime weekStart,
  }) async {
    fetchCalls++;
    lastCourtId = courtId;
    lastWeekStart = weekStart;
    return List.of(_slots);
  }

  @override
  Future<OwnerSlot> createOwnerSlot({
    required String courtId,
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    final slot = OwnerSlot(
      id: 'new-${created.length}',
      courtId: courtId,
      startAt: startAt,
      endAt: endAt,
      status: SlotStatus.owner,
    );
    created.add(slot);
    _slots = [..._slots, slot];
    return slot;
  }

  /// Simulates the server creating a confirmed (`booked`) slot — the manual
  /// booking endpoint does this, and the bloc's reload then surfaces it.
  void addBooked({
    required String courtId,
    required DateTime startAt,
    required DateTime endAt,
  }) {
    _slots = [
      ..._slots,
      OwnerSlot(
        id: 'booked-${_slots.length}',
        courtId: courtId,
        startAt: startAt,
        endAt: endAt,
        status: SlotStatus.booked,
      ),
    ];
  }
}

/// In-memory [ManualBookingRepository]. Records each call; when [throwCode] is
/// set it raises a [ManualBookingException] (simulating a server rejection),
/// otherwise it appends a `booked` slot to [slotRepo] so the reload reflects it.
class _FakeBookingRepo implements ManualBookingRepository {
  _FakeBookingRepo({this.slotRepo, this.throwCode});

  final _FakeSlotRepo? slotRepo;
  final String? throwCode;
  final List<Map<String, dynamic>> calls = [];

  @override
  Future<void> createManualBooking({
    required String courtId,
    required DateTime startAt,
    required DateTime endAt,
    String? customerName,
    String? customerPhone,
    String? notes,
    int? pricePerHourOverride,
  }) async {
    calls.add(<String, dynamic>{
      'courtId': courtId,
      'startAt': startAt,
      'endAt': endAt,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'notes': notes,
      'pricePerHourOverride': pricePerHourOverride,
    });
    if (throwCode != null) throw ManualBookingException(throwCode!);
    slotRepo?.addBooked(courtId: courtId, startAt: startAt, endAt: endAt);
  }
}

// 2026-05-13 is a Wednesday → its Monday is 2026-05-11 (design week).
DateTime _fixedNow() => DateTime(2026, 5, 13, 9);
final _monday = DateTime(2026, 5, 11);

void main() {
  group('ScheduleBloc', () {
    test('started loads courts + this-week slots for the first court',
        () async {
      final repo = _FakeSlotRepo(initial: [
        OwnerSlot(
          id: 's1',
          courtId: 'c1',
          startAt: DateTime(2026, 5, 14, 8),
          endAt: DateTime(2026, 5, 14, 10),
          status: SlotStatus.owner,
        ),
      ]);
      final bloc = ScheduleBloc(
        slotRepository: repo,
        bookingRepository: _FakeBookingRepo(),
        loadCourts: () async => [_court('c1', 'Sân 1'), _court('c2', 'Sân 2')],
        now: _fixedNow,
      );

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([isA<ScheduleLoading>(), isA<ScheduleLoaded>()]),
      );
      bloc.add(const ScheduleEvent.started());
      await expectation;

      final s = bloc.state as ScheduleLoaded;
      expect(s.courts, hasLength(2));
      expect(s.activeCourtId, 'c1');
      expect(s.weekStart, _monday);
      expect(s.slots, hasLength(1));
      expect(repo.lastCourtId, 'c1');
      expect(repo.lastWeekStart, _monday);
      await bloc.close();
    });

    test('no courts yields an empty loaded view (no slot fetch)', () async {
      final repo = _FakeSlotRepo();
      final bloc = ScheduleBloc(
        slotRepository: repo,
        bookingRepository: _FakeBookingRepo(),
        loadCourts: () async => <OwnerCourt>[],
        now: _fixedNow,
      );

      bloc.add(const ScheduleEvent.started());
      await expectLater(
        bloc.stream,
        emitsInOrder([isA<ScheduleLoading>(), isA<ScheduleLoaded>()]),
      );

      final s = bloc.state as ScheduleLoaded;
      expect(s.courts, isEmpty);
      expect(s.activeCourtId, '');
      expect(repo.fetchCalls, 0);
      await bloc.close();
    });

    test('courtSelected switches the active court and refetches', () async {
      final repo = _FakeSlotRepo();
      final bloc = ScheduleBloc(
        slotRepository: repo,
        bookingRepository: _FakeBookingRepo(),
        loadCourts: () async => [_court('c1', 'Sân 1'), _court('c2', 'Sân 2')],
        now: _fixedNow,
      );

      bloc.add(const ScheduleEvent.started());
      await expectLater(bloc.stream, emitsThrough(isA<ScheduleLoaded>()));

      bloc.add(const ScheduleEvent.courtSelected('c2'));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<ScheduleLoaded>().having((s) => s.activeCourtId, 'court', 'c2'),
        ),
      );
      expect(repo.lastCourtId, 'c2');
      await bloc.close();
    });

    test('ownerSlotCreated persists status=owner then reloads', () async {
      final repo = _FakeSlotRepo();
      final bloc = ScheduleBloc(
        slotRepository: repo,
        bookingRepository: _FakeBookingRepo(),
        loadCourts: () async => [_court('c1', 'Sân 1')],
        now: _fixedNow,
      );

      bloc.add(const ScheduleEvent.started());
      await expectLater(bloc.stream, emitsThrough(isA<ScheduleLoaded>()));

      bloc.add(ScheduleEvent.ownerSlotCreated(
        startAt: DateTime(2026, 5, 14, 18),
        endAt: DateTime(2026, 5, 14, 19, 30),
      ));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<ScheduleLoaded>()
              .having((s) => s.slots.length, 'slots', 1)
              .having((s) => s.busy, 'busy', false),
        ),
      );

      expect(repo.created, hasLength(1));
      expect(repo.created.single.isOwnerSlot, isTrue);
      expect(repo.created.single.courtId, 'c1');
      await bloc.close();
    });

    test('ownerSlotCreated is a no-op when it conflicts', () async {
      final repo = _FakeSlotRepo(initial: [
        OwnerSlot(
          id: 's1',
          courtId: 'c1',
          startAt: DateTime(2026, 5, 14, 18),
          endAt: DateTime(2026, 5, 14, 20),
          status: SlotStatus.booked,
        ),
      ]);
      final bloc = ScheduleBloc(
        slotRepository: repo,
        bookingRepository: _FakeBookingRepo(),
        loadCourts: () async => [_court('c1', 'Sân 1')],
        now: _fixedNow,
      );

      bloc.add(const ScheduleEvent.started());
      await expectLater(bloc.stream, emitsThrough(isA<ScheduleLoaded>()));

      // Overlaps the existing 18:00–20:00 booking.
      bloc.add(ScheduleEvent.ownerSlotCreated(
        startAt: DateTime(2026, 5, 14, 19),
        endAt: DateTime(2026, 5, 14, 20),
      ));
      // Give the (ignored) event a chance to run.
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repo.created, isEmpty);
      await bloc.close();
    });

    test('a load failure surfaces ScheduleFailure', () async {
      final bloc = ScheduleBloc(
        slotRepository: _FakeSlotRepo(),
        bookingRepository: _FakeBookingRepo(),
        loadCourts: () async => throw Exception('boom'),
        now: _fixedNow,
      );

      bloc.add(const ScheduleEvent.started());
      await expectLater(
        bloc.stream,
        emitsInOrder([isA<ScheduleLoading>(), isA<ScheduleFailure>()]),
      );
      await bloc.close();
    });

    test('manualBookingCreated books the active court then reloads', () async {
      final repo = _FakeSlotRepo();
      final booking = _FakeBookingRepo(slotRepo: repo);
      final bloc = ScheduleBloc(
        slotRepository: repo,
        bookingRepository: booking,
        loadCourts: () async => [_court('c1', 'Sân 1')],
        now: _fixedNow,
      );

      bloc.add(const ScheduleEvent.started());
      await expectLater(bloc.stream, emitsThrough(isA<ScheduleLoaded>()));

      bloc.add(ScheduleEvent.manualBookingCreated(
        startAt: DateTime(2026, 5, 14, 18),
        endAt: DateTime(2026, 5, 14, 19, 30),
        customerName: 'Minh',
        customerPhone: '+84901234567',
        notes: 'walk-in',
      ));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<ScheduleLoaded>()
              .having((s) => s.slots.length, 'slots', 1)
              .having((s) => s.slots.first.status, 'status', SlotStatus.booked)
              .having((s) => s.busy, 'busy', false)
              .having((s) => s.bookingResult, 'result',
                  isA<ManualBookingSucceeded>()),
        ),
      );

      final result = (bloc.state as ScheduleLoaded).bookingResult
          as ManualBookingSucceeded;
      expect(result.startAt, DateTime(2026, 5, 14, 18));
      expect(result.endAt, DateTime(2026, 5, 14, 19, 30));
      expect(result.customerName, 'Minh');
      expect(booking.calls, hasLength(1));
      expect(booking.calls.single['courtId'], 'c1');
      expect(booking.calls.single['customerName'], 'Minh');
      expect(booking.calls.single['customerPhone'], '+84901234567');
      await bloc.close();
    });

    test('bookingResultCleared wipes the transient booking result', () async {
      final repo = _FakeSlotRepo();
      final booking = _FakeBookingRepo(slotRepo: repo);
      final bloc = ScheduleBloc(
        slotRepository: repo,
        bookingRepository: booking,
        loadCourts: () async => [_court('c1', 'Sân 1')],
        now: _fixedNow,
      );

      bloc.add(const ScheduleEvent.started());
      await expectLater(bloc.stream, emitsThrough(isA<ScheduleLoaded>()));

      bloc.add(ScheduleEvent.manualBookingCreated(
        startAt: DateTime(2026, 5, 14, 18),
        endAt: DateTime(2026, 5, 14, 19, 30),
      ));
      await expectLater(
        bloc.stream,
        emitsThrough(isA<ScheduleLoaded>().having(
            (s) => s.bookingResult, 'result', isA<ManualBookingSucceeded>())),
      );

      bloc.add(const ScheduleEvent.bookingResultCleared());
      await expectLater(
        bloc.stream,
        emitsThrough(isA<ScheduleLoaded>()
            .having((s) => s.bookingResult, 'result', isNull)),
      );
      await bloc.close();
    });

    test('manualBookingCreated is a no-op when it conflicts client-side',
        () async {
      final repo = _FakeSlotRepo(initial: [
        OwnerSlot(
          id: 's1',
          courtId: 'c1',
          startAt: DateTime(2026, 5, 14, 18),
          endAt: DateTime(2026, 5, 14, 20),
          status: SlotStatus.booked,
        ),
      ]);
      final booking = _FakeBookingRepo(slotRepo: repo);
      final bloc = ScheduleBloc(
        slotRepository: repo,
        bookingRepository: booking,
        loadCourts: () async => [_court('c1', 'Sân 1')],
        now: _fixedNow,
      );

      bloc.add(const ScheduleEvent.started());
      await expectLater(bloc.stream, emitsThrough(isA<ScheduleLoaded>()));

      bloc.add(ScheduleEvent.manualBookingCreated(
        startAt: DateTime(2026, 5, 14, 19),
        endAt: DateTime(2026, 5, 14, 20),
      ));
      await expectLater(
        bloc.stream,
        emitsThrough(isA<ScheduleLoaded>().having(
            (s) => s.bookingResult, 'result', isA<ManualBookingFailed>())),
      );

      // No server call was made — the client guard short-circuited it.
      expect(booking.calls, isEmpty);
      await bloc.close();
    });

    test(
        'manualBookingCreated maps every server error code to a localized '
        'failure message', () async {
      const cases = <String, String>{
        'overlap': 'đã có người đặt',
        'invalid_input': 'chưa hợp lệ',
        'not_owner': 'không có quyền',
        'court_not_found': 'Không tìm thấy sân',
        'unauthorized': 'hết hạn',
        'service_unavailable': 'Không kết nối',
        'network': 'Không kết nối',
        'unknown': 'Không thể tạo booking',
      };
      for (final entry in cases.entries) {
        final repo = _FakeSlotRepo();
        final booking = _FakeBookingRepo(slotRepo: repo, throwCode: entry.key);
        final bloc = ScheduleBloc(
          slotRepository: repo,
          bookingRepository: booking,
          loadCourts: () async => [_court('c1', 'Sân 1')],
          now: _fixedNow,
        );
        bloc.add(const ScheduleEvent.started());
        await expectLater(bloc.stream, emitsThrough(isA<ScheduleLoaded>()));

        bloc.add(ScheduleEvent.manualBookingCreated(
          startAt: DateTime(2026, 5, 14, 18),
          endAt: DateTime(2026, 5, 14, 19, 30),
        ));
        await expectLater(
          bloc.stream,
          emitsThrough(isA<ScheduleLoaded>().having(
              (s) => s.bookingResult, 'result', isA<ManualBookingFailed>())),
        );
        final msg = ((bloc.state as ScheduleLoaded).bookingResult
                as ManualBookingFailed)
            .message;
        expect(msg, contains(entry.value), reason: 'code "${entry.key}"');
        await bloc.close();
      }
    });

    test(
        'manualBookingCreated keeps the schedule loaded with a failure result on '
        'a server rejection', () async {
      final repo = _FakeSlotRepo();
      final booking = _FakeBookingRepo(slotRepo: repo, throwCode: 'overlap');
      final bloc = ScheduleBloc(
        slotRepository: repo,
        bookingRepository: booking,
        loadCourts: () async => [_court('c1', 'Sân 1')],
        now: _fixedNow,
      );

      bloc.add(const ScheduleEvent.started());
      await expectLater(bloc.stream, emitsThrough(isA<ScheduleLoaded>()));

      bloc.add(ScheduleEvent.manualBookingCreated(
        startAt: DateTime(2026, 5, 14, 18),
        endAt: DateTime(2026, 5, 14, 19, 30),
      ));
      await expectLater(
        bloc.stream,
        emitsThrough(isA<ScheduleLoaded>()
            .having((s) => s.busy, 'busy', false)
            .having(
                (s) => s.bookingResult, 'result', isA<ManualBookingFailed>())),
      );

      // A predictable rejection must NOT nuke the view to ScheduleFailure —
      // the owner stays in the still-open dialog to fix + retry.
      final state = bloc.state as ScheduleLoaded;
      expect((state.bookingResult as ManualBookingFailed).message,
          contains('đã có người đặt'));
      expect(booking.calls, hasLength(1));
      await bloc.close();
    });
  });
}
