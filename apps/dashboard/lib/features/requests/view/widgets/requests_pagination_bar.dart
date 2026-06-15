import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../../bloc/requests_bloc.dart';
import '../../requests_logic.dart';

class RequestsPaginationBar extends StatelessWidget {
  const RequestsPaginationBar({super.key, required this.page, required this.total});
  final int page;
  final int total;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RequestsBloc>();
    final pages = pageCount(total);
    final canPrev = page > 0;
    final canNext = page < pages - 1;
    return Row(
      children: [
        Semantics(
          label: 'requests-record-count',
          child: Text(
            recordCountLabel(page, total),
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5, color: AppColors.neutral600),
          ),
        ),
        const Spacer(),
        _PageButton(
          icon: Icons.chevron_left_rounded,
          semantics: 'requests-prev-page-btn',
          enabled: canPrev,
          onTap: () => bloc.add(RequestsEvent.pageChanged(page - 1)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Trang ${page + 1}/$pages',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral700,
            ),
          ),
        ),
        _PageButton(
          icon: Icons.chevron_right_rounded,
          semantics: 'requests-next-page-btn',
          enabled: canNext,
          onTap: () => bloc.add(RequestsEvent.pageChanged(page + 1)),
        ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.icon,
    required this.semantics,
    required this.enabled,
    required this.onTap,
  });
  final IconData icon;
  final String semantics;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semantics,
      button: true,
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Icon(icon, size: 18, color: AppColors.neutral600),
            ),
          ),
        ),
      ),
    );
  }
}
