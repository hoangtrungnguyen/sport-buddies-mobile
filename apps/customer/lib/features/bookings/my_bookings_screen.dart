// My Bookings — unified screen with 3 tabs: Upcoming / Pending / History.
//
// Upcoming + Pending tabs are backed by [BookingsCubit] (future bookings
// whose status is pending or confirmed).
// History tab is backed by [HistoryCubit] (completed/cancelled bookings).
//
// Design reference: EPIC-6 My Bookings.html

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/spb_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'booking_model.dart';
import 'bookings_cubit.dart';
import 'bookings_state.dart';
import 'history_cubit.dart';
import 'history_state.dart';
import 'mock_booking.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Page entry point
// ─────────────────────────────────────────────────────────────────────────────

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => BookingsCubit(client)..loadUpcoming(),
        ),
        BlocProvider(
          create: (_) => HistoryCubit(client)..loadHistory(),
        ),
      ],
      child: const MyBookingsScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

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

  List<MockBooking> _filterUpcoming(List<Booking> all) {
    final mapped = all.map((b) => b.toMockBooking()).toList();
    if (_upcomingFilter == null) return mapped;
    return switch (_upcomingFilter!) {
      'one_off' => mapped.where((b) => b.type == BookingType.oneOff).toList(),
      'recurring' =>
        mapped.where((b) => b.type == BookingType.recurring).toList(),
      _ => mapped.where((b) => b.sport.name == _upcomingFilter).toList(),
    };
  }

  List<MockBooking> _filterHistory(List<HistoryBookingItem> items) {
    final filtered = switch (_historyFilter) {
      null => items,
      'completed' => items.where((i) => i.dbStatus == 'completed').toList(),
      'cancelled' => items.where((i) => i.dbStatus == 'cancelled').toList(),
      _ => items,
    };
    return filtered.map((i) => i.toMockBooking()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: Column(
        children: [
          BlocBuilder<BookingsCubit, BookingsState>(
            builder: (context, state) {
              final all = state is BookingsLoaded ? state.bookings : const <Booking>[];
              final upcomingCount = all.length;
              final pendingCount =
                  all.where((b) => b.status == 'pending').length;
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
                        onRetry: () =>
                            context.read<HistoryCubit>().loadHistory(),
                      ),
                    HistoryLoaded(:final items) => _HistoryTabView(
                        bookings: _filterHistory(items),
                        activeFilter: _historyFilter,
                        onFilterChanged: (f) =>
                            setState(() => _historyFilter = f),
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
      BookingsLoaded(:final bookings) => _UpcomingTabView(
          bookings: _filterUpcoming(bookings),
          rawBookings: bookings,
          activeFilter: _upcomingFilter,
          onFilterChanged: (f) => setState(() => _upcomingFilter = f),
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
      BookingsLoaded(:final bookings) => _PendingTabView(
          pending: bookings
              .where((b) => b.status == 'pending')
              .map((b) => b.toMockBooking())
              .toList(),
        ),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header + tab bar
// ─────────────────────────────────────────────────────────────────────────────

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
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NotifButton(),
                  _ProfileAvatar(),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Text(
                'Lịch đặt của tôi',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.22,
                  color: AppColors.neutral900,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TabBar(
              controller: tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: EdgeInsets.zero,
              labelPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              indicatorColor: AppColors.primary,
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: AppColors.primaryDark,
              unselectedLabelColor: AppColors.neutral500,
              labelStyle: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(
                  height: 40,
                  child: Text(
                    upcomingCount > 0
                        ? 'Sắp tới · $upcomingCount'
                        : 'Sắp tới',
                  ),
                ),
                Tab(
                  height: 40,
                  child: Text(
                    pendingCount > 0
                        ? 'Đang chờ · $pendingCount'
                        : 'Đang chờ',
                  ),
                ),
                const Tab(height: 40, child: Text('Lịch sử')),
              ],
            ),
            Container(height: 1, color: AppColors.neutral200),
          ],
        ),
      ),
    );
  }
}

class _NotifButton extends StatelessWidget {
  const _NotifButton();

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
            color: AppColors.neutral900,
            onPressed: () {},
          ),
          Positioned(
            top: 7,
            right: 8,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  String _initialsFrom(User? user) {
    if (user == null) return '?';
    final metaName = user.userMetadata?['full_name'] as String?;
    final source = (metaName?.trim().isNotEmpty ?? false)
        ? metaName!.trim()
        : (user.email?.trim() ?? '');
    if (source.isEmpty) return '?';
    final parts = source.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return (parts.first[0] + parts.last[0]).toUpperCase();
    }
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
          colors: [AppColors.primary, AppColors.primaryMid],
        ),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Upcoming tab
// ─────────────────────────────────────────────────────────────────────────────

class _UpcomingTabView extends StatelessWidget {
  const _UpcomingTabView({
    required this.bookings,
    required this.rawBookings,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final List<MockBooking> bookings;
  final List<Booking> rawBookings;
  final String? activeFilter;
  final ValueChanged<String?> onFilterChanged;

  List<MapEntry<String, List<MockBooking>>> _groupByDate() {
    final grouped = <String, List<MockBooking>>{};
    for (final b in bookings) {
      final key = _dateSectionLabel(b.date);
      grouped.putIfAbsent(key, () => []).add(b);
    }
    return grouped.entries.toList();
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupByDate();
    final all = rawBookings.map((b) => b.toMockBooking()).toList();
    final oneOffCount = all.where((b) => b.type == BookingType.oneOff).length;
    final recurringCount =
        all.where((b) => b.type == BookingType.recurring).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        _FilterChipRow(
          chips: [
            _ChipData(label: 'Tất cả · ${all.length}', value: null),
            _ChipData(label: 'Một lần · $oneOffCount', value: 'one_off'),
            _ChipData(label: '🔁 Định kỳ · $recurringCount', value: 'recurring'),
            const _ChipData(label: 'Pickleball', value: 'pickleball'),
            const _ChipData(label: 'Bóng đá', value: 'football'),
          ],
          activeValue: activeFilter,
          onChanged: onFilterChanged,
        ),
        const SizedBox(height: 8),
        if (groups.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Không có lịch đặt nào',
                style: TextStyle(color: AppColors.neutral500),
              ),
            ),
          )
        else
          for (final group in groups) ...[
            _SectionHeader(label: group.key),
            const SizedBox(height: 8),
            for (final booking in group.value) ...[
              _BookingCard(booking: booking),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 6),
          ],
      ],
    );
  }
}

