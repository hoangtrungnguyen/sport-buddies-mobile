// AppColors lives in spb_core but uses dart:ui Color, which requires the
// Flutter engine. Tests using Color assertions are in apps/customer/test/core/theme/.
// This file only verifies the constants can be resolved (compile-time check).

import 'dart:ui';

import 'package:spb_core/core/theme/app_colors.dart';
import 'package:test/test.dart';

void main() {
  group('AppColors — compile-time accessibility', () {
    test('AppColors constants are non-null Color values', () {
      // Verify all five constants exist and are Color instances.
      expect(AppColors.primary, isA<Color>());
      expect(AppColors.secondary, isA<Color>());
      expect(AppColors.surface, isA<Color>());
      expect(AppColors.background, isA<Color>());
      expect(AppColors.error, isA<Color>());
    });
  });
}
