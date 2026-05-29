import 'package:dashboard/core/router/app_router.dart';
import 'package:dashboard/features/auth/repository/owner_auth_repository.dart';
import 'package:dashboard/features/notifications/repository/notification_repository.dart';
import 'package:dashboard/features/requests/repository/booking_action_repository.dart';
import 'package:dashboard/features/requests/repository/booking_request_repository.dart';
import 'package:dashboard/features/schedule/repository/manual_booking_repository.dart';
import 'package:dashboard/features/schedule/repository/owner_slot_repository.dart';
import 'package:dashboard/features/setup/repository/owner_court_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  sl.registerLazySingleton<OwnerAuthRepository>(
    () => OwnerAuthRepository(),
  );

  sl.registerLazySingleton<OwnerCourtRepository>(
    () => OwnerCourtRepository(Supabase.instance.client),
  );

  sl.registerLazySingleton<OwnerSlotRepository>(
    () => SupabaseOwnerSlotRepository(Supabase.instance.client),
  );

  sl.registerLazySingleton<ManualBookingRepository>(
    () => HttpManualBookingRepository(),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(Supabase.instance.client),
  );

  sl.registerLazySingleton<BookingRequestRepository>(
    () => SupabaseBookingRequestRepository(Supabase.instance.client),
  );

  sl.registerLazySingleton<BookingActionRepository>(
    () => SupabaseBookingActionRepository(Supabase.instance.client),
  );

  // Router registered last so it can resolve other singletons.
  sl.registerSingleton<GoRouter>(buildRouter());
}
