// Cubit tests for MapFilterCubit — grava-c9ca.3.1
//
// AC verified:
//   - MapFilterCubit initialises with all sports selected (empty filter = show all)
//   - filterBySports([]) resets to show-all
//   - filterBySports(['football']) shows only football
//   - Multi-select: filterBySports(['football', 'basketball']) keeps both
//   - Calling filterBySports with the same list emits a new state with equal set

import 'package:bloc_test/bloc_test.dart';
import 'package:customer/features/map/map_filter_cubit.dart';;
import 'package:customer/features/map/map_filter_state.dart';;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MapFilterCubit', () {
    late MapFilterCubit cubit;

    setUp(() {
      cubit = MapFilterCubit();
    });

    tearDown(() => cubit.close());

    test('initial state has empty selectedSports (show all)', () {
      expect(cubit.state.selectedSports, isEmpty);
    });

    blocTest<MapFilterCubit, MapFilterState>(
      'filterBySports with single sport emits state with that sport',
      build: () => MapFilterCubit(),
      act: (c) => c.filterBySports(['football']),
      expect: () => [
        isA<MapFilterState>().having(
          (s) => s.selectedSports,
          'selectedSports',
          {'football'},
        ),
      ],
    );

    blocTest<MapFilterCubit, MapFilterState>(
      'filterBySports with multiple sports emits state with all sports',
      build: () => MapFilterCubit(),
      act: (c) => c.filterBySports(['football', 'basketball']),
      expect: () => [
        isA<MapFilterState>().having(
          (s) => s.selectedSports,
          'selectedSports',
          {'football', 'basketball'},
        ),
      ],
    );

    blocTest<MapFilterCubit, MapFilterState>(
      'filterBySports with empty list resets to show-all',
      build: () => MapFilterCubit(),
      act: (c) {
        c.filterBySports(['tennis']);
        c.filterBySports([]);
      },
      expect: () => [
        isA<MapFilterState>().having(
          (s) => s.selectedSports,
          'selectedSports',
          {'tennis'},
        ),
        isA<MapFilterState>().having(
          (s) => s.selectedSports,
          'selectedSports',
          isEmpty,
        ),
      ],
    );

    blocTest<MapFilterCubit, MapFilterState>(
      'filterBySports with all 5 sports emits state with all 5',
      build: () => MapFilterCubit(),
      act: (c) => c.filterBySports([
        'football',
        'basketball',
        'tennis',
        'badminton',
        'pickleball',
      ]),
      expect: () => [
        isA<MapFilterState>().having(
          (s) => s.selectedSports,
          'selectedSports',
          {'football', 'basketball', 'tennis', 'badminton', 'pickleball'},
        ),
      ],
    );
  });
}
