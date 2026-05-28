import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../bloc/court_bloc.dart';
import '../bloc/court_event.dart';
import '../bloc/court_state.dart';
import '../model/owner_court.dart';
import '../repository/owner_court_repository.dart';
import 'court_form_dialog.dart';

const _kSportColors = <String, Color>{
  'Bóng đá 5v5': Color(0xFF16A34A),
  'Bóng đá 7v7': Color(0xFF15803D),
  'Bóng đá 11v11': Color(0xFF14532D),
  'Pickleball': Color(0xFFF97316),
  'Tennis': Color(0xFFEC4899),
  'Cầu lông': Color(0xFFA855F7),
  'Bóng rổ': Color(0xFFEF4444),
  'Đa năng': Color(0xFF0EA5E9),
};

String _fmtHour(int h) => '${h.toString().padLeft(2, '0')}:00';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

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
      builder: (context, state) => switch (state) {
        CourtInitial() ||
        CourtLoading() =>
          const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
        CourtLoaded(:final courts) => _CourtList(courts: courts),
        CourtFailure(:final message) => _FailureView(message: message),
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _CourtList extends StatelessWidget {
  const _CourtList({required this.courts});
  final List<OwnerCourt> courts;

  @override
  Widget build(BuildContext context) {
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
                      'Thiết Lập Sân',
                      style: GoogleFonts.sora(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quản lý loại sân, giờ hoạt động và giá tại cơ sở của bạn.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Thêm sân mới'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                onPressed: () => _openForm(context, null),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (courts.isEmpty)
            _EmptyState(onAdd: () => _openForm(context, null))
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: courts
                  .map((c) => SizedBox(
                        width: 360,
                        child: _CourtCard(
                          court: c,
                          onEdit: () => _openForm(context, c),
                          onToggleActive: () => c.isActive
                              ? _confirmDeactivate(context, c)
                              : context.read<CourtBloc>().add(
                                    CourtEvent.reactivateRequested(c.id)),
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Future<void> _openForm(BuildContext context, OwnerCourt? court) async {
    final bloc = context.read<CourtBloc>();
    final repo = context.read<OwnerCourtRepository>();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CourtFormDialog(repository: repo, court: court),
    );
    if (result == true) {
      bloc.add(const CourtEvent.loadRequested());
    }
  }

  Future<void> _confirmDeactivate(
      BuildContext context, OwnerCourt court) async {
    final bloc = context.read<CourtBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Ngưng hoạt động "${court.name}"?',
          style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: Text(
          'Sân sẽ không hiện cho khách đặt. Lịch sử booking vẫn được giữ nguyên.',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 14, color: AppColors.neutral600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            style:
                TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Ngưng hoạt động'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      bloc.add(CourtEvent.deactivateRequested(court.id));
    }
  }
}

// ---------------------------------------------------------------------------

class _CourtCard extends StatelessWidget {
  const _CourtCard({
    required this.court,
    required this.onEdit,
    required this.onToggleActive,
  });

  final OwnerCourt court;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  Color get _color =>
      _kSportColors[court.sportType] ?? AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final vnd = NumberFormat('#,###', 'vi_VN');
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      color: court.isActive ? AppColors.surface : AppColors.neutral50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name row
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: court.isActive ? _color : AppColors.neutral300,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        court.name,
                        style: GoogleFonts.sora(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: court.isActive
                              ? AppColors.neutral900
                              : AppColors.neutral400,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        court.sportType,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!court.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.neutral200,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      'Ngưng hoạt động',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.neutral100),
            const SizedBox(height: 12),

            // Info chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _Chip(
                  icon: Icons.access_time_rounded,
                  label:
                      '${_fmtHour(court.openHour)} – ${_fmtHour(court.closeHour)}',
                ),
                _Chip(
                  icon: Icons.people_outline_rounded,
                  label: '${court.capacity} người',
                ),
                _Chip(
                  icon: Icons.payments_outlined,
                  label: '${vnd.format(court.pricePerHour)}đ/giờ',
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Actions
            Row(
              children: [
                const Spacer(),
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Sửa'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.neutral700,
                    side: const BorderSide(color: AppColors.neutral200),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    textStyle: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  onPressed: onEdit,
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: court.isActive
                        ? AppColors.danger
                        : AppColors.primary,
                    side: BorderSide(
                      color: court.isActive
                          ? AppColors.danger.withValues(alpha: 0.4)
                          : AppColors.primary.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    textStyle: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  onPressed: onToggleActive,
                  child:
                      Text(court.isActive ? 'Ngưng' : 'Kích hoạt'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.neutral500),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.neutral700,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 60),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.sports_soccer_outlined,
                size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            'Chưa có sân nào',
            style: GoogleFonts.sora(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tạo sân đầu tiên để bắt đầu nhận booking từ khách hàng.',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14, color: AppColors.neutral500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Tạo sân đầu tiên'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              textStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600, fontSize: 14),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: onAdd,
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _FailureView extends StatelessWidget {
  const _FailureView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 40, color: AppColors.danger),
          const SizedBox(height: 12),
          Text(message,
              style: GoogleFonts.plusJakartaSans(
                  color: AppColors.neutral600, fontSize: 14)),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context
                .read<CourtBloc>()
                .add(const CourtEvent.loadRequested()),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
