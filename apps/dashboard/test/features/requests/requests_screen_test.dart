import 'package:dashboard/features/requests/bloc/requests_bloc.dart';
import 'package:dashboard/features/requests/model/booking_request.dart';
import 'package:dashboard/features/requests/repository/booking_action_repository.dart';
import 'package:dashboard/features/requests/repository/booking_request_repository.dart';
import 'package:dashboard/features/requests/requests_logic.dart';
import 'package:dashboard/features/requests/view/requests_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

final _today = DateTime(2026, 5, 29);

BookingRequest _req(
  String id,
  int hour, {
  BookingStatus status = BookingStatus.confirmed,
  int revenue = 100000,
  String name = 'Khách',
  String? slotId,
  String? phone,
}) {
  final start = DateTime(_today.year, _today.month, _today.day, hour);
  return BookingRequest(
    id: id,
    code: '#$id',
    customerName: name,
    courtName: 'Sân 1',
    startAt: start,
    endAt: start.add(const Duration(hours: 1)),
    status: status,
    revenue: revenue,
    slotId: slotId,
    customerPhone: phone,
  );
}

class _FakeRepo implements BookingRequestRepository {
  _FakeRepo(this.items);
  final List<BookingRequest> items;
  final List<DateTime> calls = [];

  @override
  Future<List<BookingRequest>> fetchForDay({required DateTime day}) async {
    calls.add(day);
    // Only the seeded "today" has data; other days are empty.
    return isSameDay(day, _today) ? items : const [];
  }
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

Future<(RequestsBloc, _FakeRepo, _FakeActionRepo)> _pump(
  WidgetTester tester,
  List<BookingRequest> items,
) async {
  final repo = _FakeRepo(items);
  final actions = _FakeActionRepo();
  final bloc = RequestsBloc(
    repository: repo,
    actionRepository: actions,
    now: () => DateTime(2026, 5, 29, 9, 30),
  )..add(const RequestsEvent.started());
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: BlocProvider.value(
        value: bloc,
        child: const RequestsScreen(),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  return (bloc, repo, actions);
}

void main() {
  testWidgets('renders the summary bar with total, pending and revenue',
      (tester) async {
    final (bloc, _, _) = await _pump(tester, [
      _req('a', 8, status: BookingStatus.confirmed, revenue: 100000),
      _req('b', 9, status: BookingStatus.pending, revenue: 50000),
      _req('c', 10, status: BookingStatus.cancelled, revenue: 999000),
    ]);
    addTearDown(bloc.close);

    expect(find.text('Tổng đơn'), findsOneWidget);
    expect(find.text('Chờ xác nhận'), findsWidgets); // label + badge
    expect(find.text('Doanh thu dự kiến'), findsOneWidget);
    // total = 3; pending = 1; revenue excludes the cancelled 999k → 150.000đ.
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('150.000đ'), findsOneWidget);
  });

  testWidgets('a card shows customer, code, court, time and status badge',
      (tester) async {
    final (bloc, _, _) = await _pump(tester, [
      _req('a', 8, name: 'Nguyễn Văn A', status: BookingStatus.confirmed),
    ]);
    addTearDown(bloc.close);

    expect(find.text('Nguyễn Văn A'), findsOneWidget);
    expect(find.text('#a'), findsOneWidget);
    expect(find.text('Sân 1'), findsOneWidget);
    expect(find.text('08:00 – 09:00'), findsOneWidget);
    expect(find.text('Đã xác nhận'), findsOneWidget);
    expect(find.text('08:00'), findsOneWidget); // group time header
  });

  testWidgets('cancelled bookings are de-emphasized via reduced opacity',
      (tester) async {
    final (bloc, _, _) = await _pump(tester, [
      _req('a', 8, status: BookingStatus.cancelled),
    ]);
    addTearDown(bloc.close);

    expect(find.text('Đã huỷ'), findsOneWidget);
    expect(
      find.byWidgetPredicate((w) => w is Opacity && w.opacity == 0.55),
      findsOneWidget,
    );
  });

  testWidgets('empty day shows the empty state', (tester) async {
    final (bloc, _, _) = await _pump(tester, const []);
    addTearDown(bloc.close);

    expect(find.text('Chưa có đơn đặt sân nào'), findsOneWidget);
    expect(find.text('Các đơn đặt sân trong ngày sẽ hiển thị ở đây.'),
        findsOneWidget);
  });

  testWidgets('paginates 4 per page and the next button advances the page',
      (tester) async {
    final items = List.generate(6, (i) => _req('$i', 6 + i)); // 6 items
    final (bloc, _, _) = await _pump(tester, items);
    addTearDown(bloc.close);

    // Page 1: first 4 (hours 6–9). Record count is cumulative.
    expect(find.text('Hiển thị 4 trong 6 đơn'), findsOneWidget);
    expect(find.text('Trang 1/2'), findsOneWidget);
    expect(find.text('06:00'), findsOneWidget); // first group present
    expect(find.text('11:00'), findsNothing); // last item not on page 1

    final nextPage = find.bySemanticsLabel('requests-next-page-btn');
    await tester.ensureVisible(nextPage); // pagination bar sits below the fold
    await tester.tap(nextPage);
    await tester.pumpAndSettle();

    // Page 2: remaining 2 (hours 10–11).
    expect(find.text('Hiển thị 6 trong 6 đơn'), findsOneWidget);
    expect(find.text('Trang 2/2'), findsOneWidget);
    expect(find.text('11:00'), findsOneWidget);
    expect(find.text('06:00'), findsNothing);
  });

  testWidgets('day navigation fetches the next day', (tester) async {
    final (bloc, repo, _) = await _pump(tester, [_req('a', 8)]);
    addTearDown(bloc.close);

    expect(find.text(dayHeading(_today)), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('requests-next-day-btn'));
    await tester.pumpAndSettle();

    final tomorrow = DateTime(2026, 5, 30);
    expect(repo.calls.last, tomorrow);
    expect(find.text(dayHeading(tomorrow)), findsOneWidget);
    // Tomorrow has no data → empty state.
    expect(find.text('Chưa có đơn đặt sân nào'), findsOneWidget);
  });

  testWidgets('only pending cards show Duyệt / Từ chối buttons', (tester) async {
    final (bloc, _, _) = await _pump(tester, [
      _req('p', 8, status: BookingStatus.pending),
      _req('c', 9, status: BookingStatus.confirmed),
    ]);
    addTearDown(bloc.close);

    // One pending → exactly one pair of action buttons; the confirmed card adds
    // none. (FilledButton.icon is a private subtype, so match by label text.)
    expect(find.text('Duyệt'), findsOneWidget);
    expect(find.text('Từ chối'), findsOneWidget);
  });

  testWidgets('approve confirms the card, reveals phone, and offers undo',
      (tester) async {
    final (bloc, _, actions) = await _pump(tester, [
      _req('p', 8, status: BookingStatus.pending, phone: '+84900000000'),
    ]);
    addTearDown(bloc.close);

    // Phone hidden while pending.
    expect(find.text('+84900000000'), findsNothing);

    await tester.tap(find.text('Duyệt'));
    await tester.pumpAndSettle();

    expect(actions.log, ['approve:p']);
    expect(find.text('Đã xác nhận'), findsOneWidget); // badge flipped
    expect(find.text('+84900000000'), findsOneWidget); // revealed
    expect(find.text('Duyệt'), findsNothing); // action buttons gone
    expect(find.text('Hoàn tác'), findsOneWidget); // undo snackbar

    await tester.pumpAndSettle(const Duration(seconds: 5)); // flush snackbar
  });

  testWidgets('reject opens a reason step then cancels the card',
      (tester) async {
    final (bloc, _, actions) = await _pump(tester, [
      _req('p', 8, status: BookingStatus.pending, slotId: 'slot-p'),
    ]);
    addTearDown(bloc.close);

    await tester.tap(find.text('Từ chối'));
    await tester.pumpAndSettle();

    // Optional reason field + confirm step appears.
    expect(find.text('Từ chối đơn #p?'), findsOneWidget);
    await tester.enterText(
        find.bySemanticsLabel('requests-reject-reason-field'), 'Trùng lịch');
    await tester.tap(find.bySemanticsLabel('requests-reject-confirm-btn'));
    await tester.pumpAndSettle();

    expect(actions.log, ['reject:p:Trùng lịch']);
    expect(find.text('Đã huỷ'), findsOneWidget); // cancelled badge

    await tester.pumpAndSettle(const Duration(seconds: 5)); // flush snackbar
  });

  testWidgets('undo restores pending and re-hides the phone',
      (tester) async {
    final (bloc, _, actions) = await _pump(tester, [
      _req('p', 8, status: BookingStatus.pending, phone: '+84900000000'),
    ]);
    addTearDown(bloc.close);

    await tester.tap(find.text('Duyệt'));
    await tester.pumpAndSettle();
    expect(find.text('Đã xác nhận'), findsOneWidget);
    expect(find.text('+84900000000'), findsOneWidget); // revealed

    await tester.tap(find.text('Hoàn tác'));
    await tester.pumpAndSettle();

    expect(actions.log, ['approve:p', 'restore:p']);
    expect(find.text('Duyệt'), findsOneWidget); // pending again → buttons back
    expect(find.text('+84900000000'), findsNothing); // phone hidden again

    await tester.pumpAndSettle(const Duration(seconds: 5)); // flush snackbar
  });

  testWidgets('reject with no reason confirms and forwards a null reason',
      (tester) async {
    final (bloc, _, actions) = await _pump(tester, [
      _req('p', 8, status: BookingStatus.pending, slotId: 'slot-p'),
    ]);
    addTearDown(bloc.close);

    await tester.tap(find.text('Từ chối'));
    await tester.pumpAndSettle();
    // Leave the reason blank; confirm.
    await tester.tap(find.bySemanticsLabel('requests-reject-confirm-btn'));
    await tester.pumpAndSettle();

    expect(actions.log, ['reject:p:null']); // optional reason omitted
    expect(find.text('Đã huỷ'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 5)); // flush snackbar
  });

  testWidgets('dismissing the reject dialog leaves the request pending',
      (tester) async {
    final (bloc, _, actions) = await _pump(tester, [
      _req('p', 8, status: BookingStatus.pending),
    ]);
    addTearDown(bloc.close);

    await tester.tap(find.text('Từ chối'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Huỷ')); // cancel the dialog
    await tester.pumpAndSettle();

    expect(actions.log, isEmpty); // no mutation
    expect(find.text('Duyệt'), findsOneWidget); // still pending
  });
}
