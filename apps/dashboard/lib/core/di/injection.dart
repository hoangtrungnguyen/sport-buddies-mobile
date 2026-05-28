import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:dashboard/core/router/app_router.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // navigatorKey is registered in main.dart before this runs
  sl.registerSingleton<GoRouter>(buildRouter());
}
