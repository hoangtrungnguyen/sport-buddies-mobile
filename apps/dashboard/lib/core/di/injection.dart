import 'package:dashboard/config/feature_flags/feature_flag_cubit.dart';
import 'package:dashboard/config/feature_flags/feature_flag_service.dart';
import 'package:dashboard/core/router/app_router.dart';
import 'package:dashboard/features/auth/repository/owner_auth_repository.dart';
import 'package:dashboard/features/home/repository/home_api_client.dart';
import 'package:dashboard/features/home/repository/home_repository.dart';
import 'package:dashboard/features/home/repository/home_repository_impl.dart';
import 'package:dashboard/features/notifications/repository/notification_repository.dart';
import 'package:dashboard/features/profile/repository/profile_repository.dart';
import 'package:dashboard/features/profile/repository/profile_repository_impl.dart';
import 'package:dashboard/features/requests/repository/booking_action_repository.dart';
import 'package:dashboard/features/requests/repository/booking_request_repository.dart';
import 'package:dashboard/features/slot_detail/repository/slot_players_repository.dart';
import 'package:dashboard/features/courts/repository/venue_api_client.dart';
import 'package:dashboard/features/courts/repository/venue_repository.dart';
import 'package:dashboard/features/setup/repository/owner_court_repository.dart';
import 'package:dashboard/features/venue_schedule/repository/schedule_api_client.dart';
import 'package:dashboard/features/venue_schedule/repository/schedule_repository.dart';
import 'package:dashboard/features/venue_schedule/repository/supabase_schedule_repository.dart';
import 'package:dashboard/features/venue_schedule/service/schedule_service.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  sl.registerLazySingleton<OwnerAuthRepository>(
    () => OwnerAuthRepository(),
  );

  sl.registerLazySingleton<HomeApiClient>(
    () => HomeApiClient(),
  );

  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl<HomeApiClient>()),
  );

  sl.registerLazySingleton<OwnerCourtRepository>(
    () => OwnerCourtRepository(Supabase.instance.client),
  );

  sl.registerLazySingleton<VenueApiClient>(
    () => VenueApiClient(),
  );

  sl.registerLazySingleton<VenueRepository>(
    () => VenueRepository(Supabase.instance.client, sl<VenueApiClient>()),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(Supabase.instance.client),
  );

  // Owner profile (Hồ sơ). No backend endpoint yet — the impl serves an
  // in-memory record overlaid with the live Supabase identity. Swap for an
  // API/Supabase-backed impl once the endpoint lands.
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(Supabase.instance.client),
  );

  sl.registerLazySingleton<BookingRequestRepository>(
    () => SupabaseBookingRequestRepository(Supabase.instance.client),
  );

  sl.registerLazySingleton<BookingActionRepository>(
    () => SupabaseBookingActionRepository(Supabase.instance.client),
  );

  sl.registerLazySingleton<SlotPlayersRepository>(
    () => SupabaseSlotPlayersRepository(Supabase.instance.client),
  );

  // "Lịch sân" (venue_schedule) — reads stay direct-to-Supabase; every
  // mutation (slot create/block/unblock, booking status) goes through the
  // Django backend via this Dio client, forwarding the owner's Supabase JWT.
  sl.registerLazySingleton<ScheduleApiClient>(
    () => ScheduleApiClient(),
  );

  sl.registerLazySingleton<ScheduleRepository>(
    () => SupabaseScheduleRepository(
      Supabase.instance.client,
      sl<ScheduleApiClient>(),
    ),
  );

  sl.registerLazySingleton<ScheduleService>(
    () => ScheduleService(sl<ScheduleRepository>()),
  );

  // Feature flags. The service is initialized in main() (needs the owner
  // session + plan) before this runs, so the registered singleton is ready.
  sl.registerSingleton<FeatureFlagService>(FeatureFlagService());
  sl.registerLazySingleton<FeatureFlagCubit>(
    () => FeatureFlagCubit(sl<FeatureFlagService>()),
    dispose: (cubit) => cubit.close(),
  );

  // Router registered last so it can resolve other singletons.
  sl.registerSingleton<GoRouter>(buildRouter());
}
