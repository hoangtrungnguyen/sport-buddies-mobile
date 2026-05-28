// Entry point for the SportBuddies Owner Dashboard.
//
// Bootstrap order:
//   1. WidgetsFlutterBinding.ensureInitialized()
//   2. Env.assertConfigured()
//   3. Supabase.initialize(...)
//   4. configureDependencies()   — registers GoRouter, DI graph
//   5. runApp(DashboardApp())
//
// Run with:
//   fvm flutter run \
//     --dart-define=SUPABASE_URL=http://localhost:54321 \
//     --dart-define=SUPABASE_ANON_KEY=<anon-key>

import 'package:dashboard/app.dart';
import 'package:dashboard/core/debug/app_bloc_observer.dart';
import 'package:dashboard/core/di/injection.dart';
import 'package:dashboard/core/env/env.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Held for the lifetime of the app so the semantics tree stays alive.
// ignore: unused_element
SemanticsHandle? _semanticsHandle;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Force-enable the semantics tree so automated agents (Puppeteer, Claude Code)
  // can interact with widgets via [aria-label] selectors without requiring
  // user to click "Enable accessibility".
  _semanticsHandle = RendererBinding.instance.ensureSemantics();

  final navigatorKey = GlobalKey<NavigatorState>();
  GetIt.instance.registerSingleton<GlobalKey<NavigatorState>>(navigatorKey);

  Bloc.observer = AppBlocObserver(navigatorKey: navigatorKey);

  try {
    Env.assertConfigured();
  } on StateError catch (e) {
    debugPrint(
      'FATAL: missing env vars — ${e.message}\n'
      'Pass them via --dart-define=KEY=value at run/build time.',
    );
    if (!kIsWeb) rethrow;
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  await configureDependencies();

  runApp(const DashboardApp());
}
