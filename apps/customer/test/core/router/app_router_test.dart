// Tests for the GoRouter configuration (updated for grava-144f.1.2 forgot-password).
//
// The router exposes six routes:
//   /                  → HomePage
//   /login             → LoginScreen (CAPP-010)
//   /signup            → SignUpScreen (CAPP-010)
//   /forgot-password   → ForgotPasswordScreen (grava-144f.1.2)
//   /profile           → ProfileScreen (later story)
//   /map               → MapScreen (later story)
import 'package:customer/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('AppRouter — buildRouter()', () {
    test('returns a GoRouter instance', () {
      final router = buildRouter();
      expect(router, isA<GoRouter>());
    });

    test(
        'GoRouter contains routes for "/", "/login", "/signup", "/forgot-password", "/profile", and "/map"',
        () {
      final router = buildRouter();
      final routes = router.configuration.routes;
      final paths =
          routes.whereType<GoRoute>().map((r) => r.path).toList();
      expect(
        paths,
        containsAll([
          '/',
          '/login',
          '/signup',
          '/forgot-password',
          '/profile',
          '/map',
        ]),
      );
    });

    testWidgets('/ resolves to a widget that contains the bootstrap text',
        (WidgetTester tester) async {
      final router = buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(find.text('SportBuddies — bootstrap OK'), findsOneWidget);
    });

    testWidgets('/login resolves to a widget that shows "Sign in"',
        (WidgetTester tester) async {
      final router = buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.go('/login');
      await tester.pumpAndSettle();
      // "Sign in" appears in both the AppBar title and the submit button.
      expect(find.text('Sign in'), findsWidgets);
    });

    testWidgets('/signup resolves to a widget that shows "Create account"',
        (WidgetTester tester) async {
      final router = buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.go('/signup');
      await tester.pumpAndSettle();
      // "Create account" appears in both the AppBar title and the submit button.
      expect(find.text('Create account'), findsWidgets);
    });
  });

  group('HomePage widget', () {
    testWidgets('renders "SportBuddies — bootstrap OK"',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomePage()),
      );
      expect(find.text('SportBuddies — bootstrap OK'), findsOneWidget);
    });
  });
}
