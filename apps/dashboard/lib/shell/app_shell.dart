import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

/// Authenticated app shell — sidebar + content area.
/// Populated screen by screen as epics are implemented.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 1024;

    if (isWide) {
      return Scaffold(
        backgroundColor: AppColors.neutral50,
        body: Row(
          children: [
            _Sidebar(),
            const Expanded(child: _Placeholder()),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: const _Placeholder(),
      drawer: Drawer(child: _Sidebar()),
    );
  }
}

class _Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      color: AppColors.surface,
      child: Column(
        children: [
          // Brand
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
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
                        color: AppColors.primary.withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
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
                        fontSize: 15,
                        letterSpacing: -0.1,
                        color: AppColors.neutral900,
                      ),
                    ),
                    Text(
                      'Chủ sân',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.neutral100),
          const SizedBox(height: 8),
          // Placeholder nav items — filled as epics ship
          _NavItem(icon: Icons.home_outlined, label: 'Trang chủ', active: true),
          _NavItem(icon: Icons.inbox_outlined, label: 'Yêu cầu'),
          _NavItem(icon: Icons.calendar_today_outlined, label: 'Lịch sân'),
          _NavItem(icon: Icons.bar_chart_outlined, label: 'Thống kê'),
          _NavItem(icon: Icons.people_outlined, label: 'Khách hàng'),
          const Spacer(),
          const Divider(height: 1, color: AppColors.neutral100),
          _NavItem(icon: Icons.notifications_outlined, label: 'Thông báo'),
          _NavItem(icon: Icons.settings_outlined, label: 'Cài đặt sân'),
          _NavItem(icon: Icons.logout_outlined, label: 'Đăng xuất'),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: active ? AppColors.primaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: active ? AppColors.primaryDark : AppColors.neutral700,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight:
                          active ? FontWeight.w600 : FontWeight.w500,
                      color: active
                          ? AppColors.primaryDark
                          : AppColors.neutral700,
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

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.construction_rounded, size: 40, color: AppColors.neutral300),
          SizedBox(height: 12),
          Text(
            'Dashboard — đang được phát triển',
            style: TextStyle(color: AppColors.neutral500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
