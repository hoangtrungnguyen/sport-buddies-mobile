// Unit tests for SupabaseCourtRepository — grava-c9ca.1.3
//
// AC: unit test CourtRepository with mocked Supabase client.
//
// Strategy: subclass SupabaseCourtRepository and override `fetchRows()` to
// inject fixture data. This avoids wiring the full Supabase builder chain
// through mocktail (PostgrestFilterBuilder is itself a Future, making it
// very difficult to mock with standard tools).
//
// Covers:
//   1. getApprovedCourts returns Success<List<Court>> on valid data.
//   2. getApprovedCourts returns Failure<ServerFailure> on PostgrestException.
//   3. getApprovedCourts returns Failure<NetworkFailure> on generic exception.
//   4. fromJson is tolerant of int values for lat/lng.
//   5. Returns empty list when no approved courts exist.

import 'package:flutter_test/flutter_test.dart';
import 'package:spb_core/spb_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../court_repository_test_helpers.dart';

void main() {
  group('SupabaseCourtRepository.getApprovedCourts', () {
    test('returns Success with parsed courts on valid response', () async {
      final repo = FakeCourtRepository(
        rowsProvider: () async => [
          {'id': '1', 'name': 'Sân A', 'lat': 10.7, 'lng': 106.7},
          {'id': '2', 'name': 'Sân B', 'lat': 10.8, 'lng': 106.8},
        ],
      );

      final result = await repo.getApprovedCourts();

      expect(result, isA<Success<List<Court>>>());
      final courts = (result as Success<List<Court>>).value;
      expect(courts.length, 2);
      expect(courts[0].id, '1');
      expect(courts[0].name, 'Sân A');
      expect(courts[0].lat, 10.7);
      expect(courts[1].id, '2');
    });

    test('fromJson is tolerant of int lat/lng values', () async {
      final repo = FakeCourtRepository(
        rowsProvider: () async => [
          {'id': 'x', 'name': 'Sân X', 'lat': 10, 'lng': 106},
        ],
      );

      final result = await repo.getApprovedCourts();

      expect(result, isA<Success<List<Court>>>());
      final courts = (result as Success<List<Court>>).value;
      expect(courts[0].lat, 10.0);
      expect(courts[0].lng, 106.0);
    });

    test('returns Failure<ServerFailure> on PostgrestException', () async {
      final repo = FakeCourtRepository(
        rowsProvider: () => Future.error(
          const PostgrestException(message: 'relation "courts" does not exist'),
        ),
      );

      final result = await repo.getApprovedCourts();

      expect(result, isA<Failure<List<Court>>>());
      final failure = (result as Failure<List<Court>>).failure;
      expect(failure, isA<ServerFailure>());
    });

    test('returns Failure<NetworkFailure> on generic exception', () async {
      final repo = FakeCourtRepository(
        rowsProvider: () => Future.error(Exception('network error')),
      );

      final result = await repo.getApprovedCourts();

      expect(result, isA<Failure<List<Court>>>());
      final failure = (result as Failure<List<Court>>).failure;
      expect(failure, isA<NetworkFailure>());
    });

    test('returns empty Success list when no approved courts', () async {
      final repo = FakeCourtRepository(
        rowsProvider: () async => [],
      );

      final result = await repo.getApprovedCourts();

      expect(result, isA<Success<List<Court>>>());
      final courts = (result as Success<List<Court>>).value;
      expect(courts, isEmpty);
    });
  });
}
