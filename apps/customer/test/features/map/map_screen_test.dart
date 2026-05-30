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
//   7. Empty state is shown when no courts are in range (grava-c9ca.4.3).

import 'package:customer/features/map/cubit/map_cubit.dart';
import 'package:customer/features/map/map_screen.dart';
import 'package:customer/features/slots/cubit/open_slot_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spb_core/spb_core.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockCourtAvailabilityRepository extends Mock
    implements CourtAvailabilityRepository {}

class MockSlotRepository extends Mock implements SlotRepository {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Pumps [MapScreen] with both required cubits.
Future<void> pumpMapScreen(
  WidgetTester tester, {
  required MapCubit mapCubit,
  SlotListCubit? slotCubit,
}) async {
  final sc = slotCubit ?? _defaultSlotCubit();
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<MapCubit>(create: (_) => mapCubit),
        BlocProvider<SlotListCubit>(create: (_) => sc),
      ],
      child: const MaterialApp(home: MapScreen()),
    ),
  );
}

SlotListCubit _defaultSlotCubit() {
  final repo = MockSlotRepository();
  when(() => repo.fetchAllGroupSlots())
      .thenAnswer((_) async => const Success([]));
  return SlotListCubit(repo);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('MapScreen', () {
    testWidgets('renders without crashing (empty API key → OSM fallback)',
        (WidgetTester tester) async {
      final mockRepo = MockCourtAvailabilityRepository();
      when(() => mockRepo.fetchCourtsWithAvailability())
          .thenAnswer((_) async => const Success([]));
      final cubit = MapCubit(repository: mockRepo);
      addTearDown(cubit.close);

      await pumpMapScreen(tester, mapCubit: cubit);
      expect(find.byType(MapScreen), findsOneWidget);
    });

    testWidgets('contains a FlutterMap widget', (WidgetTester tester) async {
      final mockRepo = MockCourtAvailabilityRepository();
      when(() => mockRepo.fetchCourtsWithAvailability())
          .thenAnswer((_) async => const Success([]));
      final cubit = MapCubit(repository: mockRepo);
      addTearDown(cubit.close);

      await pumpMapScreen(tester, mapCubit: cubit);
      expect(find.byType(FlutterMap), findsOneWidget);
    });

    testWidgets('has a Scaffold as the root layout',
        (WidgetTester tester) async {
      final mockRepo = MockCourtAvailabilityRepository();
      when(() => mockRepo.fetchCourtsWithAvailability())
          .thenAnswer((_) async => const Success([]));
      final cubit = MapCubit(repository: mockRepo);
      addTearDown(cubit.close);

      await pumpMapScreen(tester, mapCubit: cubit);
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });

    testWidgets('shows CircularProgressIndicator while loading',
        (WidgetTester tester) async {
      final cubit = _ManualMapCubit();
      addTearDown(cubit.close);
      cubit.setLoading();

      await pumpMapScreen(tester, mapCubit: cubit);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows MarkerLayer when courts are loaded',
        (WidgetTester tester) async {
      const courts = [
        CourtAvailability(
          courtId: '1',
          name: 'Sân A',
          lat: 10.7,
          lng: 106.7,
          openSlotCount: 5,
        ),
      ];
      final cubit = _ManualMapCubit();
      addTearDown(cubit.close);
      cubit.setLoaded(courts);

      await pumpMapScreen(tester, mapCubit: cubit);
      await tester.pump();

      expect(find.byType(MarkerLayer), findsOneWidget);
    });

    testWidgets('tapping a marker shows bottom sheet with court name',
        (WidgetTester tester) async {
      const courts = [
        CourtAvailability(
          courtId: '1',
          name: 'Sân Tao Đàn',
          lat: 10.7769,
          lng: 106.7009,
          openSlotCount: 3,
        ),
      ];
      final cubit = _ManualMapCubit();
      addTearDown(cubit.close);
      cubit.setLoaded(courts);

      await pumpMapScreen(tester, mapCubit: cubit);
      await tester.pump();

      await tester.tap(find.byIcon(Icons.location_pin));
      await tester.pumpAndSettle();

      expect(find.text('Sân Tao Đàn'), findsAtLeastNWidgets(1));
    });

    // grava-c9ca.4.3: Empty state tests
    testWidgets('shows empty state when no courts are in range',
        (WidgetTester tester) async {
      final cubit = _ManualMapCubit();
      addTearDown(cubit.close);

      await pumpMapScreen(tester, mapCubit: cubit);
      await tester.pump();

      // After pump, loadCourts() is called and completes with empty list
      // Verify empty state is shown
      expect(find.text('Không tìm thấy sân gần bạn'), findsOneWidget);
      // Verify FlutterMap is NOT shown when empty
      expect(find.byType(FlutterMap), findsNothing);
    });

    testWidgets('empty state shows location_off icon',
        (WidgetTester tester) async {
      final cubit = _ManualMapCubit();
      addTearDown(cubit.close);
      cubit.setLoaded(const []);

      await pumpMapScreen(tester, mapCubit: cubit);
      await tester.pump();

      expect(find.byIcon(Icons.location_off), findsOneWidget);
    });

    testWidgets('empty state shows helpful message about zooming or filtering',
        (WidgetTester tester) async {
      final cubit = _ManualMapCubit();
      addTearDown(cubit.close);
      cubit.setLoaded(const []);

      await pumpMapScreen(tester, mapCubit: cubit);
      await tester.pump();

      expect(
        find.text('Thử phóng to bản đồ hoặc thay đổi bộ lọc'),
        findsOneWidget,
      );
    });
  });
}

/// Manually controllable MapCubit for widget tests — allows direct state injection.
class _ManualMapCubit extends MapCubit {
  _ManualMapCubit() : super(repository: _FakeRepository());

  void setLoading() => emit(const MapLoading());
  void setLoaded(List<CourtAvailability> courts) => emit(MapLoaded(courts));
  void setError(String message) => emit(MapError(message));
}

/// Fake repository that returns empty list (state is controlled manually).
class _FakeRepository implements CourtAvailabilityRepository {
  @override
  Future<Result<List<CourtAvailability>>> fetchCourtsWithAvailability() async {
    return const Success([]);
  }
}
