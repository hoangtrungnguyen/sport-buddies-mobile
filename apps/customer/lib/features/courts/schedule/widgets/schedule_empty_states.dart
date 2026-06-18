// Empty-state widgets for the venue schedule: tap hint and disabled CTA.
// Extracted from court_schedule_overview_screen.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class EmptyHintCard extends StatelessWidget {
  const EmptyHintCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        border: Border.all(color: const Color(0xFFFDE68A)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.touch_app_outlined,
            size: 20,
            color: Color(0xFFB45309),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).scheduleTapHint,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context).scheduleMultiHint,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyCta extends StatelessWidget {
  const EmptyCta({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  AppLocalizations.of(context).schedulePickAtLeastOne,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: null,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD1D5DB),
              disabledBackgroundColor: const Color(0xFFE5E7EB),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              AppLocalizations.of(context).scheduleContinue,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
