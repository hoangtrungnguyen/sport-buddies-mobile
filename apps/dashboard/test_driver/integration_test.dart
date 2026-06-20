import 'package:integration_test/integration_test_driver.dart';

/// Driver entry for `flutter drive` — runs the integration_test targets in a
/// real browser (web) or device. See scripts/web_e2e.sh.
Future<void> main() => integrationDriver();
