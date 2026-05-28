import 'package:dashboard/core/di/injection.dart';
import 'package:dashboard/features/auth/bloc/auth_bloc.dart';
import 'package:dashboard/features/auth/view/forgot_password_screen.dart';
import 'package:dashboard/features/auth/view/login_screen.dart';
import 'package:dashboard/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

GoRouter buildRouter() {
  const publicPaths = {'/login', '/forgot-password'};

  AuthBloc createAuthBloc() {
    SupabaseClient? client;
    try {
      client = Supabase.instance.client;
    } catch (_) {}
    return AuthBloc(supabaseClient: client);
  }

  return GoRouter(
    navigatorKey: sl<GlobalKey<NavigatorState>>(),
    initialLocation: '/',
    redirect: (context, state) {
      Session? session;
      try {
        session = Supabase.instance.client.auth.currentSession;
      } catch (_) {}

      final authed = session != null;
      final going = state.matchedLocation;

      if (!authed && !publicPaths.contains(going)) return '/login';
      if (authed && going == '/login') return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AppShell(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => BlocProvider(
          create: (_) => createAuthBloc()..add(const AuthEvent.appStarted()),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => BlocProvider(
          create: (_) => createAuthBloc(),
          child: const ForgotPasswordScreen(),
        ),
      ),
    ],
  );
}
