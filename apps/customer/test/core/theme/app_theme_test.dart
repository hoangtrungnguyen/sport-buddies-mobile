import 'package:customer/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spb_core/core/theme/app_colors.dart';

void main() {
  group('buildLightTheme()', () {
    late ThemeData theme;

    setUp(() {
      theme = buildLightTheme();
    });

    test('returns a ThemeData', () {
      expect(theme, isA<ThemeData>());
    });

    test('uses Material 3', () {
      expect(theme.useMaterial3, isTrue);
    });

    test('primary color matches AppColors.primary', () {
      expect(theme.colorScheme.primary, equals(AppColors.primary));
    });

    test('secondary color matches AppColors.secondary', () {
      expect(theme.colorScheme.secondary, equals(AppColors.secondary));
    });

    test('surface color matches AppColors.surface', () {
      expect(theme.colorScheme.surface, equals(AppColors.surface));
    });

    test('error color matches AppColors.error', () {
      expect(theme.colorScheme.error, equals(AppColors.error));
    });

    test('brightness is light', () {
      expect(theme.brightness, equals(Brightness.light));
    });
  });
}
