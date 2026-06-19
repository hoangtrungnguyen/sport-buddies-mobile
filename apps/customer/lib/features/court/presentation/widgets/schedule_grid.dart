// Courts × hours schedule grid with selectable cells.
// Extracted from schedule_page.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/court.dart';
import '../../domain/schedule.dart';
import '../../theme/app_tokens.dart';
import '../schedule_grid_ref.dart';

class ScheduleGrid extends StatelessWidget {
  const ScheduleGrid({
    super.key,
    required this.center,
    required this.day,
    required this.selection,
    required this.onToggle,
  });

  final SportsCenter center;
  final ScheduleDay day;
  final Set<GridRef> selection;
  final void Function(String courtId, int hour) onToggle;

  static const _labelWidth = 92.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: AppTokens.radiusMd,
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _headerRow(scheme),
          for (var ri = 0; ri < center.courts.length; ri++)
            _courtRow(context, scheme, center.courts[ri], ri),
        ],
      ),
    );
  }

  Widget _headerRow(ColorScheme scheme) {
    return Container(
      color: scheme.surfaceContainerLow,
      child: Row(
        children: [
          const SizedBox(width: _labelWidth, height: 36),
          for (final h in day.hourLabels)
            Expanded(
              child: Center(
                child: Text(
                  h.substring(0, 5),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                    fontFeatures: AppTokens.tnum,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _courtRow(
    BuildContext context,
    ColorScheme scheme,
    Court court,
    int rowIndex,
  ) {
    final statuses = day.rows[court.id] ?? const [];
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: rowIndex == 0
              ? BorderSide.none
              : BorderSide(color: scheme.outlineVariant),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Court-name link → 09 (edge E6).
            SizedBox(
              width: _labelWidth,
              child: InkWell(
                onTap: () => context.push('/browse/court/${court.id}/slots'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          court.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: scheme.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: scheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 14,
                        color: scheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            for (var ci = 0; ci < statuses.length; ci++)
              Expanded(
                child: _Cell(
                  status: statuses[ci],
                  selected: selection.contains(GridRef(court.id, ci)),
                  onTap: statuses[ci] == CellStatus.open
                      ? () => onToggle(court.id, ci)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.status, required this.selected, this.onTap});

  final CellStatus status;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    late final Color bg;
    late final Widget glyph;
    if (selected) {
      bg = scheme.primaryContainer;
      glyph = Icon(Icons.check, size: 16, color: scheme.onPrimaryContainer);
    } else {
      switch (status) {
        case CellStatus.open:
          bg = scheme.surfaceContainerLowest;
          glyph = Text(
            '•',
            style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant),
          );
        case CellStatus.booked:
          bg = scheme.surfaceContainerHigh;
          glyph = Text(
            AppLocalizations.of(context).scheduleBookedShort,
            style: TextStyle(fontSize: 10, color: scheme.outline),
          );
        case CellStatus.blocked:
          bg = scheme.surfaceContainerHigh;
          glyph = Text(
            '—',
            style: TextStyle(fontSize: 12, color: scheme.outline),
          );
      }
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        height: AppTokens.gridCellHeight,
        margin: selected ? const EdgeInsets.all(1) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: selected
              ? const BorderRadius.all(Radius.circular(AppTokens.cornerXs))
              : null,
          border: selected
              ? Border.all(color: scheme.primary, width: 2)
              : Border(left: BorderSide(color: scheme.outlineVariant)),
        ),
        alignment: Alignment.center,
        child: glyph,
      ),
    );
  }
}
