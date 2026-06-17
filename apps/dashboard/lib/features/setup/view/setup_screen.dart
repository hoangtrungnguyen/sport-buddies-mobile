import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../bloc/court_bloc.dart';
import '../bloc/court_event.dart';
import '../bloc/court_state.dart';
import '../model/owner_court.dart';
import 'widgets/court_setup_card.dart';

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
                onPressed: () => context.push('/courts/new'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (courts.isEmpty)
            _EmptyState(onAdd: () => context.push('/courts/new'))
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: courts
                  .map((c) => SizedBox(
                        width: 360,
                        child: CourtSetupCard(
                          court: c,
                          onEdit: () => context.push('/courts/${c.id}/edit', extra: c),
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
