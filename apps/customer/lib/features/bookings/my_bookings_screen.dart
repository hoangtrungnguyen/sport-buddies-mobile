// My Bookings — unified screen with 3 tabs: Upcoming / Pending / History.
//
// Material Design 3 — role rail (primary=host, secondary=join), M3Badge.
// Design reference: EPIC-6 My Bookings.html

import 'package:customer/core/l10n/error_messages.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'booking_model.dart';
import 'bookings_cubit.dart';
import 'bookings_state.dart';
import 'history_cubit.dart';
import 'history_state.dart';
import 'booking_view.dart';
import 'bookings_style.dart';
import 'widgets/bookings_header.dart';
import 'widgets/booking_tab_views.dart';

// ─── Page entry point ────────────────────────────────────────────────────────

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => BookingsCubit(client)..loadUpcoming()),
        BlocProvider(create: (_) => HistoryCubit(client)..loadHistory()),
      ],
      child: const MyBookingsScreen(),
    );
  }
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  String? _upcomingFilter;
  String? _historyFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<BookingView> _filterUpcoming(List<BookingView> all) {
    return switch (_upcomingFilter) {
      null => all,
      'host' => all.where((b) => b.role == BookingRole.host).toList(),
      'join' => all.where((b) => b.role == BookingRole.join).toList(),
      'recurring' => all.where((b) => b.type == BookingType.recurring).toList(),
      _ => all,
    };
  }

  List<BookingView> _filterHistory(List<BookingView> all) {
    return switch (_historyFilter) {
      null => all,
      'host' => all.where((b) => b.role == BookingRole.host).toList(),
      'join' => all.where((b) => b.role == BookingRole.join).toList(),
      'completed' =>
        all.where((b) => b.status == BookingStatus.completed).toList(),
      _ => all,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mdSurface,
      body: Column(
        children: [
          BlocBuilder<BookingsCubit, BookingsState>(
            builder: (context, state) {
              final all = state is BookingsLoaded
                  ? state.bookings
                  : const <Booking>[];
              final joinReqs = state is BookingsLoaded
                  ? state.joinRequests
                  : const <JoinedSlotRequest>[];
              final source = all.map((b) => b.toBookingView()).toList();
              final upcomingCount = source.length;
              final pendingCount =
                  source
                      .where((b) => b.status == BookingStatus.pending)
                      .length +
                  joinReqs.length;
              return MyBookingsHeader(
                tabController: _tabController,
                upcomingCount: upcomingCount,
                pendingCount: pendingCount,
              );
            },
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                BlocBuilder<BookingsCubit, BookingsState>(
                  builder: (context, state) => _buildUpcomingTab(state),
                ),
                BlocBuilder<BookingsCubit, BookingsState>(
                  builder: (context, state) => _buildPendingTab(state),
                ),
                BlocBuilder<HistoryCubit, HistoryState>(
                  builder: (context, state) => switch (state) {
                    HistoryLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    HistoryError(:final message) => ErrorView(
                      message: appErrorMessage(
                        AppLocalizations.of(context),
                        message,
                      ),
                      onRetry: () => context.read<HistoryCubit>().loadHistory(),
                    ),
                    HistoryLoaded(:final items) => RefreshIndicator(
                      color: mdPrimary,
                      onRefresh: () =>
                          context.read<HistoryCubit>().loadHistory(),
                      child: HistoryTabView(
                        bookings: _filterHistory(
                          items.map((i) => i.toBookingView()).toList(),
                        ),
                        activeFilter: _historyFilter,
                        onFilterChanged: (f) =>
                            setState(() => _historyFilter = f),
                      ),
                    ),
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTab(BookingsState state) {
    return switch (state) {
      BookingsLoading() ||
      BookingsCancelling() => const Center(child: CircularProgressIndicator()),
      BookingsError(:final message) => ErrorView(
        message: appErrorMessage(AppLocalizations.of(context), message),
        onRetry: () => context.read<BookingsCubit>().loadUpcoming(),
      ),
      BookingsLoaded(:final bookings) => RefreshIndicator(
        color: mdPrimary,
        onRefresh: () => context.read<BookingsCubit>().loadUpcoming(),
        child: UpcomingTabView(
          bookings: _filterUpcoming(
            bookings.map((b) => b.toBookingView()).toList(),
          ),
          allBookings: bookings.map((b) => b.toBookingView()).toList(),
          activeFilter: _upcomingFilter,
          onFilterChanged: (f) => setState(() => _upcomingFilter = f),
        ),
      ),
    };
  }

  Widget _buildPendingTab(BookingsState state) {
    return switch (state) {
      BookingsLoading() ||
      BookingsCancelling() => const Center(child: CircularProgressIndicator()),
      BookingsError(:final message) => ErrorView(
        message: appErrorMessage(AppLocalizations.of(context), message),
        onRetry: () => context.read<BookingsCubit>().loadUpcoming(),
      ),
      BookingsLoaded(:final bookings, :final joinRequests) => RefreshIndicator(
        color: mdPrimary,
        onRefresh: () => context.read<BookingsCubit>().loadUpcoming(),
        child: PendingTabView(
          pending: [
            ...bookings
                .where((b) => b.status == 'pending')
                .map((b) => b.toBookingView()),
            ...joinRequests.map((j) => j.toBookingView()),
          ],
        ),
      ),
    };
  }
}
