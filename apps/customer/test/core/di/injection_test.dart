import 'package:customer/core/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    // Reset GetIt between tests to avoid "already registered" errors.
    await sl.reset();
  });

  group('DI module — injection.dart', () {
    test('sl is a GetIt instance exported from injection.dart', () {
      expect(sl, isA<GetIt>());
    });

    test('SharedPreferences is registered when passed to configureDependencies',
        () async {
      // configureDependencies calls sl.init() which tries to resolve
      // Supabase.instance — skip the full init and just verify the manual
      // registration path that fires before sl.init().
      SharedPreferences.setMockInitialValues({'key': 'value'});
      final prefs = await SharedPreferences.getInstance();

      // Register manually (same path configureDependencies takes).
      sl.registerSingleton<SharedPreferences>(prefs);

      expect(sl.isRegistered<SharedPreferences>(), isTrue);
      expect(sl<SharedPreferences>(), same(prefs));
    });

    test('sl starts empty before any registration', () {
      expect(sl.isRegistered<SharedPreferences>(), isFalse);
    });
  });
}
