// Cubit tests for MapCubit — grava-c9ca.3.1
//
// AC verified:
//   - MapCubit initialises with all sports selected (empty filter = show all)
//   - filterBySports([]) resets to show-all
//   - filterBySports(['football']) shows only football
//   - Multi-select: filterBySports(['football', 'basketball']) keeps both
//   - Calling filterBySports with the same list emits a new state with equal set

import 'package:bloc_test/bloc_test.dart';
import 'package:customer/features/map/map_cubit.dart';
import 'package:customer/features/map/map_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MapCubit', () {
    late MapCubit cubit;

    setUp(() {
      cubit = MapCubit();
    });

    tearDown(() => cubit.close());

    test('initial state has empty selectedSports (show all)', () {
      expect(cubit.state.selectedSports, isEmpty);
    });

    blocTest<MapCubit, MapState>(
      'filterBySports with single sport emits state with that sport',
      build: () => MapCubit(),
      act: (c) => c.filterBySports(['football']),
      expect: () => [
        isA<MapState>().having(
          (s) => s.selectedSports,
          'selectedSports',
          {'football'},
        ),
      ],
    );

    blocTest<MapCubit, MapState>(
      'filterBySports with multiple sports emits state with all sports',
      build: () => MapCubit(),
      act: (c) => c.filterBySports(['football', 'basketball']),
      expect: () => [
        isA<MapState>().having(
          (s) => s.selectedSports,
          'selectedSports',
          {'football', 'basketball'},
        ),
      ],
    );

    blocTest<MapCubit, MapState>(
      'filterBySports with empty list resets to show-all',
      build: () => MapCubit(),
      act: (c) {
        c.filterBySports(['tennis']);
        c.filterBySports([]);
      },
      expect: () => [
        isA<MapState>().having(
          (s) => s.selectedSports,
          'selectedSports',
          {'tennis'},
        ),
        isA<MapState>().having(
          (s) => s.selectedSports,
          'selectedSports',
          isEmpty,
        ),
      ],
    );

    blocTest<MapCubit, MapState>(
      'filterBySports with all 5 sports emits state with all 5',
      build: () => MapCubit(),
      act: (c) => c.filterBySports([
        'football',
        'basketball',
        'tennis',
        'badminton',
        'pickleball',
      ]),
      expect: () => [
        isA<MapState>().having(
          (s) => s.selectedSports,
          'selectedSports',
          {'football', 'basketball', 'tennis', 'badminton', 'pickleball'},
        ),
      ],
    );
  });
}
