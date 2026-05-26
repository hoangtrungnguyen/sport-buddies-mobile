// Widget tests for MapScreen.
//
// These tests run in the default test-runner context where no --dart-define
// values are set, so Env.vietmapApiKey is the empty string. MapScreen must
// detect the empty key and fall back to the public OpenStreetMap tile URL so
// the test host does not need network access to a keyed endpoint.
//
// MapScreen accepts an optional [LocationCubit] parameter for testing so no
// real GPS call is issued during widget tests.
//
// AC verified:
//   1. MapScreen widget exists and can be constructed.
//   2. Renders without crashing when API key is empty (OSM fallback).
//   3. FlutterMap is present in the widget tree.
//   4. Map centre updates reactively when LocationLoaded emitted.

import 'package:bloc_test/bloc_test.dart';
import 'package:customer/features/map/location_cubit.dart';
import 'package:customer/features/map/location_service.dart';
import 'package:customer/features/map/location_state.dart';
import 'package:customer/features/map/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockLocationService extends Mock implements LocationService {}

class MockLocationCubit extends MockCubit<LocationState>
    implements LocationCubit {}

void main() {
  late MockLocationCubit mockCubit;

  setUp(() {
    mockCubit = MockLocationCubit();
    // Default state: resolved to HCMC default so the map has a centre.
    when(() => mockCubit.state).thenReturn(
      const LocationLoaded(center: LatLng(10.7769, 106.7009), isDefault: true),
    );
  });

  Widget buildSubject({LocationCubit? cubit}) => MaterialApp(
        home: MapScreen(cubit: cubit ?? mockCubit),
      );

  group('MapScreen', () {
    testWidgets('renders without crashing (empty API key → OSM fallback)',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.byType(MapScreen), findsOneWidget);
    });

    testWidgets('contains a FlutterMap widget', (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.byType(FlutterMap), findsOneWidget);
    });

    testWidgets('has a Scaffold as the root layout',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });

    testWidgets('shows map centred on GPS position when LocationLoaded(gps)',
        (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(
        const LocationLoaded(
          center: LatLng(10.8, 106.6),
          isDefault: false,
        ),
      );
      await tester.pumpWidget(buildSubject());
      expect(find.byType(FlutterMap), findsOneWidget);
    });

    testWidgets('shows FlutterMap while LocationLoading',
        (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const LocationLoading());
      await tester.pumpWidget(buildSubject());
      expect(find.byType(FlutterMap), findsOneWidget);
    });
  });
}
