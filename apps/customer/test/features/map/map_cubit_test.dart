// Unit tests for MapCubit — grava-c9ca.1.3
//
// Verifies the loading → loaded / error state transitions driven by
// CourtRepository results.

import 'package:bloc_test/bloc_test.dart';
import 'package:customer/features/map/map_cubit.dart';
import 'package:customer/features/map/map_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spb_core/models/court.dart';
import 'package:spb_core/spb_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../court_repository_test_helpers.dart';

void main() {
  const courts = [
    Court(id: '1', name: 'Sân A', lat: 10.7, lng: 106.7),
    Court(id: '2', name: 'Sân B', lat: 10.8, lng: 106.8),
  ];

  group('MapCubit', () {
    test('initial state is MapInitial', () {
      final cubit = MapCubit(
        repository: FakeCourtRepository(rowsProvider: () async => []),
      );
      expect(cubit.state, const MapInitial());
      cubit.close();
    });

    blocTest<MapCubit, MapState>(
      'emits [MapLoading, MapLoaded] on successful fetch',
      build: () => MapCubit(
        repository: FakeCourtRepository(
          rowsProvider: () async => courts
              .map((c) => {'id': c.id, 'name': c.name, 'lat': c.lat, 'lng': c.lng})
              .toList(),
        ),
      ),
      act: (cubit) => cubit.loadCourts(),
      expect: () => [
        const MapLoading(),
        const MapLoaded(courts),
      ],
    );

    blocTest<MapCubit, MapState>(
      'emits [MapLoading, MapError] on repository failure',
      build: () => MapCubit(
        repository: FakeCourtRepository(
          rowsProvider: () => Future.error(
            const PostgrestException(message: 'db error'),
          ),
        ),
      ),
      act: (cubit) => cubit.loadCourts(),
      expect: () => [
        const MapLoading(),
        isA<MapError>(),
      ],
    );

    blocTest<MapCubit, MapState>(
      'emits [MapLoading, MapLoaded(empty)] when no courts returned',
      build: () => MapCubit(
        repository: FakeCourtRepository(rowsProvider: () async => []),
      ),
      act: (cubit) => cubit.loadCourts(),
      expect: () => [
        const MapLoading(),
        const MapLoaded([]),
      ],
    );
  });
}
