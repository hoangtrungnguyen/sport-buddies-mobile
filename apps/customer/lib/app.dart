import 'package:customer/core/di/injection.dart';
import 'package:customer/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Root widget for the SportBuddies customer app.
///
/// Wires [MaterialApp.router] with:
/// - The Material 3 theme from [buildLightTheme] (colors from `spb_core`).
/// - The [GoRouter] singleton registered in the DI container.
///
/// Bootstrap order (in `main.dart`):
///   WidgetsFlutterBinding.ensureInitialized
///   → Firebase.initializeApp
///   → Supabase.initialize
///   → SharedPreferences.getInstance
///   → configureDependencies(prefs)
///   → runApp(CustomerApp())
class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = sl<GoRouter>();

    return MaterialApp.router(
      title: 'SportBuddies',
      theme: buildLightTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
