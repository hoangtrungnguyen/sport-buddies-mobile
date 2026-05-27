import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'app_locale';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._prefs)
      : super(Locale(_prefs.getString(_kLocaleKey) ?? 'vi'));

  final SharedPreferences _prefs;

  void setLocale(Locale locale) {
    _prefs.setString(_kLocaleKey, locale.languageCode);
    emit(locale);
  }

  void toggleLocale() {
    final next = state.languageCode == 'vi' ? const Locale('en') : const Locale('vi');
    setLocale(next);
  }
}
