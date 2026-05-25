// DI entry-point.
//
// Usage (called once in main.dart after all platform services are ready):
//
//   await configureDependencies(prefs);
//
// Rule §6.2: Widgets NEVER call sl<T>() directly.
// BLoCs are provided to the widget tree via BlocProvider in the router builder.
// Only this file and the router setup file are allowed to reference `sl`.

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'injection.config.dart';

/// Global service locator.
final GetIt sl = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies(SharedPreferences prefs) async {
  // Register SharedPreferences as a singleton with the pre-resolved instance.
  // It is awaited in main.dart before runApp() and passed in here, ensuring
  // the async init order: Firebase → Supabase → prefs → DI → runApp.
  sl.registerSingleton<SharedPreferences>(prefs);

  sl.init();
}
