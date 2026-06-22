// Sent → waiting/declined → confirmed status timeline for the awaiting-owner
// step. Extracted from step_3_awaiting.dart.

import 'package:customer/features/court/theme/app_tokens.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class AwaitingStatusTimeline extends StatelessWidget {
  const AwaitingStatusTimeline({
    super.key,
    required this.sentAt,
    required this.declined,
  });

  final String sentAt;
  final bool declined;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _TimelineItem(
          kind: _NodeKind.done,
          title: l10n.wizardTimelineSent,
          time: sentAt,
        ),
        _TimelineItem(
          kind: declined ? _NodeKind.declined : _NodeKind.active,
          title: declined
              ? l10n.wizardTimelineDeclined
              : l10n.wizardTimelineWaiting,
          time: declined ? '' : l10n.wizardWaitingShort,
        ),
        _TimelineItem(
          kind: _NodeKind.upcoming,
          title: l10n.wizardTimelineConfirmed,
          time: '',
          isLast: true,
        ),
      ],
    );
  }
}

enum _NodeKind { done, active, upcoming, declined }

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.kind,
    required this.title,
    required this.time,
    this.isLast = false,
  });

  final _NodeKind kind;
  final String title;
  final String time;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    Widget node() {
      switch (kind) {
        case _NodeKind.done:
          return _circle(
            scheme.primary,
            child: Icon(Icons.check, size: 14, color: scheme.onPrimary),
          );
        case _NodeKind.active:
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: scheme.tertiaryContainer,
                  spreadRadius: 3,
                  blurRadius: 0,
                ),
              ],
            ),
            child: _circle(
              scheme.tertiary,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: scheme.onTertiary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        case _NodeKind.declined:
          return _circle(
            scheme.error,
            child: Icon(Icons.close, size: 14, color: scheme.onError),
          );
        case _NodeKind.upcoming:
          return _circle(scheme.surfaceContainerHighest);
      }
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              node(),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: scheme.outlineVariant),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16, top: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: text.labelLarge),
                  if (time.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: text.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontFeatures: AppTokens.tnum,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(Color color, {Widget? child}) => Container(
    width: 24,
    height: 24,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    child: child,
  );
}
