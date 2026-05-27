import 'package:customer/core/l10n/locale_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocaleCubit', () {
    testWidgets('initializes with device locale when no saved preference exists', (tester) async {
      final prefs = await SharedPreferences.getInstance();

      // Case 1: Device locale is 'en'
      tester.platformDispatcher.localeTestValue = const Locale('en');
      final cubit1 = LocaleCubit(prefs);
      expect(cubit1.state.languageCode, 'en');
      await cubit1.close();

      // Case 2: Device locale is 'vi'
      tester.platformDispatcher.localeTestValue = const Locale('vi');
      final cubit2 = LocaleCubit(prefs);
      expect(cubit2.state.languageCode, 'vi');
      await cubit2.close();

      // Case 3: Device locale is not 'vi' or 'en' (e.g. 'fr') -> falls back to 'vi'
      tester.platformDispatcher.localeTestValue = const Locale('fr');
      final cubit3 = LocaleCubit(prefs);
      expect(cubit3.state.languageCode, 'vi');
      await cubit3.close();

      // Clear the test value override
      tester.platformDispatcher.clearLocaleTestValue();
    });

    test('initializes with saved preference if it exists', () async {
      SharedPreferences.setMockInitialValues({'locale': 'en'});
      final prefs = await SharedPreferences.getInstance();
      final cubit = LocaleCubit(prefs);
      expect(cubit.state.languageCode, 'en');
      await cubit.close();
    });

    test('setLocale persists selection and emits state', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = LocaleCubit(prefs);

      cubit.setLocale(const Locale('en'));
      expect(cubit.state.languageCode, 'en');
      expect(prefs.getString('locale'), 'en');

      cubit.setLocale(const Locale('vi'));
      expect(cubit.state.languageCode, 'vi');
      expect(prefs.getString('locale'), 'vi');

      await cubit.close();
    });

    test('toggleLocale toggles between vi and en', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = LocaleCubit(prefs);

      // Force vi initial state for testing toggle
      cubit.setLocale(const Locale('vi'));
      expect(cubit.state.languageCode, 'vi');

      cubit.toggleLocale();
      expect(cubit.state.languageCode, 'en');
      expect(prefs.getString('locale'), 'en');

      cubit.toggleLocale();
      expect(cubit.state.languageCode, 'vi');
      expect(prefs.getString('locale'), 'vi');

      await cubit.close();
    });
  });
}
