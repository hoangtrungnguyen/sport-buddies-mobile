import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../../setup/bloc/court_bloc.dart';
import '../../setup/bloc/court_event.dart';
import '../../setup/bloc/court_state.dart';
import '../../setup/model/owner_court.dart';

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

class CourtsScreen extends StatelessWidget {
  const CourtsScreen({super.key});

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
          context.read<CourtBloc>().add(const CourtEvent.loadRequested());
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sân của tôi',
                          style: GoogleFonts.sora(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quản lý danh sách sân và thông tin chi tiết.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Thêm sân mới'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      textStyle: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                    onPressed: () => context.push('/courts/new'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // List
              switch (state) {
                CourtInitial() || CourtLoading() => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    ),
                  ),
                CourtLoaded(:final courts) when courts.isEmpty =>
                  _EmptyState(
                    onAdd: () => context.push('/courts/new'),
                  ),
                CourtLoaded(:final courts) => Column(
                    children: courts
                        .map((c) => _CourtCard(
                              court: c,
                              onEdit: () => context.push(
                                '/courts/${c.id}/edit',
                                extra: c,
                              ),
                            ))
                        .toList(),
                  ),
                CourtFailure() => const SizedBox.shrink(),
              },
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _CourtCard extends StatelessWidget {
  const _CourtCard({required this.court, required this.onEdit});
  final OwnerCourt court;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final vnd = NumberFormat('#,###', 'vi_VN');
    final color = _kSportColors[court.primarySport] ?? AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neutral200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: court.isActive ? color : AppColors.neutral300,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        court.name,
                        style: GoogleFonts.sora(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: court.isActive
                              ? AppColors.neutral900
                              : AppColors.neutral400,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                    if (!court.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.neutral100,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          'Tạm ngưng',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${court.primarySport} · ${vnd.format(court.pricePerHour)}đ/giờ · ${court.capacity} người',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.neutral500,
                  ),
                ),
                if (court.address != null &&
                    court.address!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: AppColors.neutral400),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          court.address!,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.neutral400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: onEdit,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: AppColors.neutral700,
              side: const BorderSide(color: AppColors.neutral200),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              textStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
            child: const Text('Sửa'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.stadium_outlined,
                  size: 28, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có sân nào',
              style: GoogleFonts.sora(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tạo sân đầu tiên để bắt đầu nhận booking.',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5, color: AppColors.neutral400),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Tạo sân đầu tiên'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                textStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600, fontSize: 13.5),
              ),
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}
