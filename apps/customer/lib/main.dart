// Entry point for the SportBuddies customer app.
//
// Bootstrap order (tech-plan §9.2):
//   1. WidgetsFlutterBinding.ensureInitialized()
//   2. Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
//   3. Env.assertConfigured()          ← fail-fast before secrets are used
//   4. Supabase.initialize(...)
//   5. SharedPreferences.getInstance()
//   6. configureDependencies(prefs)
//   7. runApp(CustomerApp())

import 'dart:io' show exit;

import 'package:customer/app.dart';
import 'package:customer/core/di/injection.dart';
import 'package:customer/core/env/env.dart';
import 'package:customer/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Step 1: ensure Flutter bindings are ready before any platform channel call.
  WidgetsFlutterBinding.ensureInitialized();

  // Step 2: initialise Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Step 3: fail fast if compile-time env vars are missing.
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

  // Step 4: initialise Supabase (URL and anon key are now guaranteed non-empty).
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

  // Step 5: resolve SharedPreferences before the DI container starts.
  final prefs = await SharedPreferences.getInstance();

  // Step 6: wire the DI graph (registers Supabase client, GoRouter, prefs).
  await configureDependencies(prefs);

  // Step 7: hand off to the root widget.
  runApp(const CustomerApp());
}
