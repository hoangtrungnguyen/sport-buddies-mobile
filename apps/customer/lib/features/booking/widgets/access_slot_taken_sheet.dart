// Bottom sheet shown when the chosen slot was taken before confirmation.
// Extracted from access_control_screen.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class SlotTakenSheet extends StatelessWidget {
  const SlotTakenSheet({super.key, required this.onPickAnother});

  final VoidCallback onPickAnother;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 40,
                color: Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.accessSlotTakenTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.accessSlotTakenBody,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: onPickAnother,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: const Color(0xFF16A34A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                l10n.wizardPickAnotherTime,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
