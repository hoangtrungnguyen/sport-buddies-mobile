import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../service/court_info_parser_service.dart';
import '../../util/court_format.dart';

class _ReviewRow {
  const _ReviewRow(this.key, this.label, this.value);
  final String key;
  final String label;
  final String value;
}

List<_ReviewRow> _reviewRows(CourtParseResult r) {
  final rows = <_ReviewRow>[];
  void add(String k, String label, String? v) {
    if (v != null && v.trim().isNotEmpty) rows.add(_ReviewRow(k, label, v));
  }

  add('name', 'Tên sân', r.name);
  add('address', 'Địa chỉ', r.address);
  if (r.lat != null && r.lng != null) {
    add('location', 'Toạ độ',
        '${r.lat!.toStringAsFixed(5)}, ${r.lng!.toStringAsFixed(5)}');
  } else if (r.googleMapsUrl != null) {
    add('location', 'Google Maps', r.googleMapsUrl);
  }
  add('phone', 'Điện thoại', r.phone);
  add('description', 'Mô tả', r.description);
  if (r.amenities.isNotEmpty) {
    add('amenities', 'Tiện ích', r.amenities.join(' · '));
  }
  if (r.openHour != null && r.closeHour != null) {
    add('hours', 'Giờ hoạt động',
        '${formatHour(r.openHour!)}–${formatHour(r.closeHour!)}');
  }
  if (r.venues.isNotEmpty) {
    add(
      'venues',
      'Sân con',
      '${r.venues.length} sân: ${r.venues.map((v) => '${v.name} (${v.sportType} · ${formatPricePerHour(v.pricePerHour)})').join(', ')}',
    );
  }
  return rows;
}

class ReviewView extends StatelessWidget {
  const ReviewView({
    super.key,
    required this.result,
    required this.checked,
    required this.onToggle,
    required this.onBack,
    required this.onApply,
  });

  final CourtParseResult result;
  final Map<String, bool> checked;
  final ValueChanged<String> onToggle;
  final VoidCallback onBack;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final rows = _reviewRows(result);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Symbols.fact_check, size: 20, color: scheme.tertiary),
                    const SizedBox(width: 8),
                    Text('Kiểm tra trước khi điền',
                        style: theme.textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Bỏ chọn những dòng không đúng — chỉ các dòng được chọn sẽ điền vào form.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'AI không tìm thấy thông tin nào trong nội dung này.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < rows.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          _ReviewTile(
                            row: rows[i],
                            checked: checked[rows[i].key] ?? true,
                            onToggle: () => onToggle(rows[i].key),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        _ReviewFooter(onBack: onBack, onApply: onApply),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.row,
    required this.checked,
    required this.onToggle,
  });
  final _ReviewRow row;
  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onToggle,
      child: Opacity(
        opacity: checked ? 1 : 0.4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                checked ? Symbols.check_circle : Symbols.radio_button_unchecked,
                size: 22,
                color: checked ? scheme.primary : scheme.outline,
                fill: checked ? 1 : 0,
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 96,
                child: Text(
                  row.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  row.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    decoration: checked ? null : TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewFooter extends StatelessWidget {
  const _ReviewFooter({required this.onBack, required this.onApply});
  final VoidCallback onBack;
  final VoidCallback onApply;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Row(
        children: [
          TextButton(onPressed: onBack, child: const Text('Sửa lại')),
          const Spacer(),
          FilledButton.icon(
            icon: const Icon(Symbols.auto_awesome, size: 18),
            label: const Text('Điền vào form'),
            onPressed: onApply,
          ),
        ],
      ),
    );
  }
}
