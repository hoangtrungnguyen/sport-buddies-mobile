// GoRouter configuration — CAPP-010 screens wired.
//
// Routes:
//   /         → HomePage (map placeholder — replaced by real map screen in
//               a future CAPP story)
//   /login    → LoginScreen (CAPP-010)
//   /signup   → SignUpScreen (CAPP-010)
//
// DI wiring: registered as Singleton in RegisterModule (injection_module.dart)
// so that FCM handlers outside the widget tree can call `sl<GoRouter>().go(...)`.

import 'package:customer/features/auth/bloc/auth_bloc.dart';
import 'package:customer/features/auth/view/forgot_password_screen.dart';
import 'package:customer/features/auth/view/login_screen.dart';
import 'package:customer/features/auth/view/sign_up_screen.dart';
import 'package:customer/features/map/map_screen.dart';
import 'package:customer/features/profile/profile_cubit.dart';
import 'package:customer/features/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Builds and returns the application [GoRouter].
///
/// Redirect logic (grava-144f.1.4):
///   - Unauthenticated users landing on any route other than [/login] or
///     [/signup] are sent to [/login].
///   - Authenticated users landing on [/login] or [/signup] are sent to [/].
///   - All other combinations return `null` (no redirect).
GoRouter buildRouter() {
  // Routes that are always accessible without a session.
  const publicPaths = {'/login', '/signup'};

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Guard: Supabase.instance throws if not yet initialised (e.g. tests).
      // In that case, treat as unauthenticated so public routes remain accessible.
      Session? session;
      try {
        session = Supabase.instance.client.auth.currentSession;
      } catch (_) {
        session = null;
      }

      final isAuthenticated = session != null;
      final goingTo = state.matchedLocation;

      if (!isAuthenticated && !publicPaths.contains(goingTo)) {
        return '/login';
      }
      if (isAuthenticated && publicPaths.contains(goingTo)) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => BlocProvider(
          create: (_) => AuthBloc(),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => BlocProvider(
          create: (_) => AuthBloc(),
          child: const SignUpScreen(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => BlocProvider(
          create: (_) => AuthBloc(),
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => BlocProvider(
          create: (_) => ProfileCubit(Supabase.instance.client),
          child: const ProfileScreen(),
        ),
      ),
      // grava-c9ca.1.1: Map screen — CAPP-030
      GoRoute(
        path: '/map',
        builder: (context, state) => const MapScreen(),
      ),
    ],
  );
}

/// Placeholder home screen.
///
/// Shows a simple confirmation that the Flutter bootstrap succeeded.
/// Replaced by the real map/home screen when the map story lands.
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
