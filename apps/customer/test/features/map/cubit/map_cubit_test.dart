// Unit tests for MapCubit pin-colour logic — grava-c9ca.2.1.
//
// These tests cover the colour-derivation logic (green/grey based on open
// slot count) without requiring a real Supabase connection.
//
// AC verified:
//   1. markerColor is green when openSlotCount > 0.
//   2. markerColor is grey when openSlotCount == 0.
//   3. MapCubit emits MapLoading then MapLoaded on successful fetch.
//   4. MapCubit emits MapLoading then MapError on repository failure.
//   5. CourtAvailability equality / hashCode contract.

import 'package:customer/features/map/cubit/map_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spb_core/spb_core.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockCourtAvailabilityRepository extends Mock
    implements CourtAvailabilityRepository {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('markerColor', () {
    test('returns green when openSlotCount > 0', () {
      const court = CourtAvailability(
        courtId: 'c1',
        name: 'Court A',
        lat: 10.0,
        lng: 106.0,
        openSlotCount: 3,
      );
      expect(court.markerColor, equals(const Color(0xFF2E7D32)));
    });

    test('returns grey when openSlotCount == 0', () {
      const court = CourtAvailability(
        courtId: 'c1',
        name: 'Court A',
        lat: 10.0,
        lng: 106.0,
        openSlotCount: 0,
      );
      expect(court.markerColor, equals(const Color(0xFF9E9E9E)));
    });

    test('returns green for very large openSlotCount', () {
      const court = CourtAvailability(
        courtId: 'c2',
        name: 'Court B',
        lat: 10.0,
        lng: 106.0,
        openSlotCount: 999,
      );
      expect(court.markerColor, equals(const Color(0xFF2E7D32)));
    });
  });

  group('CourtAvailability equality', () {
    test('equal when all fields match', () {
      const a = CourtAvailability(
        courtId: 'c1',
        name: 'Court A',
        lat: 10.0,
        lng: 106.0,
        openSlotCount: 5,
      );
      const b = CourtAvailability(
        courtId: 'c1',
        name: 'Court A',
        lat: 10.0,
        lng: 106.0,
        openSlotCount: 5,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when openSlotCount differs', () {
      const a = CourtAvailability(
        courtId: 'c1',
        name: 'Court A',
        lat: 10.0,
        lng: 106.0,
        openSlotCount: 0,
      );
      const b = CourtAvailability(
        courtId: 'c1',
        name: 'Court A',
        lat: 10.0,
        lng: 106.0,
        openSlotCount: 1,
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('MapCubit', () {
    late MockCourtAvailabilityRepository mockRepo;

    setUp(() {
      mockRepo = MockCourtAvailabilityRepository();
    });

    test('emits [MapLoading, MapLoaded] on successful fetch', () async {
      final courts = [
        const CourtAvailability(
          courtId: 'c1',
          name: 'Court A',
          lat: 10.0,
          lng: 106.0,
          openSlotCount: 2,
        ),
        const CourtAvailability(
          courtId: 'c2',
          name: 'Court B',
          lat: 10.1,
          lng: 106.1,
          openSlotCount: 0,
        ),
      ];

      when(() => mockRepo.fetchCourtsWithAvailability())
          .thenAnswer((_) async => Success(courts));

      final cubit = MapCubit(repository: mockRepo);

      final future = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<MapLoading>(),
          isA<MapLoaded>().having(
            (s) => s.courts,
            'courts',
            courts,
          ),
        ]),
      );

      await cubit.loadCourts();
      await future;
    });

    test('emits [MapLoading, MapError] on repository failure', () async {
      when(() => mockRepo.fetchCourtsWithAvailability())
          .thenAnswer((_) async => const Failure(NetworkFailure()));

      final cubit = MapCubit(repository: mockRepo);

      final future = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<MapLoading>(),
          isA<MapError>(),
        ]),
      );

      await cubit.loadCourts();
      await future;
    });

    test('initial state is MapInitial', () {
      final cubit = MapCubit(repository: mockRepo);
      expect(cubit.state, isA<MapInitial>());
    });
  });
}
