import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../../model/owner_court.dart';

String _fmtHour(int h) => '${h.toString().padLeft(2, '0')}:00';

/// One court tile in the Setup grid: status dot + name/address, an
/// "Ngưng hoạt động" badge when inactive, the operating-hours chip, and the
/// Sửa / Ngưng-Kích hoạt actions. Inactive courts render on the muted surface.
class CourtSetupCard extends StatelessWidget {
  const CourtSetupCard({
    super.key,
    required this.court,
    required this.onEdit,
    required this.onToggleActive,
  });

  final OwnerCourt court;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
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
            _nameRow(),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.neutral100),
            const SizedBox(height: 12),
            _infoChips(),
            const SizedBox(height: 14),
            _actions(),
          ],
        ),
      ),
    );
  }

  /// Status dot + name/address, with the "Ngưng hoạt động" badge when inactive.
  Widget _nameRow() {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: court.isActive ? AppColors.primary : AppColors.neutral300,
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
              if (court.address != null && court.address!.isNotEmpty)
                Text(
                  court.address!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: AppColors.neutral500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        if (!court.isActive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
    );
  }

  /// Operating-hours chip (the only chip for now).
  Widget _infoChips() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _Chip(
          icon: Icons.access_time_rounded,
          label: '${_fmtHour(court.openHour)} – ${_fmtHour(court.closeHour)}',
        ),
      ],
    );
  }

  /// Sửa + Ngưng/Kích hoạt action buttons.
  Widget _actions() {
    return Row(
      children: [
        const Spacer(),
        OutlinedButton.icon(
          icon: const Icon(Icons.edit_outlined, size: 14),
          label: const Text('Sửa'),
          style: _actionStyle(
            foreground: AppColors.neutral700,
            side: const BorderSide(color: AppColors.neutral200),
          ),
          onPressed: onEdit,
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          style: _actionStyle(
            foreground:
                court.isActive ? AppColors.danger : AppColors.primary,
            side: BorderSide(
              color: court.isActive
                  ? AppColors.danger.withValues(alpha: 0.4)
                  : AppColors.primary.withValues(alpha: 0.4),
            ),
          ),
          onPressed: onToggleActive,
          child: Text(court.isActive ? 'Ngưng' : 'Kích hoạt'),
        ),
      ],
    );
  }

  /// Shared outlined-action button style — the two buttons differ only in
  /// [foreground] colour and [side].
  ButtonStyle _actionStyle({
    required Color foreground,
    required BorderSide side,
  }) {
    return OutlinedButton.styleFrom(
      foregroundColor: foreground,
      side: side,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600, fontSize: 13),
    );
  }
}

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
