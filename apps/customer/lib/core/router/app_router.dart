// GoRouter configuration — bootstrap skeleton.
//
// Tech-plan §5 — placeholder routes only.
// Feature routes (booking, profile, map, etc.) land in their own CAPP stories.
//
// DI wiring: registered as Singleton in RegisterModule (injection_module.dart)
// so that FCM handlers outside the widget tree can call `sl<GoRouter>().go(...)`.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Builds and returns the application [GoRouter].
///
/// Exposed as a top-level function (not a class) so [RegisterModule] can call
/// it with `GoRouter get goRouter => buildRouter()` without creating a
/// circular dependency on a class that imports the DI container.
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // TODO(CAPP-010): wire supabase.auth.currentSession check here.
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
    ],
  );
}

/// Placeholder home screen.
///
/// Shows a simple confirmation that the Flutter bootstrap succeeded.
/// Replaced by the real [HomeScreen] when CAPP-002 lands.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('SportBuddies — bootstrap OK'),
      ),
    );
  }
}

/// Placeholder login screen stub.
///
/// Replaced by the real [LoginScreen] when CAPP-010 lands.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Login (CAPP-010 stub)'),
      ),
    );
  }
}
