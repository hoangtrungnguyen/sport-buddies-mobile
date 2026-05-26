// Unit tests for LocationCubit.
//
// AC verified:
//   1. Initial state is LocationInitial.
//   2. On permission denied → emits LocationLoaded with HCMC default.
//   3. On permission granted → emits LocationLoaded with GPS position.
//   4. On service disabled → emits LocationLoaded with HCMC default.
//   5. LocationLoaded equality works correctly.

import 'package:bloc_test/bloc_test.dart';
import 'package:customer/features/map/location_cubit.dart';
import 'package:customer/features/map/location_service.dart';
import 'package:customer/features/map/location_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockLocationService extends Mock implements LocationService {}

void main() {
  const hcmcLatLng = LatLng(10.7769, 106.7009);

  // Helper: build a fake geolocator Position.
  Position makePosition({required double lat, required double lng}) {
    return Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime(2024),
      accuracy: 10.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
  }

  group('LocationCubit', () {
    late MockLocationService mockService;

    setUp(() {
      mockService = MockLocationService();
    });

    test('initial state is LocationInitial', () {
      final cubit = LocationCubit(mockService);
      expect(cubit.state, isA<LocationInitial>());
      cubit.close();
    });

    blocTest<LocationCubit, LocationState>(
      'emits [LocationLoading, LocationLoaded(hcmc)] when location service disabled',
      build: () {
        when(() => mockService.isLocationServiceEnabled())
            .thenAnswer((_) async => false);
        return LocationCubit(mockService);
      },
      act: (cubit) => cubit.requestAndFetch(),
      expect: () => [
        isA<LocationLoading>(),
        const LocationLoaded(center: hcmcLatLng, isDefault: true),
      ],
    );

    blocTest<LocationCubit, LocationState>(
      'emits [LocationLoading, LocationLoaded(hcmc)] when permission denied',
      build: () {
        when(() => mockService.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(() => mockService.checkPermission())
            .thenAnswer((_) async => LocationPermission.denied);
        when(() => mockService.requestPermission())
            .thenAnswer((_) async => LocationPermission.denied);
        return LocationCubit(mockService);
      },
      act: (cubit) => cubit.requestAndFetch(),
      expect: () => [
        isA<LocationLoading>(),
        const LocationLoaded(center: hcmcLatLng, isDefault: true),
      ],
    );

    blocTest<LocationCubit, LocationState>(
      'emits [LocationLoading, LocationLoaded(hcmc)] when permission permanently denied',
      build: () {
        when(() => mockService.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(() => mockService.checkPermission())
            .thenAnswer((_) async => LocationPermission.deniedForever);
        return LocationCubit(mockService);
      },
      act: (cubit) => cubit.requestAndFetch(),
      expect: () => [
        isA<LocationLoading>(),
        const LocationLoaded(center: hcmcLatLng, isDefault: true),
      ],
    );

    blocTest<LocationCubit, LocationState>(
      'emits [LocationLoading, LocationLoaded(gps)] when permission granted',
      build: () {
        when(() => mockService.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(() => mockService.checkPermission())
            .thenAnswer((_) async => LocationPermission.denied);
        when(() => mockService.requestPermission())
            .thenAnswer((_) async => LocationPermission.whileInUse);
        when(() => mockService.getCurrentPosition())
            .thenAnswer((_) async => makePosition(lat: 10.8, lng: 106.6));
        return LocationCubit(mockService);
      },
      act: (cubit) => cubit.requestAndFetch(),
      expect: () => [
        isA<LocationLoading>(),
        const LocationLoaded(center: LatLng(10.8, 106.6), isDefault: false),
      ],
    );

    blocTest<LocationCubit, LocationState>(
      'emits [LocationLoading, LocationLoaded(gps)] when already whileInUse',
      build: () {
        when(() => mockService.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(() => mockService.checkPermission())
            .thenAnswer((_) async => LocationPermission.whileInUse);
        when(() => mockService.getCurrentPosition())
            .thenAnswer((_) async => makePosition(lat: 10.9, lng: 106.5));
        return LocationCubit(mockService);
      },
      act: (cubit) => cubit.requestAndFetch(),
      expect: () => [
        isA<LocationLoading>(),
        const LocationLoaded(center: LatLng(10.9, 106.5), isDefault: false),
      ],
    );

    blocTest<LocationCubit, LocationState>(
      'emits [LocationLoading, LocationLoaded(hcmc)] on exception',
      build: () {
        when(() => mockService.isLocationServiceEnabled())
            .thenThrow(Exception('unexpected'));
        return LocationCubit(mockService);
      },
      act: (cubit) => cubit.requestAndFetch(),
      expect: () => [
        isA<LocationLoading>(),
        const LocationLoaded(center: hcmcLatLng, isDefault: true),
      ],
    );
  });

  group('LocationLoaded', () {
    test('equality — same values', () {
      expect(
        const LocationLoaded(center: hcmcLatLng, isDefault: true),
        equals(const LocationLoaded(center: hcmcLatLng, isDefault: true)),
      );
    });

    test('equality — different isDefault', () {
      expect(
        const LocationLoaded(center: hcmcLatLng, isDefault: true),
        isNot(
            equals(const LocationLoaded(center: hcmcLatLng, isDefault: false))),
      );
    });

    test('equality — different center', () {
      expect(
        const LocationLoaded(center: LatLng(1.0, 2.0), isDefault: false),
        isNot(equals(
            const LocationLoaded(
                center: LatLng(3.0, 4.0), isDefault: false))),
      );
    });
  });
}
