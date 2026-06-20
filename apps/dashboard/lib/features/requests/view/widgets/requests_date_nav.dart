import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../../bloc/requests_bloc.dart';
import '../../requests_logic.dart';

class RequestsDateNav extends StatelessWidget {
  const RequestsDateNav({super.key, required this.day});
  final DateTime day;

  Future<void> _pick(BuildContext context) async {
    final bloc = context.read<RequestsBloc>();
    final picked = await showDatePicker(
      context: context,
      initialDate: day,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) bloc.add(RequestsEvent.dateChanged(picked));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RequestsBloc>();
    return Row(
      children: [
        _stepper(context, bloc),
        const SizedBox(width: 10),
        _todayButton(bloc),
      ],
    );
  }

  /// Prev / date-picker / next, grouped in a bordered pill.
  Widget _stepper(BuildContext context, RequestsBloc bloc) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NavArrow(
            icon: Icons.chevron_left_rounded,
            semantics: 'requests-prev-day-btn',
            onTap: () => bloc.add(RequestsEvent.dateChanged(addDays(day, -1))),
          ),
          _dateButton(context),
          _NavArrow(
            icon: Icons.chevron_right_rounded,
            semantics: 'requests-next-day-btn',
            onTap: () => bloc.add(RequestsEvent.dateChanged(addDays(day, 1))),
          ),
        ],
      ),
    );
  }

  /// Calendar icon + day heading; opens the date picker on tap.
  Widget _dateButton(BuildContext context) {
    return Semantics(
      label: 'requests-date-picker-btn',
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _pick(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 14, color: AppColors.neutral500),
              const SizedBox(width: 8),
              Text(
                dayHeading(day),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// "Hôm nay" — jump the list back to today.
  Widget _todayButton(RequestsBloc bloc) {
    return Semantics(
      label: 'requests-today-btn',
      button: true,
      child: OutlinedButton(
        onPressed: () => bloc.add(RequestsEvent.dateChanged(DateTime.now())),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.neutral700,
          side: const BorderSide(color: AppColors.neutral200),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          textStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600, fontSize: 12.5),
        ),
        child: const Text('Hôm nay'),
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow(
      {required this.icon, required this.onTap, required this.semantics});
  final IconData icon;
  final VoidCallback onTap;
  final String semantics;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semantics,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: AppColors.neutral600),
        ),
      ),
    );
  }
}
