// Entry point for the SportBuddies customer app.
//
// Bootstrap order:
//   1. WidgetsFlutterBinding.ensureInitialized()
//   2. Env.assertConfigured()          ← fail-fast before secrets are used
//   3. Supabase.initialize(...)
//   4. SharedPreferences.getInstance()
//   5. configureDependencies(prefs)
//   6. runApp(CustomerApp())

import 'dart:io' show exit;

import 'package:customer/app.dart';
import 'package:customer/core/debug/app_bloc_observer.dart';
import 'package:customer/core/di/injection.dart';
import 'package:customer/core/env/env.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Step 1: ensure Flutter bindings are ready before any platform channel call.
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const AppBlocObserver();

  // Step 2: fail fast if compile-time env vars are missing.
  // On failure we print a human-readable diagnostic then exit so the operator
  // does not have to wait for a cryptic downstream error at the first API call.
  try {
    Env.assertConfigured();
  } on StateError catch (e) {
    // ignore: avoid_print
    debugPrint(
      'FATAL: env misconfiguration — ${e.message}\n'
      'Pass the missing keys via --dart-define=<KEY>=<value> at build/run time.',
    );
    if (!kIsWeb) {
      exit(1);
    }
    // On web, `dart:io`'s exit() is not available; re-throw so Flutter's
    // error boundary renders the message instead of continuing silently.
    rethrow;
  }

  // Step 3: initialise Supabase (URL and anon key are now guaranteed non-empty).
  //
  // Session persistence (grava-144f.1.4):
  //   supabase_flutter ≥ 2.x uses SharedPreferencesLocalStorage by default
  //   when no custom `localStorage` is provided, so sessions survive app
  //   restarts without extra configuration.  We pass FlutterAuthClientOptions
  //   explicitly to document the intent and keep the option visible for future
  //   customisation (e.g. switching to a secure-storage backend).
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(),
  );

  // Step 4: resolve SharedPreferences before the DI container starts.
  final prefs = await SharedPreferences.getInstance();

  // Step 5: wire the DI graph (registers Supabase client, GoRouter, prefs).
  await configureDependencies(prefs);

  // Step 6: hand off to the root widget.
  runApp(const CustomerApp());
}
