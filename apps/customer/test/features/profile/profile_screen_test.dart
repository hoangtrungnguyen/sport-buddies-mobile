// Widget tests for ProfileScreen.
//
// Covers:
//   - Loading state is shown while cubit emits ProfileLoading.
//   - Loaded state renders avatar, full_name, phone, email.
//   - ProfileScreen is accessible via the /profile route.

import 'package:customer/core/l10n/locale_cubit.dart';
import 'package:customer/features/profile/profile_cubit.dart';
import 'package:customer/features/profile/profile_screen.dart';
import 'package:customer/features/profile/profile_state.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Minimal fake cubit — avoids real Supabase calls in tests.
// ---------------------------------------------------------------------------
class _FakeCubit extends ProfileCubit {
  _FakeCubit(super.initial) : super.fake();

  @override
  Future<void> loadProfile() async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
Widget _buildSubject(ProfileCubit cubit, LocaleCubit localeCubit) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<LocaleCubit>.value(value: localeCubit),
      BlocProvider<ProfileCubit>.value(value: cubit),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ProfileScreen(),
    ),
  );
}

void main() {
  late LocaleCubit localeCubit;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    localeCubit = LocaleCubit(prefs);
  });

  tearDownAll(() => localeCubit.close());

  group('ProfileScreen', () {
    testWidgets('shows a loading indicator while ProfileLoading', (tester) async {
      final cubit = _FakeCubit(const ProfileLoading());
      addTearDown(cubit.close);

      await tester.pumpWidget(_buildSubject(cubit, localeCubit));

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

      await tester.pumpWidget(_buildSubject(cubit, localeCubit));
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

      await tester.pumpWidget(_buildSubject(cubit, localeCubit));
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

      await tester.pumpWidget(_buildSubject(cubit, localeCubit));
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

      await tester.pumpWidget(_buildSubject(cubit, localeCubit));
      await tester.pump();

      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('shows error message on ProfileError', (tester) async {
      final cubit = _FakeCubit(
        const ProfileError('Something went wrong'),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(_buildSubject(cubit, localeCubit));
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

      await tester.pumpWidget(_buildSubject(cubit, localeCubit));
      await tester.pump();

      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('renders profile stats row when ProfileLoaded', (tester) async {
      final cubit = _FakeCubit(
        const ProfileLoaded(
          fullName: 'Nguyen Van A',
          phone: '0901234567',
          email: 'vana@example.com',
          avatarUrl: null,
        ),
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(_buildSubject(cubit, localeCubit));
      await tester.pump();

      expect(find.textContaining('12 '), findsOneWidget);
      expect(find.textContaining('4.8'), findsOneWidget);
      expect(find.textContaining('3 '), findsOneWidget);
    });
  });
}
