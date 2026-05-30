import 'package:dashboard/features/schedule/bloc/schedule_bloc.dart';
import 'package:dashboard/features/schedule/model/owner_slot.dart';
import 'package:dashboard/features/schedule/repository/manual_booking_repository.dart';
import 'package:dashboard/features/schedule/repository/owner_slot_repository.dart';
import 'package:dashboard/features/schedule/view/slot_actions_dialog.dart';
import 'package:dashboard/features/setup/model/owner_court.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

OwnerCourt _court() => const OwnerCourt(
      id: 'c1',
      name: 'Sân 1',
      sportTypes: ['Tennis'],
      capacity: 4,
      openHour: 6,
      closeHour: 22,
      pricePerHour: 100000,
      isActive: true,
    );

OwnerSlot _slot(String status, {String? reason}) => OwnerSlot(
      id: 's1',
      courtId: 'c1',
      startAt: DateTime(2026, 5, 14, 8),
      endAt: DateTime(2026, 5, 14, 9),
      status: status,
      blockedReason: reason,
    );

/// Recording [OwnerSlotRepository] — fetch returns a fixed list; block/unblock
/// just log their args.
class _RecordingSlotRepo implements OwnerSlotRepository {
  final List<Map<String, dynamic>> blockCalls = [];
  final List<String> unblockCalls = [];

  @override
  Future<List<OwnerSlot>> fetchWeekSlots({
    required String courtId,
    required DateTime weekStart,
  }) async =>
      [_slot(SlotStatus.open)];

  @override
  Future<OwnerSlot> createOwnerSlot({
    required String courtId,
    required DateTime startAt,
    required DateTime endAt,
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> blockSlot({required String slotId, String? reason}) async =>
      blockCalls.add({'slotId': slotId, 'reason': reason});

  @override
  Future<void> unblockSlot({required String slotId}) async =>
      unblockCalls.add(slotId);
}

class _NoopBookingRepo implements ManualBookingRepository {
  @override
  Future<void> createManualBooking({
    required String courtId,
    required DateTime startAt,
    required DateTime endAt,
    String? customerName,
    String? customerPhone,
    String? notes,
    int? pricePerHourOverride,
  }) async {}
}

Future<(ScheduleBloc, _RecordingSlotRepo)> _loadedBloc() async {
  final repo = _RecordingSlotRepo();
  final bloc = ScheduleBloc(
    slotRepository: repo,
    bookingRepository: _NoopBookingRepo(),
    loadCourts: () async => [_court()],
    now: () => DateTime(2026, 5, 13, 9),
  );
  final loaded = bloc.stream.firstWhere((s) => s is ScheduleLoaded);
  bloc.add(const ScheduleEvent.started());
  await loaded;
  return (bloc, repo);
}

Future<void> _open(WidgetTester tester, ScheduleBloc bloc, OwnerSlot slot) async {
  late BuildContext ctx;
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(body: Builder(builder: (c) {
      ctx = c;
      return const SizedBox();
    })),
  ));
  showSlotActionsDialog(ctx, bloc: bloc, slot: slot);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('open slot: Khoá giờ with a reason dispatches a block',
      (tester) async {
    final (bloc, repo) = await _loadedBloc();
    addTearDown(bloc.close);
    await _open(tester, bloc, _slot(SlotStatus.open));

    expect(find.text('Khoá khung giờ'), findsOneWidget);
    // (FilledButton.icon / the wrapped TextField are private subtypes, so match
    // by the single TextField + the button label text.)
    await tester.enterText(find.byType(TextField), 'Bảo trì sân');
    await tester.tap(find.text('Khoá giờ'));
    await tester.pumpAndSettle();

    expect(repo.blockCalls.single, {'slotId': 's1', 'reason': 'Bảo trì sân'});
  });

  testWidgets('blocked slot: shows the reason and unblocks', (tester) async {
    final (bloc, repo) = await _loadedBloc();
    addTearDown(bloc.close);
    await _open(tester, bloc, _slot(SlotStatus.blocked, reason: 'Sự kiện'));

    expect(find.textContaining('Sự kiện'), findsOneWidget); // reason shown
    await tester.tap(find.text('Bỏ khoá'));
    await tester.pumpAndSettle();

    expect(repo.unblockCalls.single, 's1');
    expect(repo.blockCalls, isEmpty);
  });

  testWidgets('booked slot: block is disabled with an error, no dispatch',
      (tester) async {
    final (bloc, repo) = await _loadedBloc();
    addTearDown(bloc.close);
    await _open(tester, bloc, _slot(SlotStatus.booked));

    expect(find.text('Không thể khoá khung giờ đã có khách đặt.'),
        findsOneWidget);
    // The block button is disabled → tapping its label does nothing.
    await tester.tap(find.text('Khoá giờ'));
    await tester.pumpAndSettle();
    expect(repo.blockCalls, isEmpty);
    expect(repo.unblockCalls, isEmpty);
  });
}
