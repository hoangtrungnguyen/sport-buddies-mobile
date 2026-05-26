// Widget tests for ProfileScreen.
//
// Covers:
//   - Loading state is shown while cubit emits ProfileLoading.
//   - Loaded state renders avatar, full_name, phone, email fields.
//   - ProfileScreen is accessible via the /profile route.

import 'package:customer/features/profile/profile_cubit.dart';
import 'package:customer/features/profile/profile_screen.dart';
import 'package:customer/features/profile/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Minimal fake cubit — avoids real Supabase calls in tests.
//
// Overrides loadProfile() with a no-op so ProfileScreen.initState() does not
// alter the pre-seeded initial state.
// ---------------------------------------------------------------------------
class _FakeCubit extends ProfileCubit {
  _FakeCubit(super.initial) : super.fake();

  @override
  Future<void> loadProfile() async {
    // no-op: state is pre-seeded by the test.
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
Widget _buildSubject(ProfileCubit cubit) {
  return MaterialApp(
    home: BlocProvider<ProfileCubit>.value(
      value: cubit,
      child: const ProfileScreen(),
    ),
  );
}

void main() {
  group('ProfileScreen', () {
    testWidgets('shows a loading indicator while ProfileLoading', (tester) async {
      final cubit = _FakeCubit(const ProfileLoading());
      addTearDown(cubit.close);

      await tester.pumpWidget(_buildSubject(cubit));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders full_name when ProfileLoaded', (tester) async {
      final cubit = _FakeCubit(
        const ProfileLoaded(
          fullName: 'Nguyen Van A',
          phone: '0901234567',
          email: 'vana@example.com',
          avatarUrl: null,
        ),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(_buildSubject(cubit));
      await tester.pump();

      expect(find.text('Nguyen Van A'), findsOneWidget);
    });

    testWidgets('renders phone when ProfileLoaded', (tester) async {
      final cubit = _FakeCubit(
        const ProfileLoaded(
          fullName: 'Nguyen Van A',
          phone: '0901234567',
          email: 'vana@example.com',
          avatarUrl: null,
        ),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(_buildSubject(cubit));
      await tester.pump();

      expect(find.text('0901234567'), findsOneWidget);
    });

    testWidgets('renders email (read-only) when ProfileLoaded', (tester) async {
      final cubit = _FakeCubit(
        const ProfileLoaded(
          fullName: 'Nguyen Van A',
          phone: '0901234567',
          email: 'vana@example.com',
          avatarUrl: null,
        ),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(_buildSubject(cubit));
      await tester.pump();

      expect(find.text('vana@example.com'), findsOneWidget);
    });

    testWidgets('renders CircleAvatar when ProfileLoaded', (tester) async {
      final cubit = _FakeCubit(
        const ProfileLoaded(
          fullName: 'Nguyen Van A',
          phone: '0901234567',
          email: 'vana@example.com',
          avatarUrl: null,
        ),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(_buildSubject(cubit));
      await tester.pump();

      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('shows error message on ProfileError', (tester) async {
      final cubit = _FakeCubit(
        const ProfileError('Something went wrong'),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(_buildSubject(cubit));
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });

  group('/profile route', () {
    testWidgets('ProfileScreen widget mounts successfully as a route',
        (tester) async {
      final cubit = _FakeCubit(
        const ProfileLoaded(
          fullName: 'Test User',
          phone: '0909090909',
          email: 'test@example.com',
          avatarUrl: null,
        ),
      );
      addTearDown(cubit.close);

      // We test via BlocProvider.value rather than real router to keep the
      // test hermetic. The router integration test lives in app_router_test.dart.
      await tester.pumpWidget(_buildSubject(cubit));
      await tester.pump();

      expect(find.byType(ProfileScreen), findsOneWidget);
    });
  });
}
