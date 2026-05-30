import 'package:dashboard/features/requests/model/booking_request.dart';
import 'package:dashboard/features/slot_detail/model/slot_player.dart';
import 'package:dashboard/features/slot_detail/repository/slot_players_repository.dart';
import 'package:dashboard/features/slot_detail/view/slot_players_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements SlotPlayersRepository {
  _FakeRepo(this.players);
  final List<SlotPlayer> players;
  @override
  Future<List<SlotPlayer>> fetchPlayers({required String slotId}) async =>
      players;
}

Future<void> _open(WidgetTester tester, List<SlotPlayer> players,
    {int? capacity = 4}) async {
  late BuildContext ctx;
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(body: Builder(builder: (c) {
      ctx = c;
      return const SizedBox();
    })),
  ));
  showSlotPlayersDialog(
    ctx,
    slotId: 's1',
    courtName: 'Sân Tennis',
    startLocal: DateTime(2026, 5, 30, 15),
    endLocal: DateTime(2026, 5, 30, 16, 30),
    capacity: capacity,
    repository: _FakeRepo(players),
  );
  await tester.pumpAndSettle();
}

SlotPlayer _p(
  String id, {
  required String name,
  PaymentStatus pay = PaymentStatus.unpaid,
  BookingStatus status = BookingStatus.confirmed,
}) =>
    SlotPlayer(id: id, name: name, paymentStatus: pay, bookingStatus: status);

void main() {
  testWidgets('renders count vs capacity and player rows', (tester) async {
    await _open(tester, [
      _p('1', name: 'An', pay: PaymentStatus.paid),
      _p('2', name: 'Bình', pay: PaymentStatus.unpaid),
      _p('3', name: 'Chi', pay: PaymentStatus.partial),
    ]);

    expect(find.text('3/4 người chơi'), findsOneWidget);
    expect(find.text('An'), findsOneWidget);
    expect(find.text('Bình'), findsOneWidget);
    expect(find.text('Chi'), findsOneWidget);
    // All three payment states render distinctly (paid / partial / unpaid).
    expect(find.text('Đã thanh toán'), findsOneWidget);
    expect(find.text('Thanh toán một phần'), findsOneWidget);
    expect(find.text('Chưa thanh toán'), findsOneWidget);
  });

  testWidgets('paid players are visually distinguished from unpaid',
      (tester) async {
    await _open(tester, [
      _p('1', name: 'An', pay: PaymentStatus.paid),
      _p('2', name: 'Bình', pay: PaymentStatus.unpaid),
    ]);

    // The paid chip says "Đã thanh toán"; the unpaid one "Chưa thanh toán".
    expect(find.text('Đã thanh toán'), findsOneWidget);
    expect(find.text('Chưa thanh toán'), findsOneWidget);
  });

  testWidgets('empty roster shows the empty state', (tester) async {
    await _open(tester, const []);
    expect(find.text('0/4 người chơi'), findsOneWidget);
    expect(find.text('Chưa có người chơi nào trong khung giờ này.'),
        findsOneWidget);
  });

  testWidgets('count drops the denominator when capacity is unknown',
      (tester) async {
    await _open(tester, [_p('1', name: 'An')], capacity: null);
    expect(find.text('1 người chơi'), findsOneWidget);
  });
}
