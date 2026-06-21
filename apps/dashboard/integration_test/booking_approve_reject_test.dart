// Web UI e2e: the booking approve / reject flow on the Requests screen, driven
// in a real Chrome browser via integration_test + patrol_finders.
//
// Self-contained — fake [BookingRequestRepository] + [BookingActionRepository]
// stand in for the backend, so no network is needed. This exercises the real
// RequestsScreen + RequestsBloc: pending cards, the approve→confirm+reveal+undo
// path, and the reject→reason-dialog→cancel path.
//
// Run (needs chromedriver on :4444 — see scripts/web_e2e.sh):
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/booking_approve_reject_test.dart -d chrome
import 'package:dashboard/features/requests/bloc/requests_bloc.dart';
import 'package:dashboard/features/requests/model/booking_request.dart';
import 'package:dashboard/features/requests/repository/booking_action_repository.dart';
import 'package:dashboard/features/requests/repository/booking_request_repository.dart';
import 'package:dashboard/features/requests/requests_logic.dart';
import 'package:dashboard/features/requests/view/requests_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:patrol_finders/patrol_finders.dart';

final _today = DateTime(2026, 5, 29);
const _phone = '+84900000000';

BookingRequest _pendingReq() {
  final start = DateTime(_today.year, _today.month, _today.day, 9);
  return BookingRequest(
    id: 'p',
    code: '#p',
    customerName: 'Nguyễn Văn A',
    courtName: 'Sân 1',
    startAt: start,
    endAt: start.add(const Duration(hours: 1)),
    status: BookingStatus.pending,
    revenue: 100000,
    slotId: 's',
    customerPhone: _phone,
  );
}

class _FakeRepo implements BookingRequestRepository {
  _FakeRepo(this.items);
  final List<BookingRequest> items;

  @override
  Future<List<BookingRequest>> fetchForDay({required DateTime day}) async =>
      isSameDay(day, _today) ? items : const [];
}

class _FakeActionRepo implements BookingActionRepository {
  final List<String> log = [];

  @override
  Future<void> approve({required String bookingId}) async =>
      log.add('approve:$bookingId');

  @override
  Future<void> reject({required String bookingId, String? reason}) async =>
      log.add('reject:$bookingId:$reason');

  @override
  Future<void> restorePending({
    required String bookingId,
    String? slotId,
  }) async =>
      log.add('restore:$bookingId');
}

Future<_FakeActionRepo> _pump(PatrolTester $) async {
  final actions = _FakeActionRepo();
  final bloc = RequestsBloc(
    repository: _FakeRepo([_pendingReq()]),
    actionRepository: actions,
    // Fixed "now" so the seeded day is the one shown on open.
    now: () => DateTime(2026, 5, 29, 9, 30),
  )..add(const RequestsEvent.started());

  await $.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: BlocProvider.value(value: bloc, child: const RequestsScreen()),
      ),
    ),
  );
  return actions;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  patrolWidgetTest('approve confirms the card, reveals phone and offers undo',
      ($) async {
    final actions = await _pump($);

    // Pending card shows the action buttons and hides the phone.
    expect($('Duyệt'), findsOneWidget);
    expect($('Từ chối'), findsOneWidget);
    expect($(_phone), findsNothing);
    await binding.takeScreenshot('booking-01-pending');

    await $('Duyệt').tap();

    // Approved: backend called once, badge flipped, phone revealed, buttons
    // replaced by the undo snackbar.
    expect(actions.log, ['approve:p']);
    expect($('Đã xác nhận'), findsOneWidget);
    expect($(_phone), findsOneWidget);
    expect($('Duyệt'), findsNothing);
    expect($('Hoàn tác'), findsOneWidget);
    await binding.takeScreenshot('booking-02-approved');
  });

  patrolWidgetTest('reject opens a reason step then cancels the card',
      ($) async {
    final actions = await _pump($);

    // Open the reject dialog via the card's reject button (its semantics id is
    // unambiguous — the dialog's confirm button reuses the "Từ chối" label).
    await $.tester.tap(find.bySemanticsLabel('requests-reject-btn-p'));
    await $.tester.pumpAndSettle();

    expect($('Từ chối đơn #p?'), findsOneWidget);
    await binding.takeScreenshot('booking-03-reject-dialog');

    await $.tester.enterText(
      find.bySemanticsLabel('requests-reject-reason-field'),
      'Trùng lịch',
    );
    await $.tester.pumpAndSettle();
    // Tap the concrete confirm button. (Tapping the bySemanticsLabel wrapper
    // misses the button on web; the dialog's confirm is the only FilledButton
    // labelled "Từ chối" — the card's reject is an OutlinedButton.)
    await $.tester.tap(find.widgetWithText(FilledButton, 'Từ chối'));
    // Dialog pop → _reject resumes → dispatch → async reject(): settle twice so
    // the extra microtask hop (vs the synchronous approve path) drains on web.
    await $.tester.pumpAndSettle();
    await $.tester.pumpAndSettle(const Duration(milliseconds: 300));
    await binding.takeScreenshot('booking-04-rejected');

    // Rejected with the typed reason; card now reads cancelled.
    expect(actions.log, ['reject:p:Trùng lịch']);
    expect($('Đã huỷ'), findsOneWidget);
  });
}
