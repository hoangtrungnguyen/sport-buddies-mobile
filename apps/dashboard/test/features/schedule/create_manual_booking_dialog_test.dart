import 'package:dashboard/features/schedule/bloc/schedule_bloc.dart';
import 'package:dashboard/features/schedule/model/manual_booking_result.dart';
import 'package:dashboard/features/schedule/model/owner_slot.dart';
import 'package:dashboard/features/schedule/repository/manual_booking_repository.dart';
import 'package:dashboard/features/schedule/repository/owner_slot_repository.dart';
import 'package:dashboard/features/schedule/view/create_manual_booking_dialog.dart';
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

class _SlotRepo implements OwnerSlotRepository {
  @override
  Future<List<OwnerSlot>> fetchWeekSlots({
    required String courtId,
    required DateTime weekStart,
  }) async =>
      const [];

  @override
  Future<OwnerSlot> createOwnerSlot({
    required String courtId,
    required DateTime startAt,
    required DateTime endAt,
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> blockSlot({required String slotId, String? reason}) async =>
      throw UnimplementedError();

  @override
  Future<void> unblockSlot({required String slotId}) async =>
      throw UnimplementedError();
}

class _BookingRepo implements ManualBookingRepository {
  _BookingRepo({this.throwCode});

  /// When set, every call raises a [ManualBookingException] with this code,
  /// simulating a server rejection (e.g. 'overlap').
  final String? throwCode;
  final List<Map<String, dynamic>> calls = [];

  @override
  Future<void> createManualBooking({
    required String courtId,
    required DateTime startAt,
    required DateTime endAt,
    String? customerName,
    String? customerPhone,
    String? notes,
    int? pricePerHourOverride,
  }) async {
    calls.add({'courtId': courtId, 'customerPhone': customerPhone});
    if (throwCode != null) throw ManualBookingException(throwCode!);
  }
}

Future<ScheduleBloc> _loadedBloc(_BookingRepo booking) async {
  final bloc = ScheduleBloc(
    slotRepository: _SlotRepo(),
    bookingRepository: booking,
    loadCourts: () async => [_court()],
    now: () => DateTime(2026, 5, 13, 9),
  );
  final loaded = bloc.stream.firstWhere((s) => s is ScheduleLoaded);
  bloc.add(const ScheduleEvent.started());
  await loaded;
  return bloc;
}

Finder _phoneField() => find.byWidgetPredicate(
      (w) =>
          w is TextField &&
          (w.decoration?.hintText?.startsWith('Số điện thoại') ?? false),
    );

Finder _nameField() => find.byWidgetPredicate(
      (w) => w is TextField && (w.decoration?.hintText == 'Tên khách'),
    );

Finder _submit() => find.widgetWithText(FilledButton, 'Xác nhận đặt sân');

Finder _cancel() => find.widgetWithText(OutlinedButton, 'Huỷ');

/// Pumps a host scaffold and opens the manual-booking dialog over [bloc].
Future<void> _open(WidgetTester tester, ScheduleBloc bloc) async {
  late BuildContext ctx;
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      }),
    ),
  ));
  showCreateManualBookingDialog(ctx, bloc: bloc);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders fields; phone validation gates submit; books on submit',
      (tester) async {
    final booking = _BookingRepo();
    final bloc = await _loadedBloc(booking);
    addTearDown(bloc.close);

    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(builder: (c) {
          ctx = c;
          return const SizedBox();
        }),
      ),
    ));

    final dialogResult = showCreateManualBookingDialog(ctx, bloc: bloc);
    await tester.pumpAndSettle();

    // Renders the walk-in form.
    expect(find.text('Đặt sân tại quầy'), findsOneWidget);
    expect(find.byType(DropdownButton<String>), findsOneWidget); // court picker
    expect(find.text('Tennis'), findsOneWidget); // sport auto-filled
    expect(_phoneField(), findsOneWidget);

    FilledButton submitBtn() => tester.widget<FilledButton>(_submit());

    // Invalid phone disables submit.
    await tester.enterText(_phoneField(), '123');
    await tester.pump();
    expect(find.text('Số điện thoại không hợp lệ.'), findsOneWidget);
    expect(submitBtn().onPressed, isNull);

    // A valid local number re-enables submit.
    await tester.enterText(_phoneField(), '0901234567');
    await tester.pump();
    expect(submitBtn().onPressed, isNotNull);

    await tester.ensureVisible(_submit()); // form scrolls in the 800px viewport
    await tester.pumpAndSettle();
    await tester.tap(_submit());
    await tester.pumpAndSettle();

    // Dialog closed, returned the confirmed booking to the caller, dispatched
    // the booking with a normalized phone, and cleared the transient result.
    expect(find.text('Đặt sân tại quầy'), findsNothing);
    expect(await dialogResult, isA<ManualBookingSucceeded>());
    expect((bloc.state as ScheduleLoaded).bookingResult, isNull);
    expect(booking.calls, hasLength(1));
    expect(booking.calls.single['customerPhone'], '+84901234567');
  });

  testWidgets('reopening after a success does not auto-close on a stale result',
      (tester) async {
    final bloc = await _loadedBloc(_BookingRepo());
    addTearDown(bloc.close);

    // First booking: submit → success → dialog closes, result cleared.
    await _open(tester, bloc);
    await tester.enterText(_phoneField(), '0901234567');
    await tester.pump();
    await tester.ensureVisible(_submit());
    await tester.tap(_submit());
    await tester.pumpAndSettle();
    expect(find.text('Đặt sân tại quầy'), findsNothing);
    expect((bloc.state as ScheduleLoaded).bookingResult, isNull);

    // Reopen: the (now-cleared) result must NOT re-trigger a pop.
    await _open(tester, bloc);
    await tester.pumpAndSettle();
    expect(find.text('Đặt sân tại quầy'), findsOneWidget);
  });

  testWidgets('system back triggers the dirty-guard when the form is dirty',
      (tester) async {
    final bloc = await _loadedBloc(_BookingRepo());
    addTearDown(bloc.close);
    await _open(tester, bloc);

    await tester.enterText(_nameField(), 'Minh'); // dirty
    await tester.pump();

    // Simulate the OS back gesture / Esc — routed through PopScope.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Huỷ đặt sân?'), findsOneWidget);
  });

  testWidgets('Huỷ on a pristine form closes immediately, no confirmation',
      (tester) async {
    final bloc = await _loadedBloc(_BookingRepo());
    addTearDown(bloc.close);
    await _open(tester, bloc);

    expect(find.text('Đặt sân tại quầy'), findsOneWidget);
    await tester.ensureVisible(_cancel());
    await tester.tap(_cancel());
    await tester.pumpAndSettle();

    // No "Huỷ đặt sân?" prompt — closes straight away.
    expect(find.text('Huỷ đặt sân?'), findsNothing);
    expect(find.text('Đặt sân tại quầy'), findsNothing);
  });

  testWidgets('Huỷ after editing confirms; keep-editing stays, discard closes',
      (tester) async {
    final bloc = await _loadedBloc(_BookingRepo());
    addTearDown(bloc.close);
    await _open(tester, bloc);

    await tester.enterText(_nameField(), 'Minh'); // form is now dirty
    await tester.pump();

    await tester.ensureVisible(_cancel());
    await tester.tap(_cancel());
    await tester.pumpAndSettle();
    expect(find.text('Huỷ đặt sân?'), findsOneWidget); // confirmation appears

    // "Tiếp tục nhập" dismisses the prompt and keeps the form.
    await tester.tap(find.text('Tiếp tục nhập'));
    await tester.pumpAndSettle();
    expect(find.text('Huỷ đặt sân?'), findsNothing);
    expect(find.text('Đặt sân tại quầy'), findsOneWidget);

    // "Huỷ bỏ" discards and closes the form.
    await tester.ensureVisible(_cancel());
    await tester.tap(_cancel());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Huỷ bỏ'));
    await tester.pumpAndSettle();
    expect(find.text('Đặt sân tại quầy'), findsNothing);
  });

  testWidgets('the ✕ close button also confirms when the form is dirty',
      (tester) async {
    final bloc = await _loadedBloc(_BookingRepo());
    addTearDown(bloc.close);
    await _open(tester, bloc);

    await tester.enterText(_nameField(), 'Lan');
    await tester.pump();

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Huỷ đặt sân?'), findsOneWidget);
  });

  testWidgets('a server rejection keeps the dialog open with an inline error',
      (tester) async {
    final booking = _BookingRepo(throwCode: 'overlap');
    final bloc = await _loadedBloc(booking);
    addTearDown(bloc.close);
    await _open(tester, bloc);

    await tester.enterText(_phoneField(), '0901234567');
    await tester.pump();
    await tester.ensureVisible(_submit());
    await tester.tap(_submit());
    await tester.pumpAndSettle();

    // Dialog stays open; the localized reason shows inline; retry is possible.
    expect(find.text('Đặt sân tại quầy'), findsOneWidget);
    expect(find.textContaining('đã có người đặt'), findsOneWidget);
    expect(booking.calls, hasLength(1));
  });
}
