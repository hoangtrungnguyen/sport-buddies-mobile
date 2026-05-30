// GoRouter configuration.
//
// Top-level structure:
//   - StatefulShellRoute.indexedStack with 3 tabs (Map / Bookings / Profile),
//     each with its own Navigator so per-tab state is preserved across taps.
//   - Auth screens (/login, /signup, /forgot-password) and booking detail
//     (/bookings/:id) live outside the shell so they cover the whole screen
//     (no bottom nav).
//
// Auth redirect:
//   - Unauthenticated → forced to /login (except /signup, /forgot-password).
//   - Authenticated landing on /login or /signup → forced to /.
//
// DI: the router is a Singleton in RegisterModule so callers outside the
// widget tree (e.g. FCM handlers) can call sl<GoRouter>().go(...).

import 'package:customer/core/router/app_shell.dart';
import 'package:customer/features/auth/bloc/auth_bloc.dart';
import 'package:customer/features/auth/view/forgot_password_screen.dart';
import 'package:customer/features/auth/view/login_screen.dart';
import 'package:customer/features/auth/view/sign_up_screen.dart';
import 'package:customer/features/booking/booking_cubit.dart';
import 'package:customer/features/booking/booking_screen.dart';
import 'package:customer/features/bookings/booking_detail_screen.dart';
import 'package:customer/features/bookings/booking_history_screen.dart';
import 'package:customer/features/bookings/upcoming_bookings_screen.dart';
import 'package:customer/features/courts/court_detail_screen.dart';
import 'package:customer/features/courts/cubit/court_detail_cubit.dart';
import 'package:customer/features/courts/cubit/schedule_overview_cubit.dart';
import 'package:customer/features/courts/schedule_overview_screen.dart';
import 'package:customer/features/courts/slot_picker_screen.dart';
import 'package:customer/features/map/court_repository_impl.dart';
import 'package:customer/features/map/cubit/map_cubit.dart';
import 'package:customer/features/map/data/supabase_court_availability_repository.dart';
import 'package:customer/features/map/location_cubit.dart';
import 'package:customer/features/map/location_service.dart' show GeolocatorLocationService;
import 'package:customer/features/slots/cubit/open_slot_list_cubit.dart';
import 'package:customer/features/slots/data/supabase_slot_repository.dart';
import 'package:customer/features/map/map_screen.dart';
import 'package:customer/features/profile/profile_cubit.dart';
import 'package:customer/features/profile/profile_screen.dart';
import 'package:customer/features/recurring/recurring_booking_screen.dart';
import 'package:customer/features/slots/cubit/slot_detail_cubit.dart';
import 'package:customer/features/slots/slot_detail_screen.dart';
import 'package:customer/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

GoRouter buildRouter() {
  const publicPaths = {'/login', '/signup', '/forgot-password'};

  AuthBloc createAuthBloc() {
    SupabaseClient? supabaseClient;
    try {
      supabaseClient = Supabase.instance.client;
    } catch (_) {
      supabaseClient = null;
    }

    return AuthBloc(
      supabaseClient: supabaseClient,
      authClient: supabaseClient?.auth,
    );
  }

  return GoRouter(
    navigatorKey: sl<GlobalKey<NavigatorState>>(),
    initialLocation: '/',
    redirect: (context, state) {
      Session? session;
      try {
        session = Supabase.instance.client.auth.currentSession;
      } catch (_) {
        session = null;
      }

      final isAuthenticated = session != null;
      final goingTo = state.matchedLocation;

      if (!isAuthenticated && !publicPaths.contains(goingTo)) {
        return '/login';
      }
      if (isAuthenticated &&
          (goingTo == '/login' || goingTo == '/signup')) {
        return '/';
      }
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // Tab 1 — Map / home.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (_) => MapCubit(
                        repository: SupabaseCourtAvailabilityRepository(
                          Supabase.instance.client,
                        ),
                        realtimeClient: Supabase.instance.client,
                      )..loadCourts(),
                    ),
                    BlocProvider(
                      create: (_) =>
                          LocationCubit(const GeolocatorLocationService())..requestAndFetch(),
                    ),
                    BlocProvider(
                      create: (_) => SlotListCubit(
                        SupabaseSlotRepository(
                          client: Supabase.instance.client,
                        ),
                      ),
                    ),
                  ],
                  child: const MapScreen(),
                ),
              ),
            ],
          ),
          // Tab 2 — Bookings (upcoming default + history sibling).
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings/upcoming',
                builder: (context, state) => const UpcomingBookingsPage(),
              ),
              GoRoute(
                path: '/bookings/history',
                builder: (context, state) => const BookingHistoryPage(),
              ),
            ],
          ),
          // Tab 3 — Profile.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => BlocProvider(
                  create: (_) => ProfileCubit(Supabase.instance.client),
                  child: const ProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      // Full-screen routes (no bottom nav).
      GoRoute(
        path: '/login',
        builder: (context, state) => BlocProvider(
          create: (_) => createAuthBloc(),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => BlocProvider(
          create: (_) => createAuthBloc(),
          child: const SignUpScreen(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => BlocProvider(
          create: (_) => createAuthBloc(),
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/bookings/:id',
        builder: (context, state) => BookingDetailPage(
          bookingId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/court/:id',
        builder: (context, state) => BlocProvider(
          create: (_) => CourtDetailCubit(
            SupabaseCourtRepository(client: Supabase.instance.client),
          ),
          child: CourtDetailScreen(courtId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/court/:id/slots',
        builder: (context, state) =>
            SlotPickerScreen(courtId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/court/:id/schedule',
        builder: (context, state) => BlocProvider(
          create: (_) => ScheduleOverviewCubit(
            courtRepository:
                SupabaseCourtRepository(client: Supabase.instance.client),
            slotRepository: SupabaseSlotRepository(
                client: Supabase.instance.client),
          ),
          child: ScheduleOverviewScreen(
              courtId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/booking',
        builder: (context, state) {
          final slotId = state.extra as String;
          return BlocProvider(
            create: (_) => BookingCubit(
              slotRepository:
                  SupabaseSlotRepository(client: Supabase.instance.client),
              courtRepository:
                  SupabaseCourtRepository(client: Supabase.instance.client),
              client: Supabase.instance.client,
            ),
            child: BookingScreen(slotId: slotId),
          );
        },
      ),
      GoRoute(
        path: '/slot/:id',
        builder: (context, state) => BlocProvider(
          create: (_) => SlotDetailCubit(
            SupabaseSlotRepository(client: Supabase.instance.client),
          ),
          child: SlotDetailScreen(slotId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/booking/recurring',
        builder: (context, state) => const RecurringBookingScreen(),
      ),
    ],
  );
}
