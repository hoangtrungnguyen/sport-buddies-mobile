import 'package:dashboard/features/notifications/bloc/notification_bloc.dart';
import 'package:dashboard/features/notifications/bloc/notification_state.dart';
import 'package:dashboard/features/notifications/view/notification_panel.dart';
import 'package:dashboard/features/requests/bloc/requests_bloc.dart';
import 'package:dashboard/features/requests/model/booking_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Nav model
// ---------------------------------------------------------------------------

class _NavEntry {
  const _NavEntry({
    required this.icon,
    required this.label,
    required this.route,
    this.badge,
    this.warn = false,
  });
  final IconData icon;
  final String label;
  final String route;
  final int? badge;
  final bool warn;
}

const _mainNav = <_NavEntry>[
  _NavEntry(
    icon: Icons.home_outlined,
    label: 'Trang chủ',
    route: '/',
    badge: 3,
  ),
  _NavEntry(
    icon: Icons.inbox_outlined,
    label: 'Yêu cầu',
    route: '/requests',
    warn: true,
  ),
  _NavEntry(
    icon: Icons.calendar_today_outlined,
    label: 'Lịch sân',
    route: '/schedule',
  ),
  _NavEntry(
    icon: Icons.refresh_outlined,
    label: 'Lịch cố định',
    route: '/fixed',
    badge: 6,
  ),
  _NavEntry(
    icon: Icons.bar_chart_outlined,
    label: 'Thống kê',
    route: '/analytics',
  ),
  _NavEntry(
    icon: Icons.people_outlined,
    label: 'Khách hàng',
    route: '/players',
  ),
];

const _systemNav = <_NavEntry>[
  _NavEntry(
    icon: Icons.notifications_outlined,
    label: 'Thông báo',
    route: '/notifications',
    badge: 4,
    warn: true,
  ),
  _NavEntry(
    icon: Icons.settings_outlined,
    label: 'Cài đặt sân',
    route: '/settings',
  ),
  _NavEntry(
    icon: Icons.help_outline_rounded,
    label: 'Hỗ trợ',
    route: '/support',
  ),
];

const _routeTitle = <String, String>{
  '/': 'Trang chủ',
  '/requests': 'Yêu cầu đặt sân',
  '/schedule': 'Lịch sân',
  '/fixed': 'Lịch cố định',
  '/analytics': 'Thống kê',
  '/players': 'Khách hàng',
  '/notifications': 'Thông báo',
  '/settings': 'Cài đặt sân',
  '/support': 'Hỗ trợ',
};

