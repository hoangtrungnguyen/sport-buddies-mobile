// Widget tests for MapScreen — grava-c9ca.1.3
//
// These tests run in the default test-runner context where no --dart-define
// values are set, so Env.vietmapApiKey is the empty string. MapScreen must
// detect the empty key and fall back to the public OpenStreetMap tile URL so
// the test host does not need network access to a keyed endpoint.
//
// AC verified:
//   1. MapScreen widget exists and can be constructed.
//   2. Renders without crashing when API key is empty (OSM fallback).
//   3. FlutterMap is present in the widget tree.
//   4. When MapLoaded is emitted, MarkerLayer is present in the widget tree.
//   5. Tapping a marker shows a bottom sheet with the court name.
//   6. MapLoading shows a CircularProgressIndicator.

import 'package:customer/features/map/map_cubit.dart';
import 'package:customer/features/map/map_screen.dart';
import 'package:customer/features/map/map_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spb_core/models/court.dart';

import '../../court_repository_test_helpers.dart';

void main() {
  group('MapScreen', () {
    testWidgets('renders without crashing (empty API key → OSM fallback)',
        (WidgetTester tester) async {
      final cubit = MapCubit(
        repository: FakeCourtRepository(rowsProvider: () async => []),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(
        MaterialApp(home: MapScreen(cubit: cubit)),
      );
      expect(find.byType(MapScreen), findsOneWidget);
    });

    testWidgets('contains a FlutterMap widget', (WidgetTester tester) async {
      final cubit = MapCubit(
        repository: FakeCourtRepository(rowsProvider: () async => []),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(
        MaterialApp(home: MapScreen(cubit: cubit)),
      );
      expect(find.byType(FlutterMap), findsOneWidget);
    });

    testWidgets('has a Scaffold as the root layout',
        (WidgetTester tester) async {
      final cubit = MapCubit(
        repository: FakeCourtRepository(rowsProvider: () async => []),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(
        MaterialApp(home: MapScreen(cubit: cubit)),
      );
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });

    testWidgets('shows CircularProgressIndicator while loading',
        (WidgetTester tester) async {
      // Provide a cubit that is already in MapLoading state.
      final cubit = _ManualMapCubit();
      addTearDown(cubit.close);
      cubit.setLoading();

      await tester.pumpWidget(
        MaterialApp(home: MapScreen(cubit: cubit)),
      );
      await tester.pump(); // let BlocBuilder rebuild

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows MarkerLayer when courts are loaded',
        (WidgetTester tester) async {
      const courts = [
        Court(id: '1', name: 'Sân A', lat: 10.7, lng: 106.7),
      ];
      final cubit = _ManualMapCubit();
      addTearDown(cubit.close);
      cubit.setLoaded(courts);

      await tester.pumpWidget(
        MaterialApp(home: MapScreen(cubit: cubit)),
      );
      await tester.pump();

      expect(find.byType(MarkerLayer), findsOneWidget);
    });

    testWidgets('tapping a marker shows bottom sheet with court name',
        (WidgetTester tester) async {
      // Use the exact map centre so the marker lands within the viewport.
      const courts = [
        Court(id: '1', name: 'Sân Tao Đàn', lat: 10.7769, lng: 106.7009),
      ];
      final cubit = _ManualMapCubit();
      addTearDown(cubit.close);
      cubit.setLoaded(courts);

      await tester.pumpWidget(
        MaterialApp(home: MapScreen(cubit: cubit)),
      );
      await tester.pump();

      // Tap the marker icon — placed at the map centre, always in viewport.
      await tester.tap(find.byIcon(Icons.location_pin));
      await tester.pumpAndSettle();

      expect(find.text('Sân Tao Đàn'), findsAtLeastNWidgets(1));
    });
  });
}

/// Manually controllable MapCubit for widget tests — allows direct state injection.
class _ManualMapCubit extends MapCubit {
  _ManualMapCubit()
      : super(
          repository: FakeCourtRepository(rowsProvider: () async => []),
        );

  void setLoading() => emit(const MapLoading());
  void setLoaded(List<Court> courts) => emit(MapLoaded(courts));
  void setError(String message) => emit(MapError(message));
}
