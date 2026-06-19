// Header for the My Bookings screen: notification button, profile avatar,
// title and the Upcoming/Pending/History tab bar. Extracted from
// my_bookings_screen.dart so the screen stays focused on tab orchestration.

import 'package:customer/features/bookings/bookings_style.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Header + tab bar ────────────────────────────────────────────────────────

class MyBookingsHeader extends StatelessWidget {
  const MyBookingsHeader({
    super.key,
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
      color: mdSurface,
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
                  color: mdOnSurface,
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
                borderSide: BorderSide(color: mdPrimary, width: 3),
                insets: EdgeInsets.symmetric(horizontal: 8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: mdPrimary,
              unselectedLabelColor: mdOnSurfaceVariant,
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
            Container(height: 1, color: mdOutlineVariant),
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
      final rows =
          await client
                  .from('notifications')
                  .select('id')
                  .eq('user_id', uid)
                  .eq('read', false)
              as List<dynamic>;
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
            color: mdOnSurface,
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
                  color: mdError,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: mdSurface, width: 1.5),
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
    final parts = source
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
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
          colors: [mdPrimary, Color(0xFF22C55E)],
        ),
        border: Border.all(color: mdSurface, width: 2),
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
