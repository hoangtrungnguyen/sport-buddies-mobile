import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Driver entry for `flutter drive` — runs the integration_test targets in a
/// real browser (web) or device, and writes any screenshots a test captures
/// via `binding.takeScreenshot(name)` to `build/screenshots/{name}.png`.
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      final file = File('build/screenshots/$name.png');
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
  );
}
