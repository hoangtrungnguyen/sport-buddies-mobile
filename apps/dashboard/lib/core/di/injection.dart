import 'package:dashboard/core/router/app_router.dart';
import 'package:dashboard/features/setup/repository/owner_court_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  sl.registerLazySingleton<OwnerCourtRepository>(
    () => OwnerCourtRepository(Supabase.instance.client),
  );

  // Router registered last so it can resolve other singletons.
  sl.registerSingleton<GoRouter>(buildRouter());
}
