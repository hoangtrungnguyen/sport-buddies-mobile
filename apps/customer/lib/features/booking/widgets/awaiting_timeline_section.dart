// Vertical status timeline (sent / waiting / confirmed) for the awaiting-
// confirmation screen, plus its private timeline-item row.
// Extracted from awaiting_confirmation_screen.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimelineSection extends StatelessWidget {
  const TimelineSection({super.key, required this.submittedAt});

  final DateTime submittedAt;

  static final _timeFmt = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TimelineItem(
          done: true,
          label: l10n.wizardTimelineSent,
          time: _timeFmt.format(submittedAt),
        ),
        _TimelineItem(
          active: true,
          label: l10n.wizardTimelineWaiting,
          time: l10n.wizardWaitingShort,
        ),
        _TimelineItem(
          label: l10n.wizardTimelineConfirmed,
          time: '',
          isLast: true,
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.label,
    required this.time,
    this.done = false,
    this.active = false,
    this.isLast = false,
  });

  final String label;
  final String time;
  final bool done;
  final bool active;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final Color dotColor = done
        ? const Color(0xFF16A34A)
        : active
        ? const Color(0xFFCA8A04)
        : const Color(0xFFE5E7EB);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                  border: active
                      ? Border.all(color: const Color(0xFFFEF9C3), width: 3)
                      : null,
                ),
                child: done
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : active
                    ? const Center(
                        child: SizedBox(
                          width: 6,
                          height: 6,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
              if (!isLast)
                Container(width: 2, height: 32, color: const Color(0xFFE5E7EB)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: done || active
                        ? const Color(0xFF111827)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
                if (time.isNotEmpty)
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
