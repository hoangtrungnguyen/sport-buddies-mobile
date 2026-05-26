// Widget tests for BookingHistoryScreen.
//
// AC verified:
//   - Shows CircularProgressIndicator when BookingsLoading.
//   - Shows empty state text 'Không có lịch sử đặt sân' when BookingsLoaded([]).
//   - Shows BookingTile list when BookingsLoaded with entries.
//   - Shows error message when BookingsError.

import 'package:customer/features/bookings/booking_history_cubit.dart';
import 'package:customer/features/bookings/booking_history_screen.dart';
import 'package:customer/features/bookings/booking_model.dart';
import 'package:customer/features/bookings/bookings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake cubit to drive the screen from a pre-seeded state.
class _FakeHistoryCubit extends BookingHistoryCubit {
  _FakeHistoryCubit(super.initial) : super.fake();

  @override
  Future<void> loadHistory() async {
    // no-op: state pre-seeded.
  }
}

Widget _buildSubject(BookingHistoryCubit cubit) {
  return MaterialApp(
    home: BlocProvider<BookingHistoryCubit>.value(
      value: cubit,
      child: const BookingHistoryScreen(),
    ),
  );
}

void main() {
  group('BookingHistoryScreen', () {
    testWidgets('shows loading spinner for BookingsLoading', (tester) async {
      final cubit = _FakeHistoryCubit(const BookingsLoading());
      addTearDown(cubit.close);
      await tester.pumpWidget(_buildSubject(cubit));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty-state text for empty BookingsLoaded',
        (tester) async {
      final cubit = _FakeHistoryCubit(const BookingsLoaded([]));
      addTearDown(cubit.close);
      await tester.pumpWidget(_buildSubject(cubit));
      expect(find.text('Không có lịch sử đặt sân'), findsOneWidget);
    });

    testWidgets('shows BookingTile for each booking in list', (tester) async {
      const court = Court(id: 'c1', name: 'Sân Lịch Sử');
      final slot = Slot(
        id: 's1',
        startTime: DateTime(2026, 1, 10, 9, 0),
        endTime: DateTime(2026, 1, 10, 10, 0),
        court: court,
      );
      final booking = Booking(
        id: 'b1',
        userId: 'u1',
        status: 'completed',
        slot: slot,
      );
      final cubit = _FakeHistoryCubit(BookingsLoaded([booking]));
      addTearDown(cubit.close);
      await tester.pumpWidget(_buildSubject(cubit));
      expect(find.text('Sân Lịch Sử'), findsOneWidget);
    });

    testWidgets('shows error message for BookingsError', (tester) async {
      final cubit =
          _FakeHistoryCubit(const BookingsError('Lỗi kết nối'));
      addTearDown(cubit.close);
      await tester.pumpWidget(_buildSubject(cubit));
      expect(find.text('Lỗi kết nối'), findsOneWidget);
    });
  });
}
