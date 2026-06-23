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
import 'package:customer/core/services/logging_http_client.dart';
import 'package:customer/core/services/timeout_http_client.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_skill/flutter_skill.dart';

Future<void> main() async {
  if (kDebugMode) {
    enableFlutterDriverExtension();
    FlutterSkillBinding.ensureInitialized();
  }
  // Step 1: ensure Flutter bindings are ready before any platform channel call.
  WidgetsFlutterBinding.ensureInitialized();

  // Create the root navigator key before DI so both AppBlocObserver and
  // GoRouter share the same key instance.
  final navigatorKey = GlobalKey<NavigatorState>();
  GetIt.instance.registerSingleton<GlobalKey<NavigatorState>>(navigatorKey);

  Bloc.observer = AppBlocObserver(navigatorKey: navigatorKey);

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
    // Bound all Supabase traffic (reads/auth/storage) by 30s so a hung
    // backend fails fast instead of hanging the UI, and log each call
    // (debug-only) so the API trace is visible in the console. Logging wraps
    // the timeout so timed-out requests are reported immediately.
    httpClient: LoggingHttpClient(TimeoutHttpClient(http.Client())),
  );

  // Step 4: resolve SharedPreferences before the DI container starts.
  final prefs = await SharedPreferences.getInstance();

  // Step 5: wire the DI graph (registers Supabase client, GoRouter, prefs).
  await configureDependencies(prefs);

  // Step 6: hand off to the root widget.
  runApp(const CustomerApp());
}
