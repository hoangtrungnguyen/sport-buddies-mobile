// Widget tests for MapScreen.
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

import 'package:customer/features/map/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MapScreen', () {
    testWidgets('renders without crashing (empty API key → OSM fallback)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MapScreen(),
        ),
      );
      // No exception means the widget tree built successfully.
      expect(find.byType(MapScreen), findsOneWidget);
    });

    testWidgets('contains a FlutterMap widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MapScreen(),
        ),
      );
      expect(find.byType(FlutterMap), findsOneWidget);
    });

    testWidgets('has a Scaffold as the root layout',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MapScreen(),
        ),
      );
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });
  });
}
