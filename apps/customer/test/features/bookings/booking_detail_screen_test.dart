// Widget tests for BookingDetailScreen.
//
// AC verified:
//   1. Shows CircularProgressIndicator on BookingDetailLoading state.
//   2. Shows empty state text 'Chưa có yêu cầu tham gia' when joinRequests is empty.
//   3. Shows join request user name when list is non-empty.
//   4. Shows avatar initials for each join request (first letter of name).
//   5. Shows error message on BookingDetailError state.

import 'package:customer/features/bookings/booking_detail_cubit.dart';
import 'package:customer/features/bookings/booking_detail_screen.dart';
import 'package:customer/features/bookings/booking_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildTestWidget(BookingDetailCubit cubit) {
  return MaterialApp(
    home: BlocProvider<BookingDetailCubit>.value(
      value: cubit,
      child: const BookingDetailScreen(),
    ),
  );
}

void main() {
  group('BookingDetailScreen', () {
    testWidgets('shows loading indicator on BookingDetailLoading', (tester) async {
      final cubit = BookingDetailCubit.fake(const BookingDetailLoading());
      addTearDown(cubit.close);
      await tester.pumpWidget(_buildTestWidget(cubit));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when join requests list is empty', (tester) async {
      final cubit = BookingDetailCubit.fake(
        const BookingDetailLoaded(booking: null, joinRequests: []),
      );
      addTearDown(cubit.close);
      await tester.pumpWidget(_buildTestWidget(cubit));
      expect(find.text('Chưa có yêu cầu tham gia'), findsOneWidget);
    });

    testWidgets('shows join request user name when list is non-empty', (tester) async {
      const requests = [
        JoinRequest(
          id: 'jr1',
          slotId: 's1',
          userId: 'u1',
          status: 'pending',
          userName: 'Nguyen Van A',
          avatarUrl: null,
          createdAt: '2026-05-26T08:00:00Z',
        ),
      ];
      final cubit = BookingDetailCubit.fake(
        const BookingDetailLoaded(booking: null, joinRequests: requests),
      );
      addTearDown(cubit.close);
      await tester.pumpWidget(_buildTestWidget(cubit));
      expect(find.text('Nguyen Van A'), findsOneWidget);
    });

    testWidgets('shows avatar initials for join request', (tester) async {
      const requests = [
        JoinRequest(
          id: 'jr1',
          slotId: 's1',
          userId: 'u1',
          status: 'pending',
          userName: 'Tran Thi B',
          avatarUrl: null,
          createdAt: '2026-05-26T08:00:00Z',
        ),
      ];
      final cubit = BookingDetailCubit.fake(
        const BookingDetailLoaded(booking: null, joinRequests: requests),
      );
      addTearDown(cubit.close);
      await tester.pumpWidget(_buildTestWidget(cubit));
      // Avatar initials — first character 'T'
      expect(find.text('T'), findsOneWidget);
    });

    testWidgets('shows error message on BookingDetailError', (tester) async {
      final cubit = BookingDetailCubit.fake(
        const BookingDetailError('Something went wrong'),
      );
      addTearDown(cubit.close);
      await tester.pumpWidget(_buildTestWidget(cubit));
      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });
}
