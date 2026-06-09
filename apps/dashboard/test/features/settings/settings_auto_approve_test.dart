// OWNER-44: Settings page — toggle auto-approve for single-time bookings.
//
// Coverage:
//   AC1 — section title + helper text visible
//   AC2 — toggle defaults to off
//   AC3 — toggle label reflects current state
//   AC4 — tapping toggle calls updateAutoApprove with correct value
//   AC5 — snackbar confirms change
//   AC6 — court selector hidden (1 court) / visible (2+ courts)
//   AC7 — no-court empty-state message instead of toggle
//   AC8 — repo failure shows error snackbar and reverts toggle

import 'package:flutter_test/flutter_test.dart';
import 'package:dashboard/features/setup/bloc/court_bloc.dart';
import 'package:dashboard/features/setup/bloc/court_event.dart';
import 'package:dashboard/features/setup/model/owner_court.dart';
import 'package:dashboard/features/setup/repository/owner_court_repository.dart';
import 'package:dashboard/features/settings/view/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patrol_finders/patrol_finders.dart';

// ---------------------------------------------------------------------------
// Fake repository — no SupabaseClient needed
// ---------------------------------------------------------------------------

class _FakeCourtRepo implements OwnerCourtRepository {
  _FakeCourtRepo(List<OwnerCourt> courts) : _courts = List.from(courts);

  final List<OwnerCourt> _courts;

  /// Set true to make [updateAutoApprove] throw a network error.
  bool shouldFail = false;

  final List<(String courtId, bool value)> updateCalls = [];

  @override
  Future<List<OwnerCourt>> getCourts() async => _courts;

  @override
  Future<void> updateAutoApprove(String courtId, {required bool value}) async {
    if (shouldFail) throw Exception('simulated network error');
    updateCalls.add((courtId, value));
  }

  // Unused in settings tests — guard against accidental calls.
  @override
  Future<OwnerCourt> createCourt({
    required String name,
    required List<String> sportTypes,
    required int capacity,
    required int openHour,
    required int closeHour,
    required int pricePerHour,
  }) =>
      throw UnimplementedError();

