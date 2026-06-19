import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../../setup/bloc/court_bloc.dart';
import '../../setup/bloc/court_event.dart';
import '../../setup/bloc/court_state.dart';
import 'widgets/settings_sections.dart';

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
      listener: _onCourtState,
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pageHeader(),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _toc(context),
                  const SizedBox(width: 24),
                  Expanded(child: _sections()),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Surface court-load failures as a snackbar and re-request the data.
  void _onCourtState(BuildContext context, CourtState state) {
    if (state is CourtFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.read<CourtBloc>().add(const CourtEvent.loadRequested());
    }
  }

  /// Title + subtitle, auto-save badge and the restore-defaults button.
  Widget _pageHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _headerText()),
        const SizedBox(width: 16),
        _autoSaveBadge(),
        const SizedBox(width: 10),
        _restoreButton(),
      ],
    );
  }

  Widget _headerText() {
    return Column(
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
                fontSize: 13.5, color: AppColors.neutral500),
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
    );
  }

  Widget _autoSaveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
    );
  }

  Widget _restoreButton() {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.neutral700,
        side: const BorderSide(color: AppColors.neutral200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600, fontSize: 13),
      ),
      child: const Text('Khôi phục mặc định'),
    );
  }

  /// Left-hand table-of-contents that scrolls to / navigates between sections.
  Widget _toc(BuildContext context) {
    return SizedBox(
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
          TocItem(
            icon: Icons.check_circle_outline,
            label: 'Tự động duyệt',
            active: false,
            onTap: () => context.go('/courts'),
          ),
          TocItem(
            icon: Icons.refresh_outlined,
            label: 'Đặt lịch cố định',
            active: _activeToc == 1,
            onTap: () => _scrollTo(_fixedKey, 1),
          ),
          TocItem(
            icon: Icons.access_time_outlined,
            label: 'Phản hồi tự động',
            active: _activeToc == 2,
            onTap: () => _scrollTo(_responseKey, 2),
          ),
          TocItem(
            icon: Icons.notifications_outlined,
            label: 'Thông báo',
            active: _activeToc == 3,
            onTap: () => _scrollTo(_notifyKey, 3),
          ),
          TocItem(
            icon: Icons.stadium_outlined,
            label: 'Sân & Khu sân',
            active: false,
            onTap: () => context.go('/courts'),
          ),
        ],
      ),
    );
  }

  /// Right-hand settings section cards (auto-approve + coming-soon placeholders
  /// + courts link).
  Widget _sections() {
    return Column(
      children: [
        AutoApproveMovedCard(key: _autoApproveKey),
        const SizedBox(height: 16),
        PlaceholderSection(
          key: _fixedKey,
          icon: Icons.refresh_outlined,
          title: 'Đặt lịch cố định',
          desc:
              'Cho phép khách đăng ký slot lặp lại hàng tuần. Phù hợp đội nhóm, doanh nghiệp.',
          comingSoon: true,
        ),
        const SizedBox(height: 16),
        PlaceholderSection(
          key: _responseKey,
          icon: Icons.access_time_outlined,
          title: 'Phản hồi tự động',
          desc: 'Quy tắc tự động xử lý khi bạn không phản hồi kịp thời.',
          comingSoon: true,
        ),
        const SizedBox(height: 16),
        PlaceholderSection(
          key: _notifyKey,
          icon: Icons.notifications_outlined,
          title: 'Thông báo cho bạn',
          desc: 'Cách bạn nhận thông báo về yêu cầu đặt sân mới.',
          comingSoon: true,
        ),
        const SizedBox(height: 16),
        CourtsLinkCard(),
      ],
    );
  }
}

