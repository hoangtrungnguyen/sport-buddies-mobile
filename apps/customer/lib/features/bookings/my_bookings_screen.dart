// My Bookings — unified screen with 3 tabs: Upcoming / Pending / History.
//
// Material Design 3 — role rail (primary=host, secondary=join), M3Badge.
// Design reference: EPIC-6 My Bookings.html

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'booking_model.dart';
import 'bookings_cubit.dart';
import 'bookings_state.dart';
import 'history_cubit.dart';
import 'history_state.dart';
import 'booking_view.dart';

// ─── MD3 tokens ──────────────────────────────────────────────────────────────
const _mdSurface                 = Color(0xFFF7FBF2);
const _mdOnSurface               = Color(0xFF181D18);
const _mdOnSurfaceVariant        = Color(0xFF414941);
const _mdSurfaceContainerLowest  = Color(0xFFFFFFFF);
const _mdSurfaceContainer        = Color(0xFFEBEFE6);
const _mdSurfaceContainerHighest = Color(0xFFDCE1D7);
const _mdPrimary                 = Color(0xFF15803D);
const _mdPrimaryContainer        = Color(0xFFBBF7D0);
const _mdOnPrimaryContainer      = Color(0xFF002111);
const _mdSecondary               = Color(0xFF506352);
const _mdSecondaryContainer      = Color(0xFFD3E8D3);
const _mdOnSecondaryContainer    = Color(0xFF0E1F10);
const _mdTertiary                = Color(0xFF3D6373);
const _mdTertiaryContainer       = Color(0xFFC1E8FA);
const _mdOnTertiaryContainer     = Color(0xFF001F2A);
const _mdError                   = Color(0xFFBA1A1A);
const _mdOutlineVariant          = Color(0xFFBFC9BA);
const _mdCornerFull = BorderRadius.all(Radius.circular(9999));

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
      'completed' => all.where((b) => b.status == BookingStatus.completed).toList(),
      _ => all,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mdSurface,
      body: Column(
        children: [
          BlocBuilder<BookingsCubit, BookingsState>(
            builder: (context, state) {
              final all = state is BookingsLoaded ? state.bookings : const <Booking>[];
              final joinReqs = state is BookingsLoaded
                  ? state.joinRequests
                  : const <JoinedSlotRequest>[];
              final source = all.map((b) => b.toBookingView()).toList();
              final upcomingCount = source.length;
              final pendingCount =
                  source.where((b) => b.status == BookingStatus.pending).length +
                      joinReqs.length;
              return _MyBookingsHeader(
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
                    HistoryLoading() =>
                      const Center(child: CircularProgressIndicator()),
                    HistoryError(:final message) => _ErrorView(
                        message: message,
                        onRetry: () => context.read<HistoryCubit>().loadHistory(),
                      ),
                    HistoryLoaded(:final items) => RefreshIndicator(
                        color: _mdPrimary,
                        onRefresh: () =>
                            context.read<HistoryCubit>().loadHistory(),
                        child: _HistoryTabView(
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
      BookingsLoading() || BookingsCancelling() =>
        const Center(child: CircularProgressIndicator()),
      BookingsError(:final message) => _ErrorView(
          message: message,
          onRetry: () => context.read<BookingsCubit>().loadUpcoming(),
        ),
      BookingsLoaded(:final bookings) => RefreshIndicator(
          color: _mdPrimary,
          onRefresh: () => context.read<BookingsCubit>().loadUpcoming(),
          child: _UpcomingTabView(
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
      BookingsLoading() || BookingsCancelling() =>
        const Center(child: CircularProgressIndicator()),
      BookingsError(:final message) => _ErrorView(
          message: message,
          onRetry: () => context.read<BookingsCubit>().loadUpcoming(),
        ),
      BookingsLoaded(:final bookings, :final joinRequests) => RefreshIndicator(
          color: _mdPrimary,
          onRefresh: () => context.read<BookingsCubit>().loadUpcoming(),
          child: _PendingTabView(
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

// ─── Header + tab bar ────────────────────────────────────────────────────────

class _MyBookingsHeader extends StatelessWidget {
  const _MyBookingsHeader({
    required this.tabController,
    required this.upcomingCount,
    required this.pendingCount,
  });

  final TabController tabController;
  final int upcomingCount;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      color: _mdSurface,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _NotifButton(),
                  GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: _ProfileAvatar(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Text(
                l10n.myBookingsTitle,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.22,
                  color: _mdOnSurface,
                ),
              ),
            ),
            const SizedBox(height: 4),
            TabBar(
              controller: tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: _mdPrimary, width: 3),
                insets: EdgeInsets.symmetric(horizontal: 8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: _mdPrimary,
              unselectedLabelColor: _mdOnSurfaceVariant,
              labelStyle: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
              tabs: [
                Tab(
                  height: 48,
                  child: Text(
                    upcomingCount > 0
                        ? '${l10n.bookingsTabUpcoming} · $upcomingCount'
                        : l10n.bookingsTabUpcoming,
                  ),
                ),
                Tab(
                  height: 48,
                  child: Text(
                    pendingCount > 0
                        ? '${l10n.bookingsTabPending} · $pendingCount'
                        : l10n.bookingsTabPending,
                  ),
                ),
                Tab(height: 48, child: Text(l10n.bookingsTabHistory)),
              ],
            ),
            Container(height: 1, color: _mdOutlineVariant),
          ],
        ),
      ),
    );
  }
}

class _NotifButton extends StatefulWidget {
  const _NotifButton();

  @override
  State<_NotifButton> createState() => _NotifButtonState();
}

class _NotifButtonState extends State<_NotifButton> {
  int _unread = 0;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _loadUnread();
    _subscribeRealtime();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  /// Counts the current user's unread notifications to drive the badge.
  Future<void> _loadUnread() async {
    try {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;
      if (uid == null) return;
      final rows = await client
          .from('notifications')
          .select('id')
          .eq('user_id', uid)
          .eq('read', false) as List<dynamic>;
      if (mounted) setState(() => _unread = rows.length);
    } catch (_) {
      // Non-critical — leave the badge hidden if the count can't be fetched.
    }
  }

  /// Keeps the badge live: re-counts whenever the user's notifications change.
  void _subscribeRealtime() {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;
    if (uid == null) return;
    _channel = client
        .channel('notif_badge_$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: uid,
          ),
          callback: (_) => _loadUnread(),
        )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.notifications_outlined, size: 24),
            color: _mdOnSurface,
            onPressed: () async {
              await context.push('/notifications');
              _loadUnread(); // refresh the badge after returning
            },
          ),
          if (_unread > 0)
            Positioned(
              top: 3,
              right: 1,
              child: Container(
                height: 16,
                constraints: const BoxConstraints(minWidth: 16),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: _mdError,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _mdSurface, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  _unread > 9 ? '9+' : '$_unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  String _initialsFrom(User? user) {
    if (user == null) return '?';
    final metaName = user.userMetadata?['full_name'] as String?;
    final source = (metaName?.trim().isNotEmpty ?? false)
        ? metaName!.trim()
        : (user.email?.trim() ?? '');
    if (source.isEmpty) return '?';
    final parts = source.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return (parts.first[0] + parts.last[0]).toUpperCase();
    return source.substring(0, source.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    User? user;
    try {
      user = Supabase.instance.client.auth.currentSession?.user;
    } catch (_) {
      user = null;
    }
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_mdPrimary, Color(0xFF22C55E)],
        ),
        border: Border.all(color: _mdSurface, width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Center(
        child: Text(
          _initialsFrom(user),
          style: const TextStyle(
            fontFamily: 'Sora',
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ─── Upcoming tab ─────────────────────────────────────────────────────────────

class _UpcomingTabView extends StatelessWidget {
  const _UpcomingTabView({
    required this.bookings,
    required this.allBookings,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final List<BookingView> bookings;
  final List<BookingView> allBookings;
  final String? activeFilter;
  final ValueChanged<String?> onFilterChanged;

  List<MapEntry<String, List<BookingView>>> _groupByDate(AppLocalizations l10n) {
    final grouped = <String, List<BookingView>>{};
    for (final b in bookings) {
      final key = _dateSectionLabel(l10n, b.date);
      grouped.putIfAbsent(key, () => []).add(b);
    }
    return grouped.entries.toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groups = _groupByDate(l10n);
    final hostCount = allBookings.where((b) => b.role == BookingRole.host).length;
    final joinCount = allBookings.where((b) => b.role == BookingRole.join).length;
    final recurringCount = allBookings.where((b) => b.type == BookingType.recurring).length;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _RoleFilterChip(
                label: '${l10n.bookingsFilterAll} · ${allBookings.length}',
                value: null,
                isActive: activeFilter == null,
                onTap: () => onFilterChanged(null),
              ),
              const SizedBox(width: 8),
              _RoleFilterChip(
                label: '${l10n.bookingsFilterHost} · $hostCount',
                value: 'host',
                isActive: activeFilter == 'host',
                leading: _HostCrown(color: activeFilter == 'host' ? _mdOnPrimaryContainer : _mdPrimary, size: 12),
                onTap: () => onFilterChanged(activeFilter == 'host' ? null : 'host'),
              ),
              const SizedBox(width: 8),
              _RoleFilterChip(
                label: '${l10n.bookingsFilterJoin} · $joinCount',
                value: 'join',
                isActive: activeFilter == 'join',
                leading: Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(
                    color: activeFilter == 'join' ? _mdOnSecondaryContainer : _mdSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
                onTap: () => onFilterChanged(activeFilter == 'join' ? null : 'join'),
              ),
              const SizedBox(width: 8),
              _RoleFilterChip(
                label: '${l10n.bookingsFilterRecurring} · $recurringCount',
                value: 'recurring',
                isActive: activeFilter == 'recurring',
                onTap: () => onFilterChanged(activeFilter == 'recurring' ? null : 'recurring'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const _RoleLegend(),
        const SizedBox(height: 8),
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                l10n.bookingsEmptyUpcoming,
                style: const TextStyle(color: _mdOnSurfaceVariant),
              ),
            ),
          )
        else
          for (final group in groups) ...[
            const SizedBox(height: 6),
            _SectionHeader(label: group.key),
            const SizedBox(height: 8),
            for (final booking in group.value) ...[
              _BookingCard(booking: booking),
              const SizedBox(height: 10),
            ],
          ],
      ],
    );
  }
}

String _dateSectionLabel(AppLocalizations l10n, DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(date.year, date.month, date.day);
  final formatted = DateFormat('dd/MM').format(date);
  if (d == today) return '${l10n.bookingsToday} · $formatted';
  if (d == today.add(const Duration(days: 1))) {
    return '${l10n.bookingsTomorrow} · $formatted';
  }
  final weekdays = [
    l10n.bookingsWeekdaySun,
    l10n.bookingsWeekdayMon,
    l10n.bookingsWeekdayTue,
    l10n.bookingsWeekdayWed,
    l10n.bookingsWeekdayThu,
    l10n.bookingsWeekdayFri,
    l10n.bookingsWeekdaySat,
  ];
  return '${weekdays[date.weekday % 7]} · $formatted';
}

/// Localized booking status label from status + role.
String _statusLabel(AppLocalizations l10n, BookingStatus status, BookingRole role) =>
    switch (status) {
      BookingStatus.confirmed =>
        role == BookingRole.join ? l10n.bookingStatusApproved : l10n.bookingStatusConfirmed,
      BookingStatus.pending =>
        role == BookingRole.join ? l10n.bookingStatusPendingJoin : l10n.bookingStatusPendingHost,
      BookingStatus.completed => l10n.bookingsFilterCompleted,
      BookingStatus.cancelled => l10n.bookingStatusCancelled,
    };

/// Localized label for a join-request override token.
String _overrideLabel(AppLocalizations l10n, String token) => switch (token) {
      'accepted' => l10n.bookingJoinAccepted,
      'rejected' => l10n.bookingJoinRejected,
      _ => l10n.bookingStatusPendingHost,
    };

/// Localized label for an action token.
String _actionLabel(AppLocalizations l10n, String token) => switch (token) {
      'rebook' => l10n.bookingActionRebook,
      'detail' => l10n.bookingActionDetail,
      'cancel' => l10n.bookingActionCancel,
      _ => token,
    };

// ─── Pending tab ──────────────────────────────────────────────────────────────

class _PendingTabView extends StatelessWidget {
  const _PendingTabView({required this.pending});

  final List<BookingView> pending;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (pending.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 80),
            child: Center(
              child: Text(l10n.bookingsEmptyPending,
                  style: const TextStyle(color: _mdOnSurfaceVariant)),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        _SectionHeader(label: l10n.bookingsPendingHeader),
        const SizedBox(height: 8),
        for (final b in pending) ...[
          _BookingCard(booking: b),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

// ─── History tab ──────────────────────────────────────────────────────────────

class _HistoryTabView extends StatelessWidget {
  const _HistoryTabView({
    required this.bookings,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final List<BookingView> bookings;
  final String? activeFilter;
  final ValueChanged<String?> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _RoleFilterChip(
                label: l10n.bookingsFilterAll,
                value: null,
                isActive: activeFilter == null,
                onTap: () => onFilterChanged(null),
              ),
              const SizedBox(width: 8),
              _RoleFilterChip(
                label: l10n.bookingsFilterHost,
                value: 'host',
                isActive: activeFilter == 'host',
                leading: _HostCrown(
                  color: activeFilter == 'host' ? _mdOnPrimaryContainer : _mdPrimary,
                  size: 12,
                ),
                onTap: () => onFilterChanged(activeFilter == 'host' ? null : 'host'),
              ),
              const SizedBox(width: 8),
              _RoleFilterChip(
                label: l10n.bookingsFilterJoin,
                value: 'join',
                isActive: activeFilter == 'join',
                leading: Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(
                    color: activeFilter == 'join' ? _mdOnSecondaryContainer : _mdSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
                onTap: () => onFilterChanged(activeFilter == 'join' ? null : 'join'),
              ),
              const SizedBox(width: 8),
              _RoleFilterChip(
                label: l10n.bookingsFilterCompleted,
                value: 'completed',
                isActive: activeFilter == 'completed',
                onTap: () => onFilterChanged(activeFilter == 'completed' ? null : 'completed'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (bookings.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(l10n.bookingsEmptyHistory, style: const TextStyle(color: _mdOnSurfaceVariant)),
            ),
          )
        else
          for (final booking in bookings) ...[
            _BookingCard(booking: booking),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: _mdOnSurfaceVariant)),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: onRetry,
                child: Text(AppLocalizations.of(context).commonRetry)),
          ],
        ),
      ),
    );
  }
}

// ─── Booking card ─────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final BookingView booking;

  Future<void> _confirmCancel(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.bookingsCancelTitle),
        content: Text(l10n.bookingsCancelBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonNo),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.commonConfirm, style: const TextStyle(color: _mdError)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<BookingsCubit>().cancelBooking(booking.id);
    }
  }

  VoidCallback _actionTap(BuildContext context) {
    return switch (booking.action) {
      'rebook' when booking.courtId != null => () => context.push('/court/${booking.courtId}'),
      'detail' => () => context.push('/bookings/${booking.id}'),
      'cancel' => () => _confirmCancel(context),
      _ => () {},
    };
  }

  VoidCallback? _cardTap(BuildContext context) {
    return switch (booking.status) {
      BookingStatus.pending  => () => context.push('/booking/awaiting/${booking.id}'),
      BookingStatus.confirmed => () => context.push('/bookings/${booking.id}'),
      BookingStatus.completed || BookingStatus.cancelled => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isHost = booking.role == BookingRole.host;
    final railColor = isHost ? _mdPrimary : _mdSecondary;
    final iconBg = isHost ? _mdPrimaryContainer : _mdSecondaryContainer;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _cardTap(context),
      child: Container(
        decoration: BoxDecoration(
          color: _mdSurfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _mdOutlineVariant),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 3, offset: Offset(0, 1)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SportIconBox(
                                sport: booking.sport,
                                slots: booking.slots,
                                iconBg: iconBg,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            booking.courtName,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: _mdOnSurface,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        _TypeBadge(type: booking.type),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    _RoleLine(booking: booking),
                                    const SizedBox(height: 2),
                                    Text(
                                      booking.detail,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: _mdOnSurfaceVariant,
                                        height: 1.4,
                                      ),
                                    ),
                                    if (booking.recurringLabel != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        booking.recurringLabel!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: _mdPrimary,
                                          fontWeight: FontWeight.w600,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _M3Badge(
                          status: booking.status,
                          role: booking.role,
                          overrideToken: booking.statusOverrideToken,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(height: 1, color: _mdOutlineVariant),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time, size: 15, color: _mdOnSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              booking.time,
                              style: const TextStyle(fontSize: 13, color: _mdOnSurfaceVariant),
                            ),
                            if (booking.slots > 1) ...[
                              const SizedBox(width: 8),
                              _MultiSlotBadge(extraSlots: booking.slots - 1),
                            ],
                            const SizedBox(width: 8),
                            Text(
                              booking.price,
                              style: const TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _mdOnSurface,
                              ),
                            ),
                          ],
                        ),
                        if (booking.action != null)
                          _ActionButton(
                            label: _actionLabel(
                                AppLocalizations.of(context), booking.action!),
                            danger: booking.actionDanger,
                            onTap: _actionTap(context),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Role rail
              Positioned(
                top: 0, bottom: 0, left: 0,
                child: Container(width: 4, color: railColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleLine extends StatelessWidget {
  const _RoleLine({required this.booking});

  final BookingView booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (booking.role == BookingRole.join) {
      return Row(
        children: [
          Container(
            width: 18, height: 18,
            decoration: BoxDecoration(
              color: booking.hostColor ?? _mdOnSurfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                booking.hostInitials ?? '?',
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l10n.bookingsJoinedHost(booking.hostName ?? ''),
              style: const TextStyle(fontSize: 12, color: _mdSecondary, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _HostCrown(color: _mdPrimary, size: 13),
        const SizedBox(width: 5),
        Text(
          booking.players != null
              ? l10n.bookingsHostWithPlayers(booking.players!)
              : l10n.bookingsHost,
          style: const TextStyle(fontSize: 12, color: _mdPrimary, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _SportIconBox extends StatelessWidget {
  const _SportIconBox({required this.sport, required this.slots, required this.iconBg});

  final SportType sport;
  final int slots;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Text(bookingSportEmoji(sport), style: const TextStyle(fontSize: 22)),
            ),
          ),
          if (slots > 1)
            Positioned(
              top: -4, right: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: _mdPrimary,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: _mdSurfaceContainerLowest, width: 2),
                ),
                child: Text(
                  '$slots',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final BookingType type;

  @override
  Widget build(BuildContext context) {
    final isRecurring = type == BookingType.recurring;
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isRecurring ? _mdPrimaryContainer : _mdSurfaceContainerHighest,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Center(
        child: Text(
          isRecurring
              ? AppLocalizations.of(context).bookingsFilterRecurring
              : AppLocalizations.of(context).bookingsOneOff,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isRecurring ? FontWeight.w700 : FontWeight.w600,
            color: isRecurring ? _mdOnPrimaryContainer : _mdOnSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _M3Badge extends StatelessWidget {
  const _M3Badge({required this.status, required this.role, this.overrideToken});

  final BookingStatus status;
  final BookingRole role;
  final String? overrideToken;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = overrideToken != null
        ? _overrideLabel(l10n, overrideToken!)
        : _statusLabel(l10n, status, role);
    final (bg, fg, dot) = switch (status) {
      BookingStatus.confirmed => (_mdPrimaryContainer, _mdOnPrimaryContainer, _mdPrimary),
      BookingStatus.pending   => (_mdTertiaryContainer, _mdOnTertiaryContainer, _mdTertiary),
      BookingStatus.completed ||
      BookingStatus.cancelled => (_mdSurfaceContainerHighest, _mdOnSurfaceVariant, _mdOnSurfaceVariant),
    };
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: bg, borderRadius: _mdCornerFull),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }
}

class _MultiSlotBadge extends StatelessWidget {
  const _MultiSlotBadge({required this.extraSlots});

  final int extraSlots;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: _mdPrimaryContainer, borderRadius: BorderRadius.circular(99)),
      child: Center(
        child: Text(
          AppLocalizations.of(context).bookingsExtraSlots(extraSlots),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _mdOnPrimaryContainer),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.danger, required this.onTap});

  final String label;
  final bool danger;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: danger ? Colors.transparent : _mdSecondaryContainer,
          borderRadius: BorderRadius.circular(99),
          border: danger ? Border.all(color: _mdError) : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: danger ? _mdError : _mdOnSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Role legend ──────────────────────────────────────────────────────────────

class _RoleLegend extends StatelessWidget {
  const _RoleLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _mdSurfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _LegendItem(color: _mdPrimary, label: AppLocalizations.of(context).bookingsLegendHost),
          const SizedBox(width: 16),
          _LegendItem(
              color: _mdSecondary,
              label: AppLocalizations.of(context).bookingsLegendJoin),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4, height: 18,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 7),
        Text(label, style: const TextStyle(fontSize: 12, color: _mdOnSurfaceVariant)),
      ],
    );
  }
}

// ─── Filter chips ─────────────────────────────────────────────────────────────

class _RoleFilterChip extends StatelessWidget {
  const _RoleFilterChip({
    required this.label,
    required this.value,
    required this.isActive,
    required this.onTap,
    this.leading,
  });

  final String label;
  final String? value;
  final bool isActive;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isActive ? _mdPrimary : _mdSurfaceContainerLowest,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: isActive ? _mdPrimary : _mdOutlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 6)],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : _mdOnSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _mdOnSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ─── Host crown icon (SVG path painted) ──────────────────────────────────────

class _HostCrown extends StatelessWidget {
  const _HostCrown({this.color = _mdPrimary, this.size = 13.0});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CrownPainter(color: color),
    );
  }
}

class _CrownPainter extends CustomPainter {
  const _CrownPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final sx = size.width / 24;
    final sy = size.height / 24;
    final path = Path()
      ..moveTo(3 * sx, 7 * sy)
      ..lineTo(7.5 * sx, 10.5 * sy)
      ..lineTo(12 * sx, 4 * sy)
      ..lineTo(16.5 * sx, 10.5 * sy)
      ..lineTo(21 * sx, 7 * sy)
      ..lineTo(19.4 * sx, 18 * sy)
      ..lineTo(4.6 * sx, 18 * sy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CrownPainter old) => old.color != color;
}
