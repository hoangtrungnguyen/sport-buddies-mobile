import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../../bloc/requests_bloc.dart';

class RequestsEmptyView extends StatelessWidget {
  const RequestsEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'requests-empty',
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 56),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.inbox_rounded,
                  size: 32, color: AppColors.primary),
            ),
            const SizedBox(height: 18),
            Text(
              'Chưa có đơn đặt sân nào',
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Các đơn đặt sân trong ngày sẽ hiển thị ở đây.',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5, color: AppColors.neutral500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class RequestsFailureView extends StatelessWidget {
  const RequestsFailureView({super.key, required this.message});
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
          Semantics(
            label: 'requests-retry-btn',
            button: true,
            child: OutlinedButton(
              onPressed: () =>
                  context.read<RequestsBloc>().add(const RequestsEvent.refreshed()),
              child: const Text('Thử lại'),
            ),
          ),
        ],
      ),
    );
  }
}
