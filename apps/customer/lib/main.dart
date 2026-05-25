// Entry point for the SportBuddies customer app.
//
// Bootstrap order (per tech-plan §9.2):
//   WidgetsFlutterBinding.ensureInitialized   [this task — placeholder]
//   → Firebase.initializeApp                  [grava-35d5.9]
//   → Supabase.initialize                     [grava-35d5.5]
//   → SharedPreferences.getInstance           [grava-35d5.4]
//   → configureDependencies(prefs)            [grava-35d5.7]
//   → runApp(CustomerApp())                   [this task]
//
// Theme and router are wired inside CustomerApp (grava-35d5.8).

import 'package:customer/app.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO(grava-35d5.9): Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
  // TODO(grava-35d5.5): Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey)
  // TODO(grava-35d5.4): final prefs = await SharedPreferences.getInstance()
  // TODO(grava-35d5.7): await configureDependencies(prefs)
  runApp(const CustomerApp());
}
