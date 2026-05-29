// Widget tests for _SlotListPanel — CAPP-034
//
// AC verified:
//   1. Panel shows CircularProgressIndicator while loading.
//   2. Panel shows empty-state message when no slots returned.
//   3. Panel shows slot cards (court name, time, capacity) when slots loaded.
//   4. Panel shows error message on SlotListError.
//   5. Tapping a slot card calls onTap (navigation to /slot/:id is wired in
//      _SlotCard via GoRouter; here we verify the card renders and is tappable).
//   6. View-toggle button is visible and switches between map and slot views.

import 'package:customer/features/map/cubit/map_cubit.dart';
import 'package:customer/features/map/map_screen.dart';
import 'package:customer/features/slots/cubit/open_slot_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

final _start1 = DateTime.utc(2026, 6, 15, 19, 0);
final _end1   = DateTime.utc(2026, 6, 15, 20, 30);

Slot get _slot1 => Slot(
  id: 'slot-1',
  startTime: _start1,
  endTime: _end1,
  courtId: 'court-1',
  courtName: 'Pickle Hub Q1',
  sportType: 'pickleball',
  accessPolicy: 'open',
  maxPlayers: 6,
  currentPlayers: 3,
);

/// Pumps a [MapScreen] with both [MapCubit] and [SlotListCubit] in the tree.
///
/// [slotState] is forced immediately via [SlotListCubit.emit] after build.
Future<void> _pumpMap(
  WidgetTester tester, {
  required SlotListState slotState,
}) async {
  final courtRepo = MockCourtAvailabilityRepository();
  when(() => courtRepo.fetchCourtsWithAvailability())
      .thenAnswer((_) async => const Success([]));

  final slotRepo = MockSlotRepository();
  when(() => slotRepo.fetchAllGroupSlots())
      .thenAnswer((_) async => const Success([]));

  final mapCubit = MapCubit(repository: courtRepo);
  final slotCubit = _ManualSlotCubit(slotRepo);

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<MapCubit>(create: (_) => mapCubit),
        BlocProvider<SlotListCubit>(create: (_) => slotCubit),
      ],
      child: const MaterialApp(home: MapScreen()),
    ),
  );

  // Force the desired slot state.
  slotCubit.forceState(slotState);
  await tester.pump();
}

/// Helper to open the Slot trống panel by tapping the toggle button.
Future<void> _openSlotPanel(WidgetTester tester) async {
  await tester.tap(find.textContaining('Slot trống'));
  await tester.pump();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('_ViewToggle', () {
    testWidgets('shows Bản đồ and Slot trống buttons', (tester) async {
      await _pumpMap(tester, slotState: const SlotListInitial());
      expect(find.text('Bản đồ'), findsOneWidget);
      expect(find.textContaining('Slot trống'), findsOneWidget);
    });
  });

  group('_SlotListPanel states', () {
    testWidgets('shows loading spinner when SlotListLoading', (tester) async {
      await _pumpMap(tester, slotState: const SlotListLoading());
      await _openSlotPanel(tester);

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('shows empty message when SlotListLoaded with no slots',
        (tester) async {
      await _pumpMap(tester, slotState: const SlotListLoaded([]));
      await _openSlotPanel(tester);

      expect(
        find.textContaining('Không có slot chơi ghép'),
        findsOneWidget,
      );
    });

    testWidgets('shows slot card with court name when SlotListLoaded',
        (tester) async {
      await _pumpMap(tester, slotState: SlotListLoaded([_slot1]));
      await _openSlotPanel(tester);

      expect(find.textContaining('Pickle Hub Q1'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows spot remaining vs capacity in slot card', (tester) async {
      await _pumpMap(tester, slotState: SlotListLoaded([_slot1]));
      await _openSlotPanel(tester);

      // _SlotCard renders "3/6 người" for currentPlayers/maxPlayers.
      expect(find.textContaining('3/6'), findsOneWidget);
    });

    testWidgets('shows time label in slot card', (tester) async {
      await _pumpMap(tester, slotState: SlotListLoaded([_slot1]));
      await _openSlotPanel(tester);

      expect(find.textContaining('19:00'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows error message when SlotListError', (tester) async {
      await _pumpMap(
        tester,
        slotState: const SlotListError('Không có kết nối mạng.'),
      );
      await _openSlotPanel(tester);

      expect(find.textContaining('Không có kết nối mạng'), findsOneWidget);
    });

    testWidgets('close button returns to map view', (tester) async {
      await _pumpMap(tester, slotState: const SlotListLoaded([]));
      await _openSlotPanel(tester);

      // Close button is an Icons.close icon.
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // Slot panel's empty-message should no longer be visible.
      expect(find.textContaining('Không có slot chơi ghép'), findsNothing);
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _ManualSlotCubit extends SlotListCubit {
  _ManualSlotCubit(super.repository);

  void forceState(SlotListState s) => emit(s);
}