String _dateSectionLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(date.year, date.month, date.day);
  final formatted = DateFormat('dd/MM').format(date);
  if (d == today) return 'HÔM NAY · $formatted';
  if (d == today.add(const Duration(days: 1))) return 'NGÀY MAI · $formatted';
  const weekdays = [
    'CHỦ NHẬT',
    'THỨ HAI',
    'THỨ BA',
    'THỨ TƯ',
    'THỨ NĂM',
    'THỨ SÁU',
    'THỨ BẢY',
  ];
  return '${weekdays[date.weekday % 7]} · $formatted';
}

// ─────────────────────────────────────────────────────────────────────────────
// Pending tab
// ─────────────────────────────────────────────────────────────────────────────

class _PendingTabView extends StatelessWidget {
  const _PendingTabView({required this.pending});

  final List<MockBooking> pending;

  @override
  Widget build(BuildContext context) {
    if (pending.isEmpty) {
      return const Center(
        child: Text(
          'Không có lịch đang chờ',
          style: TextStyle(color: AppColors.neutral500),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        const _SectionHeader(label: 'ĐẶT SÂN CHỜ XÁC NHẬN'),
        const SizedBox(height: 8),
        for (final b in pending) ...[
          _BookingCard(booking: b),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// History tab
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryTabView extends StatelessWidget {
  const _HistoryTabView({
    required this.bookings,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final List<MockBooking> bookings;
  final String? activeFilter;
  final ValueChanged<String?> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        _FilterChipRow(
          chips: const [
            _ChipData(label: 'Tất cả', value: null),
            _ChipData(label: 'Đã hoàn thành', value: 'completed'),
            _ChipData(label: 'Đã huỷ', value: 'cancelled'),
          ],
          activeValue: activeFilter,
          onChanged: onFilterChanged,
        ),
        const SizedBox(height: 12),
        if (bookings.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Không có lịch sử đặt sân',
                style: TextStyle(color: AppColors.neutral500),
              ),
            ),
          )
        else
          for (final booking in bookings) ...[
            _BookingCard(booking: booking),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error view (shared)
// ─────────────────────────────────────────────────────────────────────────────

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
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.neutral500),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Booking card
// ─────────────────────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final MockBooking booking;

  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Huỷ đặt sân này?'),
        content: const Text('Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Xác nhận',
              style: TextStyle(color: AppColors.danger),
            ),
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
      'Đặt lại' when booking.courtId != null =>
        () => context.push('/court/${booking.courtId}'),
      'Chi tiết' => () => context.push('/bookings/${booking.id}'),
      'Huỷ' => () => _confirmCancel(context),
      _ => () {},
    };
  }

  VoidCallback? _cardTap(BuildContext context) {
    return switch (booking.status) {
      BookingStatus.pending =>
        () => context.push('/booking/awaiting/${booking.id}'),
      BookingStatus.confirmed =>
        () => context.push('/bookings/${booking.id}'),
      BookingStatus.completed || BookingStatus.cancelled => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isRecurring = booking.type == BookingType.recurring;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _cardTap(context),
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
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
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 6,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        booking.courtName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.neutral900,
                                          height: 1.3,
                                        ),
                                      ),
                                      _TypeBadge(type: booking.type),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    booking.detail,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.neutral500,
                                      height: 1.4,
                                    ),
                                  ),
                                  if (booking.recurringLabel != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      booking.recurringLabel!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primaryDark,
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
                      _StatusBadge(status: booking.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: AppColors.neutral200),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 15,
                                  color: AppColors.neutral700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  booking.time,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.neutral700,
                                    fontFeatures: [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (booking.slots > 1)
                              _MultiSlotBadge(extraSlots: booking.slots - 1),
                            Text(
                              booking.price,
                              style: const TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (booking.action != null) ...[
                        const SizedBox(width: 8),
                        _ActionButton(
                          label: booking.action!,
                          danger: booking.actionDanger,
                          onTap: _actionTap(context),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (isRecurring)
              Positioned(
                top: 0,
                left: 14,
                right: 14,
                child: Container(
                  height: 3,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(99),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}

class _SportIconBox extends StatelessWidget {
  const _SportIconBox({required this.sport, required this.slots});

  final SportType sport;
  final int slots;

  @override
  Widget build(BuildContext context) {
    final color = bookingSportColor(sport);
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                bookingSportEmoji(sport),
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          if (slots > 1)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  '$slots',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
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
        color: isRecurring ? AppColors.primaryLight : AppColors.neutral100,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Center(
        child: Text(
          isRecurring ? '🔁 Định kỳ' : 'Một lần',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isRecurring ? AppColors.primaryDark : AppColors.neutral700,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, dot) = switch (status) {
      BookingStatus.confirmed => (
          AppColors.successBg,
          AppColors.primaryDark,
          AppColors.success,
        ),
      BookingStatus.pending => (
          AppColors.warningBg,
          const Color(0xFF92670B),
          AppColors.warning,
        ),
      BookingStatus.completed => (
          AppColors.neutral100,
          AppColors.neutral500,
          AppColors.neutral500,
        ),
      BookingStatus.cancelled => (
          AppColors.neutral100,
          AppColors.neutral500,
          AppColors.neutral500,
        ),
    };

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            bookingStatusLabel(status),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
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
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Center(
        child: Text(
          '+$extraSlots khung',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.danger,
    required this.onTap,
  });

  final String label;
  final bool danger;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: danger ? AppColors.dangerBg : AppColors.primaryLight,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: danger ? AppColors.danger : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ChipData {
  const _ChipData({required this.label, required this.value});

  final String label;
  final String? value;
}

class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({
    required this.chips,
    required this.activeValue,
    required this.onChanged,
  });

  final List<_ChipData> chips;
  final String? activeValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final chip = chips[i];
          final isActive = chip.value == activeValue;
          return GestureDetector(
            onTap: () => onChanged(isActive ? null : chip.value),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.neutral200,
                ),
              ),
              child: Center(
                child: Text(
                  chip.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : AppColors.neutral700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral500,
        letterSpacing: 0.3,
      ),
    );
  }
}