// ---------------------------------------------------------------------------
// Shell
// ---------------------------------------------------------------------------

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _notifOpen = false;

  void _openNotif() => setState(() => _notifOpen = true);
  void _closeNotif() => setState(() => _notifOpen = false);

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final isWide = MediaQuery.sizeOf(context).width >= 1024;
    final showFab = location == '/' || location == '/requests';

    Widget shell;
    if (isWide) {
      shell = Scaffold(
        backgroundColor: AppColors.neutral50,
        body: Row(
          children: [
            _Sidebar(location: location),
            Expanded(
              child: Column(
                children: [
                  _TopBar(
                    location: location,
                    onBellTap: _openNotif,
                  ),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      shell = Scaffold(
        backgroundColor: AppColors.neutral50,
        body: Column(
          children: [
            _TopBar(
              location: location,
              isMobile: true,
              onBellTap: _openNotif,
            ),
            Expanded(child: widget.child),
          ],
        ),
        drawer: Drawer(
          backgroundColor: AppColors.surface,
          child: _Sidebar(location: location),
        ),
      );
    }

    return Stack(
      children: [
        shell,
        // Notification panel overlay
        if (_notifOpen)
          Positioned.fill(
            child: NotificationPanel(onClose: _closeNotif),
          ),
        // FAB
        if (showFab)
          Positioned(
            right: 24,
            bottom: 24,
            child: _Fab(),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// FAB
// ---------------------------------------------------------------------------

class _Fab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(14),
      elevation: 4,
      shadowColor: AppColors.primary.withValues(alpha: 0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Form đặt sân tại quầy sẽ có trong Epic Đặt Slot.',
                style: GoogleFonts.plusJakartaSans(fontSize: 13),
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Đặt sân tại quầy',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top bar
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.location,
    required this.onBellTap,
    this.isMobile = false,
  });
  final String location;
  final VoidCallback onBellTap;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final title = _routeTitle[location] ?? 'Trang chủ';

    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border:
            Border(bottom: BorderSide(color: AppColors.neutral200)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (isMobile) ...[
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded,
                    size: 20, color: AppColors.neutral700),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            const SizedBox(width: 4),
          ],

          // Breadcrumb
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chủ sân',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: AppColors.neutral500),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text('/',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, color: AppColors.neutral300)),
              ),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'SnB Đại Lộc · Q7',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          // Search (desktop)
          if (!isMobile) ...[
            _SearchBar(),
            const SizedBox(width: 12),
          ],

          _TopIconButton(
              icon: Icons.mail_outline_rounded, onTap: () {}),
          const SizedBox(width: 2),
          _BellButton(onTap: onBellTap),

          Container(
            width: 1,
            height: 28,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: AppColors.neutral200,
          ),

          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark]),
            ),
            child: Center(
              child: Text(
                'MN',
                style: GoogleFonts.sora(
                  color: Colors.white,
                  fontSize: 11.5,
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

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openSearch(context),
      child: Container(
        width: 300,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            const Icon(Icons.search_rounded,
                size: 15, color: AppColors.neutral400),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                'Tìm booking, khách hàng, mã đơn...',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5, color: AppColors.neutral400),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                  vertical: 7, horizontal: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '⌘K',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5, color: AppColors.neutral500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSearch(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black45,
      builder: (_) => const _SearchDialog(),
    );
  }
}

class _SearchDialog extends StatefulWidget {
  const _SearchDialog();

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.only(top: 80, left: 200, right: 200),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.search_rounded,
                    size: 18, color: AppColors.neutral400),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    autofocus: true,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, color: AppColors.neutral900),
                    decoration: InputDecoration(
                      hintText:
                          'Tìm booking, khách hàng, mã đơn...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 14, color: AppColors.neutral400),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      foregroundColor: AppColors.neutral500,
                      textStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12, fontWeight: FontWeight.w500)),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.neutral100),
          Container(
            height: 200,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_rounded,
                    size: 32, color: AppColors.neutral300),
                const SizedBox(height: 10),
                Text(
                  _ctrl.text.isEmpty
                      ? 'Nhập để tìm booking, khách hàng hoặc mã đơn'
                      : 'Chức năng tìm kiếm sẽ có sau khi tích hợp booking',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, color: AppColors.neutral400),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton(
      {required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: AppColors.neutral600),
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = context.select<NotificationBloc, int>(
      (bloc) => bloc.state is NotificationLoaded
          ? (bloc.state as NotificationLoaded).unreadCount
          : 0,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _TopIconButton(
          icon: Icons.notifications_outlined,
          onTap: onTap,
        ),
        if (unread > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.danger,
              ),
              child: Center(
                child: Text(
                  unread > 9 ? '9+' : unread.toString(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sidebar
// ---------------------------------------------------------------------------

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.location});
  final String location;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      color: AppColors.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'S',
                      style: GoogleFonts.sora(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SportBuddies',
                      style: GoogleFonts.sora(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        letterSpacing: -0.2,
                        color: AppColors.neutral900,
                      ),
                    ),
                    Text(
                      'Chủ sân · Quận 7',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, color: AppColors.neutral500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.neutral100),
          const SizedBox(height: 4),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionLabel('Quản lý'),
                ..._mainNav.map((e) {
                  if (e.route == '/requests') {
                    final pendingCount =
                        context.select<RequestsBloc, int>((bloc) {
                      final s = bloc.state;
                      return s is RequestsLoaded
                          ? s.requests
                              .where((r) => r.status == BookingStatus.pending)
                              .length
                          : 0;
                    });
                    return _NavItem(
                        entry: e,
                        location: location,
                        liveBadge: pendingCount > 0 ? pendingCount : null);
                  }
                  return _NavItem(entry: e, location: location);
                }),
                const SizedBox(height: 4),
                _SectionLabel('Hệ thống'),
                ..._systemNav.map(
                    (e) => _NavItem(entry: e, location: location)),
                const Spacer(),
                const Divider(height: 1, color: AppColors.neutral100),
                const SizedBox(height: 8),
                _UserCard(),
                const SizedBox(height: 8),
                _PromoBanner(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.neutral400,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.entry, required this.location, this.liveBadge});
  final _NavEntry entry;
  final String location;
  final int? liveBadge;

  bool get _active => location == entry.route;

  String get _semanticsLabel =>
      'nav-${entry.route == '/' ? 'home' : entry.route.replaceAll('/', '')}';

  @override
  Widget build(BuildContext context) {
    // GestureDetector + Semantics(onTap) reliably generates an interactive
    // flt-semantics node with aria-label, unlike Material > InkWell which
    // swallows the custom label in the semantics tree.
    return Semantics(
      label: _semanticsLabel,
      button: true,
      onTap: () => context.go(entry.route),
      child: GestureDetector(
        onTap: () => context.go(entry.route),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          decoration: BoxDecoration(
            color: _active ? AppColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                Icon(entry.icon,
                    size: 17,
                    color: _active
                        ? AppColors.primaryDark
                        : AppColors.neutral600),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    entry.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight:
                          _active ? FontWeight.w600 : FontWeight.w500,
                      color: _active
                          ? AppColors.primaryDark
                          : AppColors.neutral700,
                    ),
                  ),
                ),
                if (liveBadge != null || entry.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: entry.warn
                          ? AppColors.warning.withValues(alpha: 0.15)
                          : AppColors.neutral200,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      (liveBadge ?? entry.badge!).toString(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: entry.warn
                            ? AppColors.warning
                            : AppColors.neutral600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark]),
              ),
              child: Center(
                child: Text(
                  'MN',
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nguyễn Văn Minh',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Chủ sân · 5 sân',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: AppColors.neutral500),
                  ),
                ],
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () async {
                try {
                  await Supabase.instance.client.auth.signOut();
                } catch (_) {}
                if (context.mounted) context.go('/login');
              },
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.logout_outlined,
                    size: 15, color: AppColors.neutral400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFECFCCB), Color(0xFFDCFCE7)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gói miễn phí 3 tháng',
              style: GoogleFonts.sora(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF166534),
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Hết hạn 04/08/2026',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: const Color(0xFF15803D)),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Nâng cấp',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF15803D),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
