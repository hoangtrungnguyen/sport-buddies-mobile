import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'locale';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._prefs)
      : super(_resolveInitialLocale(_prefs));

  final SharedPreferences _prefs;

  static Locale _resolveInitialLocale(SharedPreferences prefs) {
    final saved = prefs.getString(_kLocaleKey);
    if (saved != null) {
      return Locale(saved);
    }
    final deviceLang = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    if (deviceLang == 'vi' || deviceLang == 'en') {
      return Locale(deviceLang);
    }
    return const Locale('vi');
  }

  void setLocale(Locale locale) {
    _prefs.setString(_kLocaleKey, locale.languageCode);
    emit(locale);
  }

  void toggleLocale() {
    final next = state.languageCode == 'vi' ? const Locale('en') : const Locale('vi');
    setLocale(next);
  }
}
