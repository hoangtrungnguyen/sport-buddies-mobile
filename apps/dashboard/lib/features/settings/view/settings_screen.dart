import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../../setup/bloc/court_bloc.dart';
import '../../setup/bloc/court_event.dart';
import '../../setup/bloc/court_state.dart';
import '../../setup/model/owner_court.dart';

// Section anchor keys
final _autoApproveKey = GlobalKey();
final _fixedKey = GlobalKey();
final _responseKey = GlobalKey();
final _notifyKey = GlobalKey();

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _scrollCtrl = ScrollController();
  int _activeToc = 0;

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key, int index) {
    setState(() => _activeToc = index);
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CourtBloc, CourtState>(
      listener: (context, state) {
        if (state is CourtFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context
              .read<CourtBloc>()
              .add(const CourtEvent.loadRequested());
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cài đặt sân',
                          style: GoogleFonts.sora(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                color: AppColors.neutral500),
                            children: const [
                              TextSpan(
                                  text:
                                      'Quản lý cách hệ thống xử lý yêu cầu đặt sân, lịch cố định, và thông báo · '),
                              TextSpan(
                                text: 'SnB Đại Lộc · Q7',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.neutral700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Tự động lưu',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.neutral700,
                      side: const BorderSide(color: AppColors.neutral200),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      textStyle: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    child: const Text('Khôi phục mặc định'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Two-column layout: TOC + content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOC
                  SizedBox(
                    width: 220,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                          child: Text(
                            'MỤC CÀI ĐẶT',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.neutral400,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        _TocItem(
                          icon: Icons.check_circle_outline,
                          label: 'Tự động duyệt',
                          active: _activeToc == 0,
                          onTap: () =>
                              _scrollTo(_autoApproveKey, 0),
                        ),
                        _TocItem(
                          icon: Icons.refresh_outlined,
                          label: 'Đặt lịch cố định',
                          active: _activeToc == 1,
                          onTap: () => _scrollTo(_fixedKey, 1),
                        ),
                        _TocItem(
                          icon: Icons.access_time_outlined,
                          label: 'Phản hồi tự động',
                          active: _activeToc == 2,
                          onTap: () =>
                              _scrollTo(_responseKey, 2),
                        ),
                        _TocItem(
                          icon: Icons.notifications_outlined,
                          label: 'Thông báo',
                          active: _activeToc == 3,
                          onTap: () =>
                              _scrollTo(_notifyKey, 3),
                        ),
                        _TocItem(
                          icon: Icons.stadium_outlined,
                          label: 'Sân & Khu sân',
                          active: false,
                          onTap: () => context.go('/courts'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Sections
                  Expanded(
                    child: Column(
                      children: [
                        _AutoApproveSection(
                          key: _autoApproveKey,
                          state: state,
                        ),
                        const SizedBox(height: 16),
                        _PlaceholderSection(
                          key: _fixedKey,
                          icon: Icons.refresh_outlined,
                          title: 'Đặt lịch cố định',
                          desc:
                              'Cho phép khách đăng ký slot lặp lại hàng tuần. Phù hợp đội nhóm, doanh nghiệp.',
                          comingSoon: true,
                        ),
                        const SizedBox(height: 16),
                        _PlaceholderSection(
                          key: _responseKey,
                          icon: Icons.access_time_outlined,
                          title: 'Phản hồi tự động',
                          desc:
                              'Quy tắc tự động xử lý khi bạn không phản hồi kịp thời.',
                          comingSoon: true,
                        ),
                        const SizedBox(height: 16),
                        _PlaceholderSection(
                          key: _notifyKey,
                          icon: Icons.notifications_outlined,
                          title: 'Thông báo cho bạn',
                          desc:
                              'Cách bạn nhận thông báo về yêu cầu đặt sân mới.',
                          comingSoon: true,
                        ),
                        const SizedBox(height: 16),
                        _CourtsLinkCard(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// TOC item
// ---------------------------------------------------------------------------

class _TocItem extends StatelessWidget {
  const _TocItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: active ? AppColors.primaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                Icon(icon,
                    size: 14,
                    color: active
                        ? AppColors.primaryDark
                        : AppColors.neutral500),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
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

// ---------------------------------------------------------------------------
// Placeholder section (for future epics)
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Auto-approve section (OWNER-44/45)
// ---------------------------------------------------------------------------

class _AutoApproveSection extends StatefulWidget {
  const _AutoApproveSection({super.key, required this.state});
  final CourtState state;

  @override
  State<_AutoApproveSection> createState() => _AutoApproveSectionState();
}

class _AutoApproveSectionState extends State<_AutoApproveSection> {
  String? _selectedCourtId;

  @override
  void didUpdateWidget(_AutoApproveSection old) {
    super.didUpdateWidget(old);
    // Reset selection when courts reload.
    if (widget.state is CourtLoaded && old.state is! CourtLoaded) {
      _selectedCourtId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final courts = switch (widget.state) {
      CourtLoaded(:final courts) => courts,
      _ => <OwnerCourt>[],
    };
    final loading = widget.state is CourtLoading;

    // Default to the first court when none is selected.
    final court = courts.isEmpty
        ? null
        : courts.firstWhere(
            (c) => c.id == (_selectedCourtId ?? courts.first.id),
            orElse: () => courts.first,
          );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neutral200),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_circle_outline,
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tự động duyệt đặt sân một lần',
                      style: GoogleFonts.sora(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                    Text(
                      'Chỉ áp dụng cho đặt sân một lần. Lịch cố định vẫn cần duyệt thủ công.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.neutral500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (courts.isEmpty && !loading) ...[
            const SizedBox(height: 16),
            Text(
              'Tạo ít nhất một sân để cài đặt tự động duyệt.',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: AppColors.neutral400),
            ),
          ] else ...[
            // Court selector (multi-court owners).
            if (courts.length > 1) ...[
              const SizedBox(height: 16),
              Text(
                'Sân',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: 6),
              Semantics(
                label: 'settings-auto-approve-court-selector',
                child: DropdownButton<String>(
                  value: court?.id,
                  isExpanded: true,
                  underline: Container(
                      height: 1, color: AppColors.neutral200),
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5, color: AppColors.neutral900),
                  items: courts
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ))
                      .toList(),
                  onChanged: (id) =>
                      setState(() => _selectedCourtId = id),
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Toggle row.
            if (court != null)
              _AutoApproveToggle(
                court: court,
                loading: loading,
                onChanged: (value) {
                  context.read<CourtBloc>().add(
                        CourtEvent.autoApproveToggled(court.id,
                            value: value),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Đã lưu cài đặt'),
                      backgroundColor: AppColors.neutral800,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }
}

class _AutoApproveToggle extends StatelessWidget {
  const _AutoApproveToggle({
    required this.court,
    required this.loading,
    required this.onChanged,
  });
  final OwnerCourt court;
  final bool loading;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: court.autoApproveSingle
            ? AppColors.primaryLight
            : AppColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: court.autoApproveSingle
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.neutral200,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  court.autoApproveSingle ? 'Đang bật' : 'Đang tắt',
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: court.autoApproveSingle
                        ? AppColors.primaryDark
                        : AppColors.neutral700,
                  ),
                ),
                Text(
                  court.autoApproveSingle
                      ? 'Yêu cầu đặt sân một lần sẽ được duyệt tự động.'
                      : 'Bạn cần duyệt từng yêu cầu thủ công.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: court.autoApproveSingle
                        ? AppColors.primary
                        : AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            label: 'settings-auto-approve-toggle',
            toggled: court.autoApproveSingle,
            child: Switch(
              value: court.autoApproveSingle,
              onChanged: loading ? null : onChanged,
              activeTrackColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _PlaceholderSection extends StatelessWidget {
  const _PlaceholderSection({
    super.key,
    required this.icon,
    required this.title,
    required this.desc,
    this.comingSoon = false,
  });
  final IconData icon;
  final String title;
  final String desc;
  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.neutral500),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.sora(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.neutral500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            if (comingSoon)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'Sắp ra mắt',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Courts link card — navigates to /courts
// ---------------------------------------------------------------------------

class _CourtsLinkCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.go('/courts'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.stadium_outlined,
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sân & Khu sân',
                      style: GoogleFonts.sora(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                    Text(
                      'Quản lý sân, khu sân, giờ hoạt động và giá.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppColors.neutral400),
            ],
          ),
        ),
      ),
    );
  }
}
