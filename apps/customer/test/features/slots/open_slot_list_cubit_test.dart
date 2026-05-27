import 'package:bloc_test/bloc_test.dart';
import 'package:customer/features/slots/cubit/open_slot_list_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spb_core/spb_core.dart';

class MockOpenSlotRepository extends Mock implements OpenSlotRepository {}

// DateTime is not const — use final top-level vars instead.
final _start1 = DateTime.utc(2026, 6, 1, 19, 0);
final _end1   = DateTime.utc(2026, 6, 1, 20, 30);
final _start2 = DateTime.utc(2026, 6, 2, 7, 0);
final _end2   = DateTime.utc(2026, 6, 2, 8, 30);

OpenSlot get _slot1 => OpenSlot(
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

OpenSlot get _slot2 => OpenSlot(
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
  late MockOpenSlotRepository repo;

  setUp(() {
    repo = MockOpenSlotRepository();
  });

  group('loadAllGroupSlots', () {
    blocTest<OpenSlotListCubit, OpenSlotListState>(
      'emits [Loading, Loaded] on success',
      build: () {
        when(() => repo.fetchAllOpenGroupSlots())
            .thenAnswer((_) async => Success([_slot1, _slot2]));
        return OpenSlotListCubit(repo);
      },
      act: (cubit) => cubit.loadAllGroupSlots(),
      expect: () => [
        const OpenSlotListLoading(),
        OpenSlotListLoaded([_slot1, _slot2]),
      ],
    );

    blocTest<OpenSlotListCubit, OpenSlotListState>(
      'emits [Loading, Loaded([])] when no group slots exist',
      build: () {
        when(() => repo.fetchAllOpenGroupSlots())
            .thenAnswer((_) async => const Success([]));
        return OpenSlotListCubit(repo);
      },
      act: (cubit) => cubit.loadAllGroupSlots(),
      expect: () => [
        const OpenSlotListLoading(),
        const OpenSlotListLoaded([]),
      ],
    );

    blocTest<OpenSlotListCubit, OpenSlotListState>(
      'emits [Loading, Error] on NetworkFailure',
      build: () {
        when(() => repo.fetchAllOpenGroupSlots())
            .thenAnswer((_) async => const Failure(NetworkFailure()));
        return OpenSlotListCubit(repo);
      },
      act: (cubit) => cubit.loadAllGroupSlots(),
      expect: () => [
        const OpenSlotListLoading(),
        const OpenSlotListError('Không có kết nối mạng.'),
      ],
    );

    blocTest<OpenSlotListCubit, OpenSlotListState>(
      'emits [Loading, Error] on ServerFailure',
      build: () {
        when(() => repo.fetchAllOpenGroupSlots())
            .thenAnswer((_) async => const Failure(ServerFailure(500)));
        return OpenSlotListCubit(repo);
      },
      act: (cubit) => cubit.loadAllGroupSlots(),
      expect: () => [
        const OpenSlotListLoading(),
        const OpenSlotListError('Lỗi máy chủ (500).'),
      ],
    );
  });

  group('loadForCourt', () {
    blocTest<OpenSlotListCubit, OpenSlotListState>(
      'emits [Loading, Loaded] on success',
      build: () {
        when(() => repo.fetchOpenSlots('court-1'))
            .thenAnswer((_) async => Success([_slot1]));
        return OpenSlotListCubit(repo);
      },
      act: (cubit) => cubit.loadForCourt('court-1'),
      expect: () => [
        const OpenSlotListLoading(),
        OpenSlotListLoaded([_slot1]),
      ],
    );

    blocTest<OpenSlotListCubit, OpenSlotListState>(
      'emits [Loading, Error] on failure',
      build: () {
        when(() => repo.fetchOpenSlots('court-x'))
            .thenAnswer((_) async => const Failure(NetworkFailure()));
        return OpenSlotListCubit(repo);
      },
      act: (cubit) => cubit.loadForCourt('court-x'),
      expect: () => [
        const OpenSlotListLoading(),
        const OpenSlotListError('Không có kết nối mạng.'),
      ],
    );
  });

  group('clear', () {
    blocTest<OpenSlotListCubit, OpenSlotListState>(
      'returns to Initial from Loaded',
      build: () {
        when(() => repo.fetchAllOpenGroupSlots())
            .thenAnswer((_) async => Success([_slot1]));
        return OpenSlotListCubit(repo);
      },
      act: (cubit) async {
        await cubit.loadAllGroupSlots();
        cubit.clear();
      },
      expect: () => [
        const OpenSlotListLoading(),
        OpenSlotListLoaded([_slot1]),
        const OpenSlotListInitial(),
      ],
    );
  });

  group('OpenSlotListLoaded equality', () {
    test('same slots → equal', () {
      expect(
        OpenSlotListLoaded([_slot1]),
        equals(OpenSlotListLoaded([_slot1])),
      );
    });

    test('different slots → not equal', () {
      expect(
        OpenSlotListLoaded([_slot1]),
        isNot(equals(OpenSlotListLoaded([_slot2]))),
      );
    });
  });
}
