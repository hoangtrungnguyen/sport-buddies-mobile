import 'package:dashboard/features/requests/bloc/requests_bloc.dart';
import 'package:dashboard/features/requests/model/booking_request.dart';
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

Future<(RequestsBloc, _FakeRepo)> _pump(
  WidgetTester tester,
  List<BookingRequest> items,
) async {
  final repo = _FakeRepo(items);
  final bloc = RequestsBloc(
    repository: repo,
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
  return (bloc, repo);
}

void main() {
  testWidgets('renders the summary bar with total, pending and revenue',
      (tester) async {
    final (bloc, _) = await _pump(tester, [
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
    final (bloc, _) = await _pump(tester, [
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
    final (bloc, _) = await _pump(tester, [
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
    final (bloc, _) = await _pump(tester, const []);
    addTearDown(bloc.close);

    expect(find.text('Chưa có đơn đặt sân nào'), findsOneWidget);
    expect(find.text('Các đơn đặt sân trong ngày sẽ hiển thị ở đây.'),
        findsOneWidget);
  });

  testWidgets('paginates 4 per page and the next button advances the page',
      (tester) async {
    final items = List.generate(6, (i) => _req('$i', 6 + i)); // 6 items
    final (bloc, _) = await _pump(tester, items);
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
    final (bloc, repo) = await _pump(tester, [_req('a', 8)]);
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
}
