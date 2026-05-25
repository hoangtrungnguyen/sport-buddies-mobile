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

    test('GoRouter has exactly two routes: "/" and "/login"', () {
      final router = buildRouter();
      // GoRouter exposes its configuration; verify it has the two expected paths.
      final routes = router.configuration.routes;
      final paths = routes
          .whereType<GoRoute>()
          .map((r) => r.path)
          .toList();
      expect(paths, containsAll(['/', '/login']));
    });

    testWidgets('/ resolves to a widget that contains the bootstrap text',
        (WidgetTester tester) async {
      final router = buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(find.text('SportBuddies — bootstrap OK'), findsOneWidget);
    });

    testWidgets('/login resolves to a widget that contains the login stub text',
        (WidgetTester tester) async {
      final router = buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      // Navigate to /login.
      router.go('/login');
      await tester.pumpAndSettle();
      expect(find.text('Login (CAPP-010 stub)'), findsOneWidget);
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

  group('LoginPage widget', () {
    testWidgets('renders "Login (CAPP-010 stub)"',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginPage()),
      );
      expect(find.text('Login (CAPP-010 stub)'), findsOneWidget);
    });
  });
}
