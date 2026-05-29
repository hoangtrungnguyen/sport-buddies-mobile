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
//     --dart-define=SUPABASE_PUBLISHABLE_KEY=<sb_publishable_...> \
//     --dart-define=API_BASE_URL=http://localhost:8010   # REST backend (Django)
//
// API_BASE_URL defaults to http://localhost:8010 for dev. A web *release* build
// MUST set it to an https:// URL (see the guard in main below) — credentials
// (signup/login) are otherwise sent in plaintext.

import 'package:dashboard/app.dart';
import 'package:dashboard/core/debug/app_bloc_observer.dart';
import 'package:dashboard/core/di/injection.dart';
import 'package:dashboard/core/env/env.dart';
import 'package:dashboard/features/auth/repository/owner_auth_repository.dart';
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

  // Fail closed: a web *release* build must never POST credentials (signup,
  // login) to a plaintext endpoint. Refuse to boot rather than leak them.
  // Debug + localhost dev and non-web targets are unaffected. Thrown outside
  // the swallowing try above so it actually halts startup.
  if (kIsWeb && !kDebugMode && !Env.apiBaseUrl.startsWith('https://')) {
    throw StateError(
      'Insecure API_BASE_URL "${Env.apiBaseUrl}" for a web release build. '
      'Rebuild with --dart-define=API_BASE_URL=https://<your-api-host>.',
    );
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseClientKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // DEV ONLY (--dart-define=BYPASS_AUTH=true): sign in with a fixed dev account
  // so the dashboard can be previewed without typing credentials. Non-fatal —
  // if it fails (backend unreachable / account missing) it boots to /login.
  if (Env.bypassAuth) {
    await _devAutoLogin();
  }

  await configureDependencies();

  runApp(const DashboardApp());
}

/// Signs in with the [Env.bypassEmail]/[Env.bypassPassword] dev account so a
/// `BYPASS_AUTH` preview lands on the authenticated shell with real data.
///
/// Uses the **same path as the real login**: the backend `/auth/owner/login`
/// endpoint (which validates the owner role and returns Supabase tokens), then
/// hydrates the Supabase session from those tokens. We do NOT call Supabase's
/// anon-key `signInWithPassword`. Swallows all errors — a failed dev login must
/// never block startup (the app simply boots to /login).
Future<void> _devAutoLogin() async {
  try {
    final auth = Supabase.instance.client.auth;
    if (auth.currentSession != null) return; // already signed in (persisted)
    final result = await OwnerAuthRepository().login(
      email: Env.bypassEmail,
      password: Env.bypassPassword,
    );
    await auth.setSession(result.refreshToken, accessToken: result.accessToken);
    debugPrint('BYPASS_AUTH: signed in as ${Env.bypassEmail}');
  } catch (e) {
    debugPrint(
      'BYPASS_AUTH: auto-login as ${Env.bypassEmail} failed ($e). '
      'Booting to /login. Check the backend (/auth/owner/login) is reachable '
      'and the account exists.',
    );
  }
}
