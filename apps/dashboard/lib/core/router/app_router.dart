import 'package:dashboard/core/di/injection.dart';
import 'package:dashboard/features/auth/bloc/auth_bloc.dart';
import 'package:dashboard/features/auth/bloc/signup_bloc.dart';
import 'package:dashboard/features/auth/repository/owner_auth_repository.dart';
import 'package:dashboard/features/auth/view/forgot_password_screen.dart';
import 'package:dashboard/features/auth/view/login_screen.dart';
import 'package:dashboard/features/auth/view/signup_screen.dart';
import 'package:dashboard/features/schedule/bloc/schedule_bloc.dart';
import 'package:dashboard/features/schedule/repository/manual_booking_repository.dart';
import 'package:dashboard/features/schedule/repository/owner_slot_repository.dart';
import 'package:dashboard/features/schedule/view/schedule_screen.dart';
import 'package:dashboard/features/notifications/bloc/notification_bloc.dart';
import 'package:dashboard/features/notifications/bloc/notification_event.dart';
import 'package:dashboard/features/notifications/repository/notification_repository.dart';
import 'package:dashboard/features/requests/bloc/requests_bloc.dart';
import 'package:dashboard/features/requests/repository/booking_action_repository.dart';
import 'package:dashboard/features/requests/repository/booking_request_repository.dart';
import 'package:dashboard/features/requests/view/requests_screen.dart';
import 'package:dashboard/features/settings/view/settings_screen.dart';
import 'package:dashboard/features/setup/bloc/court_bloc.dart';
import 'package:dashboard/features/setup/bloc/court_event.dart';
import 'package:dashboard/features/setup/repository/owner_court_repository.dart';
import 'package:dashboard/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spb_core/core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

GoRouter buildRouter() {
  const publicPaths = {'/login', '/signup', '/forgot-password'};

  AuthBloc createAuthBloc() {
    SupabaseClient? client;
    try {
      client = Supabase.instance.client;
    } catch (_) {}
    return AuthBloc(
      ownerAuthRepository: sl<OwnerAuthRepository>(),
      supabaseClient: client,
    );
  }

  return GoRouter(
    navigatorKey: sl<GlobalKey<NavigatorState>>(),
    initialLocation: '/',
    redirect: (context, state) {
      Session? session;
      try {
        session = Supabase.instance.client.auth.currentSession;
      } catch (_) {}

      final authed = session != null;
      final going = state.matchedLocation;

      if (!authed && !publicPaths.contains(going)) return '/login';
      if (authed && going == '/login') return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => BlocProvider(
          create: (_) =>
              createAuthBloc()..add(const AuthEvent.appStarted()),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => BlocProvider(
          create: (_) => SignupBloc(sl<OwnerAuthRepository>()),
          child: const SignupScreen(),
        ),
      ),
      // UNUSED: reachable by direct URL only. The "Quên mật khẩu?" button now
      // opens showContactSupportDialog instead of routing here. Tracking: Plane
      // OWNER-55 (Cancelled).
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => BlocProvider(
          create: (_) => createAuthBloc(),
          child: const ForgotPasswordScreen(),
        ),
      ),

      // Authenticated shell — sidebar + topbar + content.
      ShellRoute(
        builder: (context, state, child) => MultiRepositoryProvider(
          providers: [
            RepositoryProvider<OwnerCourtRepository>.value(
                value: sl<OwnerCourtRepository>()),
            RepositoryProvider<NotificationRepository>.value(
                value: sl<NotificationRepository>()),
          ],
          child: BlocProvider<NotificationBloc>(
            create: (_) =>
                NotificationBloc(sl<NotificationRepository>())
                  ..add(const NotificationEvent.loadRequested()),
            child: AppShell(child: child),
          ),
        ),
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const _PlaceholderScreen(
                'Trang chủ', Icons.home_outlined),
          ),
          GoRoute(
            path: '/requests',
            builder: (context, state) => BlocProvider(
              create: (_) => RequestsBloc(
                repository: sl<BookingRequestRepository>(),
                actionRepository: sl<BookingActionRepository>(),
              )..add(const RequestsEvent.started()),
              child: const RequestsScreen(),
            ),
          ),
          GoRoute(
            path: '/schedule',
            builder: (context, state) => BlocProvider(
              create: (_) => ScheduleBloc(
                slotRepository: sl<OwnerSlotRepository>(),
                bookingRepository: sl<ManualBookingRepository>(),
                loadCourts: () => sl<OwnerCourtRepository>().getCourts(),
              )..add(const ScheduleEvent.started()),
              child: const ScheduleScreen(),
            ),
          ),
          GoRoute(
            path: '/fixed',
            builder: (_, __) => const _PlaceholderScreen(
                'Lịch cố định', Icons.refresh_outlined),
          ),
          GoRoute(
            path: '/analytics',
            builder: (_, __) => const _PlaceholderScreen(
                'Thống kê', Icons.bar_chart_outlined),
          ),
          GoRoute(
            path: '/players',
            builder: (_, __) => const _PlaceholderScreen(
                'Khách hàng', Icons.people_outlined),
          ),
          GoRoute(
            path: '/notifications',
            builder: (_, __) => const _PlaceholderScreen(
                'Thông báo', Icons.notifications_outlined),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => BlocProvider(
              create: (_) =>
                  CourtBloc(sl<OwnerCourtRepository>())
                    ..add(const CourtEvent.loadRequested()),
              child: const SettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/support',
            builder: (_, __) => const _PlaceholderScreen(
                'Hỗ trợ', Icons.help_outline_rounded),
          ),
        ],
      ),
    ],
  );
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen(this.title, this.icon);
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: 'placeholder-$title',
            child: Icon(icon, size: 40, color: AppColors.neutral300),
          ),
          const SizedBox(height: 12),
          Text(
            '$title — đang được phát triển',
            style: const TextStyle(
                color: AppColors.neutral500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
