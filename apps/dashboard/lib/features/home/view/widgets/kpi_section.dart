import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../model/home_models.dart';

class KpiRow extends StatelessWidget {
  const KpiRow({super.key, required this.kpis});
  final List<HomeKpi> kpis;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int cols = 4;
        if (constraints.maxWidth < 1080) cols = 2;
        if (constraints.maxWidth < 560) cols = 1;

        // Drive a fixed, compact card height so cards stay dense regardless of
        // column width — a tall aspect ratio left a lot of empty space.
        const spacing = 12.0;
        const cardHeight = 150.0;
        final colWidth = (constraints.maxWidth - spacing * (cols - 1)) / cols;

        return GridView.count(
          crossAxisCount: cols,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: colWidth / cardHeight,
          children: [for (final kpi in kpis) _KpiCard(kpi: kpi)],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.kpi});
  final HomeKpi kpi;

  Color _getToneColor(KpiTone tone, ColorScheme scheme) {
    return switch (tone) {
      KpiTone.primary => scheme.primaryContainer,
      KpiTone.tertiary => scheme.tertiaryContainer,
      KpiTone.secondary => scheme.secondaryContainer,
      KpiTone.warn => const Color(0xFFFEF3C0),
    };
  }

  Color _getToneForeground(KpiTone tone, ColorScheme scheme) {
    return switch (tone) {
      KpiTone.primary => scheme.onPrimaryContainer,
      KpiTone.tertiary => scheme.onTertiaryContainer,
      KpiTone.secondary => scheme.onSecondaryContainer,
      KpiTone.warn => const Color(0xFF574500),
    };
  }

  IconData _getIcon(String icon) {
    return switch (icon) {
      'payments' => Symbols.payments,
      'event_available' => Symbols.event_available,
      'donut_large' => Symbols.donut_large,
      'inbox' => Symbols.inbox,
      _ => Symbols.info,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(scheme),
            const SizedBox(height: 8),
            Text(kpi.label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 2),
            _valueText(theme, scheme),
            if (kpi.progress != null) ...[
              const SizedBox(height: 6),
              _progressBar(scheme),
            ],
            if (kpi.sub != null) ...[
              const SizedBox(height: 4),
              Text(kpi.sub!,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }

  /// Tone-coloured icon badge with the optional delta chip trailing it.
  Widget _header(ColorScheme scheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _getToneColor(kpi.tone, scheme),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getIcon(kpi.icon),
            size: 18,
            color: _getToneForeground(kpi.tone, scheme),
          ),
        ),
        if (kpi.delta != null)
          _DeltaChip(
            delta: kpi.delta!,
            isUp: kpi.deltaUp,
            tone: kpi.tone,
          ),
      ],
    );
  }

  /// The big value with its optional unit suffix.
  Widget _valueText(ThemeData theme, ColorScheme scheme) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: kpi.value,
            style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600, fontSize: 24, height: 1.1),
          ),
          if (kpi.unit != null) ...[
            const TextSpan(text: ' '),
            TextSpan(
              text: kpi.unit!,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }

  /// Percentage progress bar — only rendered when [HomeKpi.progress] is set.
  Widget _progressBar(ColorScheme scheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: kpi.progress! / 100,
        minHeight: 5,
        backgroundColor: scheme.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation(scheme.primary),
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({
    required this.delta,
    required this.isUp,
    required this.tone,
  });

  final String delta;
  final bool? isUp;
  final KpiTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg, icon) = switch (isUp) {
      true => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          Symbols.arrow_upward,
        ),
      false => (
          scheme.errorContainer,
          scheme.onErrorContainer,
          Symbols.schedule,
        ),
      null => (
          scheme.surfaceContainerHigh,
          scheme.onSurfaceVariant,
          Symbols.info,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            delta,
            style:
                TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
