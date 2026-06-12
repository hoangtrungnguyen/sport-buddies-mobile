import 'package:dashboard/core/di/injection.dart';
import 'package:dashboard/features/auth/bloc/auth_bloc.dart';
import 'package:dashboard/features/auth/bloc/signup_bloc.dart';
import 'package:dashboard/features/auth/repository/owner_auth_repository.dart';
import 'package:dashboard/features/auth/view/forgot_password_screen.dart';
import 'package:dashboard/features/auth/view/login_screen.dart';
import 'package:dashboard/features/auth/view/signup_screen.dart';
import 'package:dashboard/features/notifications/bloc/notification_bloc.dart';
import 'package:dashboard/features/notifications/bloc/notification_event.dart';
import 'package:dashboard/features/notifications/repository/notification_repository.dart';
import 'package:dashboard/features/requests/bloc/requests_bloc.dart';
import 'package:dashboard/features/requests/repository/booking_action_repository.dart';
import 'package:dashboard/features/requests/repository/booking_request_repository.dart';
import 'package:dashboard/features/courts/bloc/venue_bloc.dart';
import 'package:dashboard/features/courts/repository/venue_repository.dart';
import 'package:dashboard/features/courts/view/court_detail_screen.dart';
import 'package:dashboard/features/courts/view/court_form_screen.dart';
import 'package:dashboard/features/courts/view/courts_screen.dart';
import 'package:dashboard/features/requests/view/requests_screen.dart';
import 'package:dashboard/features/settings/view/settings_screen.dart';
import 'package:dashboard/features/venue_schedule/view/venue_schedule_page.dart';
import 'package:dashboard/features/setup/bloc/court_bloc.dart';
import 'package:dashboard/features/setup/bloc/court_event.dart';
import 'package:dashboard/features/setup/model/owner_court.dart';
import 'package:dashboard/features/setup/repository/owner_court_repository.dart';
import 'package:dashboard/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spb_core/core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Wraps [child] in a [CustomTransitionPage] that cross-fades instead of the
/// platform-default slide. `key: state.pageKey` is REQUIRED — without it the
/// inner ShellRoute Navigator can't tell the page changed and skips the
/// transition entirely (the cause of the earlier "still sliding" behaviour).
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    // Key on the full location so sibling routes that share a path prefix
    // (e.g. /courts/:id vs /courts/:id/edit) are treated as distinct pages and
    // the inner ShellRoute navigator actually swaps content between them.
    key: ValueKey(state.uri.toString()),
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
    child: child,
  );
}

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
      debugPrint(
          '[Router] redirect — going=$going authed=$authed session=${session?.accessToken.substring(0, 20)}...');

      if (!authed && !publicPaths.contains(going)) return '/login';
      if (authed && going == '/login') return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => BlocProvider(
          create: (_) => createAuthBloc()..add(const AuthEvent.appStarted()),
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
            RepositoryProvider<VenueRepository>.value(
                value: sl<VenueRepository>()),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<NotificationBloc>(
                create: (_) => NotificationBloc(sl<NotificationRepository>())
                  ..add(const NotificationEvent.loadRequested()),
              ),
              BlocProvider<RequestsBloc>(
                create: (_) => RequestsBloc(
                  repository: sl<BookingRequestRepository>(),
                  actionRepository: sl<BookingActionRepository>(),
                )..add(const RequestsEvent.started()),
              ),
              BlocProvider<CourtBloc>(
                create: (_) => CourtBloc(sl<OwnerCourtRepository>())
                  ..add(const CourtEvent.loadRequested()),
              ),
            ],
            child: AppShell(child: child),
          ),
        ),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => _fadePage(
                state,
                const _PlaceholderScreen('Trang chủ', Icons.home_outlined)),
          ),
          GoRoute(
            path: '/requests',
            pageBuilder: (context, state) =>
                _fadePage(state, const RequestsScreen()),
          ),
          GoRoute(
            path: '/schedule',
            // New Supabase-backed "Lịch sân" screen — provides its own
            // VenueScheduleBloc internally.
            pageBuilder: (context, state) =>
                _fadePage(state, const VenueSchedulePage()),
          ),
          GoRoute(
            path: '/fixed',
            pageBuilder: (context, state) => _fadePage(
                state,
                const _PlaceholderScreen(
                    'Lịch cố định', Icons.refresh_outlined)),
          ),
          GoRoute(
            path: '/analytics',
            pageBuilder: (context, state) => _fadePage(
                state,
                const _PlaceholderScreen(
                    'Thống kê', Icons.bar_chart_outlined)),
          ),
          GoRoute(
            path: '/players',
            pageBuilder: (context, state) => _fadePage(
                state,
                const _PlaceholderScreen(
                    'Khách hàng', Icons.people_outlined)),
          ),
          GoRoute(
            path: '/notifications',
            pageBuilder: (context, state) => _fadePage(
                state,
                const _PlaceholderScreen(
                    'Thông báo', Icons.notifications_outlined)),
          ),
          GoRoute(
            path: '/courts',
            pageBuilder: (context, state) =>
                _fadePage(state, const CourtsScreen()),
          ),
          GoRoute(
            path: '/courts/new',
            pageBuilder: (context, state) =>
                _fadePage(state, const CourtFormScreen()),
          ),
          GoRoute(
            path: '/courts/:id',
            pageBuilder: (context, state) => _fadePage(
              state,
              BlocProvider(
                create: (_) => VenueBloc(sl<VenueRepository>())
                  ..add(VenueEvent.loadRequested(state.pathParameters['id']!)),
                child: CourtDetailScreen(courtId: state.pathParameters['id']!),
              ),
            ),
          ),
          GoRoute(
            path: '/courts/:id/edit',
            pageBuilder: (context, state) => _fadePage(
              state,
              CourtFormScreen(court: state.extra as OwnerCourt?),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) =>
                _fadePage(state, const SettingsScreen()),
          ),
          GoRoute(
            path: '/support',
            pageBuilder: (context, state) => _fadePage(
                state,
                const _PlaceholderScreen(
                    'Hỗ trợ', Icons.help_outline_rounded)),
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
            style: const TextStyle(color: AppColors.neutral500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
