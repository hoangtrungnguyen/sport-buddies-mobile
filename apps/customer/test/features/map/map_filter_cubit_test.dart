// MapFilterCubit tests — grava-c9ca.4.2
//
// Tests the map filter cubit including sport and distance filtering.

import 'package:flutter_test/flutter_test.dart';
import 'package:customer/features/map/map_filter_cubit.dart';
import 'package:customer/features/map/map_filter_state.dart';

void main() {
  group('MapFilterCubit', () {
    test('initial state has empty filters', () {
      final cubit = MapFilterCubit();
      expect(cubit.state.selectedSports, isEmpty);
      expect(cubit.state.maxDistanceKm, isNull);
    });

    test('filterBySports updates selected sports', () {
      final cubit = MapFilterCubit();
      cubit.filterBySports(['football', 'basketball']);

      expect(cubit.state.selectedSports, {'football', 'basketball'});
    });

    test('filterBySports with empty list resets filter', () {
      final cubit = MapFilterCubit();
      cubit.filterBySports(['football']);
      expect(cubit.state.selectedSports, {'football'});

      cubit.filterBySports([]);
      expect(cubit.state.selectedSports, isEmpty);
    });

    test('filterByDistance updates max distance', () {
      final cubit = MapFilterCubit();
      cubit.filterByDistance(5.0);

      expect(cubit.state.maxDistanceKm, 5.0);
    });

    test('filterByDistance with null clears distance filter', () {
      final cubit = MapFilterCubit();
      cubit.filterByDistance(5.0);
      expect(cubit.state.maxDistanceKm, 5.0);

      cubit.filterByDistance(null);
      expect(cubit.state.maxDistanceKm, isNull);
    });

    test('filterByDistance rounds to 1 decimal place', () {
      final cubit = MapFilterCubit();
      cubit.filterByDistance(5.456);

      expect(cubit.state.maxDistanceKm, 5.5);
    });

    test('clearAll resets both filters', () {
      final cubit = MapFilterCubit();
      cubit.filterBySports(['football']);
      cubit.filterByDistance(5.0);

      cubit.clearAll();

      expect(cubit.state.selectedSports, isEmpty);
      expect(cubit.state.maxDistanceKm, isNull);
    });
  });

  group('MapFilterState', () {
    test('copyWith creates new instance with updated values', () {
      const state = MapFilterState(
        selectedSports: {'football'},
        maxDistanceKm: 5.0,
      );

      final updated = state.copyWith(
        selectedSports: {'basketball'},
        maxDistanceKm: () => 10.0,
      );

      expect(updated.selectedSports, {'basketball'});
      expect(updated.maxDistanceKm, 10.0);
    });

    test('copyWith preserves unchanged values', () {
      const state = MapFilterState(
        selectedSports: {'football'},
        maxDistanceKm: 5.0,
      );

      final updated = state.copyWith(maxDistanceKm: () => 10.0);

      expect(updated.selectedSports, {'football'});
      expect(updated.maxDistanceKm, 10.0);
    });

    test('equality: identical states are equal', () {
      const state1 = MapFilterState(
        selectedSports: {'football'},
        maxDistanceKm: 5.0,
      );
      const state2 = MapFilterState(
        selectedSports: {'football'},
        maxDistanceKm: 5.0,
      );

      expect(state1, equals(state2));
    });

    test('equality: different sports are not equal', () {
      const state1 = MapFilterState(
        selectedSports: {'football'},
        maxDistanceKm: 5.0,
      );
      const state2 = MapFilterState(
        selectedSports: {'basketball'},
        maxDistanceKm: 5.0,
      );

      expect(state1, isNot(equals(state2)));
    });

    test('equality: different distances are not equal', () {
      const state1 = MapFilterState(
        selectedSports: {'football'},
        maxDistanceKm: 5.0,
      );
      const state2 = MapFilterState(
        selectedSports: {'football'},
        maxDistanceKm: 10.0,
      );

      expect(state1, isNot(equals(state2)));
    });
  });
}