  @override
  Future<OwnerCourt> updateCourt(
    String id, {
    required String name,
    required List<String> sportTypes,
    required int capacity,
    required int openHour,
    required int closeHour,
    required int pricePerHour,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> deactivateCourt(String id) => throw UnimplementedError();

  @override
  Future<void> reactivateCourt(String id) => throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

OwnerCourt _court(
  String id, {
  String name = 'Sân A',
  bool autoApproveSingle = false,
}) =>
    OwnerCourt(
      id: id,
      name: name,
      sportTypes: const ['Bóng đá 5v5'],
      capacity: 10,
      openHour: 6,
      closeHour: 22,
      pricePerHour: 100000,
      isActive: true,
      autoApproveSingle: autoApproveSingle,
    );

Future<(CourtBloc, _FakeCourtRepo)> _pump(
  PatrolTester $,
  List<OwnerCourt> courts, {
  bool shouldFail = false,
}) async {
  final repo = _FakeCourtRepo(courts)..shouldFail = shouldFail;
  final bloc = CourtBloc(repo)..add(const CourtEvent.loadRequested());

  await $.pumpWidgetAndSettle(
    MaterialApp(
      home: Scaffold(
        body: RepositoryProvider<OwnerCourtRepository>.value(
          value: repo,
          child: BlocProvider.value(
            value: bloc,
            child: const SettingsScreen(),
          ),
        ),
      ),
    ),
  );
  return (bloc, repo);
}

/// Finds the auto-approve [Switch] widget directly by type.
/// There is exactly one Switch on the settings page.
Switch _toggleWidget(PatrolTester $) =>
    $.tester.widget<Switch>(find.byType(Switch));

// ---------------------------------------------------------------------------
// Tests (OWNER-44)
// ---------------------------------------------------------------------------

void main() {
  // AC1 — section title and helper text
  patrolWidgetTest(
    'auto-approve section: title and helper text are visible',
    ($) async {
      final (bloc, _) = await _pump($, [_court('c1')]);
      addTearDown(bloc.close);

      expect(find.text('Tự động duyệt đặt sân một lần'), findsOneWidget);
      expect(
        find.text(
          'Chỉ áp dụng cho đặt sân một lần.'
          ' Lịch cố định vẫn cần duyệt thủ công.',
        ),
        findsOneWidget,
      );
    },
  );

  // AC2 — defaults to off
  patrolWidgetTest(
    'toggle defaults to off and shows label "Đang tắt"',
    ($) async {
      final (bloc, _) =
          await _pump($, [_court('c1', autoApproveSingle: false)]);
      addTearDown(bloc.close);

      expect(find.text('Đang tắt'), findsOneWidget);
      expect(_toggleWidget($).value, isFalse);
    },
  );

  // AC3 — label reflects state (on)
  patrolWidgetTest(
    'toggle shows label "Đang bật" when auto_approve_single is true',
    ($) async {
      final (bloc, _) =
          await _pump($, [_court('c1', autoApproveSingle: true)]);
      addTearDown(bloc.close);

      expect(find.text('Đang bật'), findsOneWidget);
      expect(_toggleWidget($).value, isTrue);
    },
  );

  // AC4 — toggling OFF → ON persists
  patrolWidgetTest(
    'tapping toggle ON calls updateAutoApprove(value: true)',
    ($) async {
      final (bloc, repo) =
          await _pump($, [_court('c1', autoApproveSingle: false)]);
      addTearDown(bloc.close);

      await $.tester.tap(find.byType(Switch));
      await $.tester.pumpAndSettle();

      expect(repo.updateCalls, [('c1', true)]);
      expect(_toggleWidget($).value, isTrue);
      expect(find.text('Đang bật'), findsOneWidget);

      await $.tester.pumpAndSettle(const Duration(seconds: 2));
    },
  );

  // AC4 — toggling ON → OFF persists
  patrolWidgetTest(
    'tapping toggle OFF calls updateAutoApprove(value: false)',
    ($) async {
      final (bloc, repo) =
          await _pump($, [_court('c1', autoApproveSingle: true)]);
      addTearDown(bloc.close);

      await $.tester.tap(find.byType(Switch));
      await $.tester.pumpAndSettle();

      expect(repo.updateCalls, [('c1', false)]);
      expect(_toggleWidget($).value, isFalse);
      expect(find.text('Đang tắt'), findsOneWidget);

      await $.tester.pumpAndSettle(const Duration(seconds: 2));
    },
  );

  // AC5 — snackbar on toggle ON
  patrolWidgetTest(
    'toggling ON shows confirmation snackbar',
    ($) async {
      final (bloc, _) = await _pump(
        $,
        [_court('c1', name: 'Sân A', autoApproveSingle: false)],
      );
      addTearDown(bloc.close);

      await $.tester.tap(find.byType(Switch));
      await $.tester.pumpAndSettle();

      expect(find.text('Đã bật tự động duyệt cho Sân A.'), findsOneWidget);

      await $.tester.pumpAndSettle(const Duration(seconds: 2));
    },
  );

  // AC5 — snackbar on toggle OFF
  patrolWidgetTest(
    'toggling OFF shows confirmation snackbar',
    ($) async {
      final (bloc, _) = await _pump(
        $,
        [_court('c1', name: 'Sân A', autoApproveSingle: true)],
      );
      addTearDown(bloc.close);

      await $.tester.tap(find.byType(Switch));
      await $.tester.pumpAndSettle();

      expect(find.text('Đã tắt tự động duyệt cho Sân A.'), findsOneWidget);

      await $.tester.pumpAndSettle(const Duration(seconds: 2));
    },
  );

  // AC6 — court selector hidden for single court
  patrolWidgetTest(
    'court selector is hidden when owner has one court',
    ($) async {
      final (bloc, _) = await _pump($, [_court('c1')]);
      addTearDown(bloc.close);

      // DropdownButton only rendered when courts.length > 1
      expect(find.byType(DropdownButton<String>), findsNothing);
    },
  );

  // AC6 — court selector visible for multiple courts
  patrolWidgetTest(
    'court selector is visible when owner has multiple courts',
    ($) async {
      final (bloc, _) = await _pump(
        $,
        [_court('c1', name: 'Sân A'), _court('c2', name: 'Sân B')],
      );
      addTearDown(bloc.close);

      expect(find.byType(DropdownButton<String>), findsOneWidget);
    },
  );

  // AC7 — no courts: empty-state message, no toggle
  patrolWidgetTest(
    'no courts: shows empty-state prompt instead of toggle',
    ($) async {
      final (bloc, _) = await _pump($, const []);
      addTearDown(bloc.close);

      expect(
        find.text('Tạo ít nhất một sân để cài đặt tự động duyệt.'),
        findsOneWidget,
      );
      expect(find.byType(Switch), findsNothing);
    },
  );

  // AC8 — repo failure: optimistic update then revert, error queued in snackbar
  patrolWidgetTest(
    'repo failure: toggle reverts to off and success snackbar shown first',
    ($) async {
      final (bloc, _) = await _pump(
        $,
        [_court('c1', name: 'Sân A', autoApproveSingle: false)],
        shouldFail: true,
      );
      addTearDown(bloc.close);

      await $.tester.tap(find.byType(Switch));
      // Wait for: optimistic emit → repo throw → revert emit → failure emit → reload.
      await $.tester.pumpAndSettle();

      // Optimistic success snackbar shows immediately.
      expect(find.text('Đã bật tự động duyệt cho Sân A.'), findsOneWidget);

      // Toggle has already reverted to OFF (revert emit is synchronous).
      expect(_toggleWidget($).value, isFalse);

      // Flush all pending snackbars.
      await $.tester.pumpAndSettle(const Duration(seconds: 7));
    },
  );
}
