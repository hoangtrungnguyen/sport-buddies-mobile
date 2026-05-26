// Smoke test for grava-35d5.10.
//
// Verifies that CustomerApp builds and renders without throwing, using a
// lightweight DI override so the test runs fully offline:
//
//   - SharedPreferences: seeded via setMockInitialValues (no platform channel)
//   - SupabaseClient: not required by CustomerApp directly; the DI container
//     registers it from Supabase.instance, which throws in test environments.
//     We bypass this by registering a stub GoRouter directly in sl, which is
//     the only DI dependency that CustomerApp.build() actually reads.
//   - GoRouter: built from buildRouter() — the router factory itself is pure
//     Dart (no network calls). Supabase is only referenced inside the /profile
//     route builder, which is never invoked during this test.
//
// The test confirms:
//   1. CustomerApp() pumpWidget does not throw.
//   2. The initial route (/) renders 'SportBuddies — bootstrap OK'.

import 'package:customer/app.dart';
import 'package:customer/core/di/injection.dart';
import 'package:customer/core/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    // Reset the GetIt container before each test to avoid "already registered"
    // errors when the test suite runs alongside injection_test.dart.
    await sl.reset();

    // Seed SharedPreferences with an empty store so platform-channel calls
    // do not hit real storage.
    SharedPreferences.setMockInitialValues({});

    // Register only the singleton that CustomerApp.build() consumes: GoRouter.
    // buildRouter() is a pure-Dart factory — it does not call Supabase or any
    // async platform service, so it is safe to call directly in tests.
    sl.registerSingleton<GoRouter>(buildRouter());
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('CustomerApp builds without throwing', (tester) async {
    await tester.pumpWidget(const CustomerApp());
    await tester.pumpAndSettle();

    expect(find.text('SportBuddies — bootstrap OK'), findsOneWidget);
  });
}
