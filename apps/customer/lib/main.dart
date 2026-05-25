// Bootstrap entry-point for the SportBuddies customer Flutter app.
//
// Init order (per tech-plan §9.2):
//   WidgetsFlutterBinding.ensureInitialized()
//   → Firebase.initializeApp()
//   → Supabase.initialize()
//   → SharedPreferences.getInstance()
//   → configureDependencies(prefs)
//   → runApp(CustomerApp())

import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase, Supabase, DI init will be wired in subsequent sub-tasks.
  runApp(const CustomerApp());
}

/// Root widget for the SportBuddies customer app.
///
/// Wires:
///  - [AppLocalizations] for i18n (vi default, en supported)
///  - [MaterialApp.router] placeholder (router added in grava-35d5.6)
class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'SportBuddies',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('vi'),
      home: Scaffold(
        body: Center(
          child: Text('SportBuddies — bootstrap OK'),
        ),
      ),
    );
  }
}
