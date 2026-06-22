import 'package:bloc_test/bloc_test.dart';
import 'package:customer/features/slots/cubit/open_slot_list_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spb_core/spb_core.dart';

class MockSlotRepository extends Mock implements SlotRepository {}

// DateTime is not const — use final top-level vars instead.
final _start1 = DateTime.utc(2026, 6, 1, 19, 0);
final _end1   = DateTime.utc(2026, 6, 1, 20, 30);
final _start2 = DateTime.utc(2026, 6, 2, 7, 0);
final _end2   = DateTime.utc(2026, 6, 2, 8, 30);

Slot get _slot1 => Slot(
  id: 'slot-1',
  startTime: _start1,
  endTime: _end1,
  courtId: 'court-1',
  courtName: 'Pickle Hub Q1',
  sportType: 'pickleball',
  accessPolicy: 'open',
  maxPlayers: 6,
  currentPlayers: 3,
);

Slot get _slot2 => Slot(
  id: 'slot-2',
  startTime: _start2,
  endTime: _end2,
  courtId: 'court-2',
  courtName: 'Badminton Pro',
  sportType: 'badminton',
  accessPolicy: 'open',
  maxPlayers: 4,
  currentPlayers: 4,
);

void main() {
  late MockSlotRepository repo;

  setUp(() {
    repo = MockSlotRepository();
  });

  group('loadAllGroupSlots', () {
    blocTest<SlotListCubit, SlotListState>(
      'emits [Loading, Loaded] on success',
      build: () {
        when(() => repo.fetchAllGroupSlots())
            .thenAnswer((_) async => Success([_slot1, _slot2]));
        return SlotListCubit(repo);
      },
      act: (cubit) => cubit.loadAllGroupSlots(),
      expect: () => [
        const SlotListLoading(),
        SlotListLoaded([_slot1, _slot2]),
      ],
    );

    blocTest<SlotListCubit, SlotListState>(
      'emits [Loading, Loaded([])] when no group slots exist',
      build: () {
        when(() => repo.fetchAllGroupSlots())
            .thenAnswer((_) async => const Success([]));
        return SlotListCubit(repo);
      },
      act: (cubit) => cubit.loadAllGroupSlots(),
      expect: () => [
        const SlotListLoading(),
        const SlotListLoaded([]),
      ],
    );

    blocTest<SlotListCubit, SlotListState>(
      'emits [Loading, Error] on NetworkFailure',
      build: () {
        when(() => repo.fetchAllGroupSlots())
            .thenAnswer((_) async => const Failure(NetworkFailure()));
        return SlotListCubit(repo);
      },
      act: (cubit) => cubit.loadAllGroupSlots(),
      expect: () => [
        const SlotListLoading(),
        const SlotListError('network'),
      ],
    );

    blocTest<SlotListCubit, SlotListState>(
      'emits [Loading, Error] on ServerFailure',
      build: () {
        when(() => repo.fetchAllGroupSlots())
            .thenAnswer((_) async => const Failure(ServerFailure(500)));
        return SlotListCubit(repo);
      },
      act: (cubit) => cubit.loadAllGroupSlots(),
      expect: () => [
        const SlotListLoading(),
        const SlotListError('server'),
      ],
    );
  });

  group('loadForCourt', () {
    blocTest<SlotListCubit, SlotListState>(
      'emits [Loading, Loaded] on success',
      build: () {
        when(() => repo.fetchSlots('court-1'))
            .thenAnswer((_) async => Success([_slot1]));
        return SlotListCubit(repo);
      },
      act: (cubit) => cubit.loadForCourt('court-1'),
      expect: () => [
        const SlotListLoading(),
        SlotListLoaded([_slot1]),
      ],
    );

    blocTest<SlotListCubit, SlotListState>(
      'emits [Loading, Error] on failure',
      build: () {
        when(() => repo.fetchSlots('court-x'))
            .thenAnswer((_) async => const Failure(NetworkFailure()));
        return SlotListCubit(repo);
      },
      act: (cubit) => cubit.loadForCourt('court-x'),
      expect: () => [
        const SlotListLoading(),
        const SlotListError('network'),
      ],
    );
  });

  group('clear', () {
    blocTest<SlotListCubit, SlotListState>(
      'returns to Initial from Loaded',
      build: () {
        when(() => repo.fetchAllGroupSlots())
            .thenAnswer((_) async => Success([_slot1]));
        return SlotListCubit(repo);
      },
      act: (cubit) async {
        await cubit.loadAllGroupSlots();
        cubit.clear();
      },
      expect: () => [
        const SlotListLoading(),
        SlotListLoaded([_slot1]),
        const SlotListInitial(),
      ],
    );
  });

  group('SlotListLoaded equality', () {
    test('same slots → equal', () {
      expect(
        SlotListLoaded([_slot1]),
        equals(SlotListLoaded([_slot1])),
      );
    });

    test('different slots → not equal', () {
      expect(
        SlotListLoaded([_slot1]),
        isNot(equals(SlotListLoaded([_slot2]))),
      );
    });
  });
}
