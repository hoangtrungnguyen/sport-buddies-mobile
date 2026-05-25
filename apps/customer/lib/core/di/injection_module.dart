// RegisterModule provides third-party/external singletons to the DI container.
//
// These are objects whose constructors we don't own, so they cannot be
// annotated with @singleton directly — instead we expose them via a
// @module abstract class with factory-getters.

import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@module
abstract class RegisterModule {
  /// The Supabase client used by all data sources.
  /// Data sources receive it via constructor injection — they never call
  /// `Supabase.instance.client` directly (§6.1).
  @singleton
  SupabaseClient get supabaseClient => Supabase.instance.client;

  /// GoRouter singleton — allows FCM handler (outside widget tree) to navigate.
  /// TODO(grava-35d5.6): replace stub with real AppRouter once task 6 lands.
  @singleton
  GoRouter get goRouter => GoRouter(routes: const []);
}
