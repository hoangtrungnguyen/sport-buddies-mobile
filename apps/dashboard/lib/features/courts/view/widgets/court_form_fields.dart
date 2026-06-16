import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../util/court_format.dart';

// ---------------------------------------------------------------------------
// Field with AI-fill marking + one-shot pulse
// ---------------------------------------------------------------------------

class AiField extends StatelessWidget {
  const AiField({
    super.key,
    required this.controller,
    required this.label,
    required this.fieldKey,
    required this.aiFilled,
    required this.pulse,
    required this.onManualEdit,
    this.leading,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.readOnly = false,
    this.helperText,
  });

  final TextEditingController controller;
  final String label;
  final String fieldKey;
  final Set<String> aiFilled;
  final Set<String> pulse;
  final ValueChanged<String> onManualEdit;
  final IconData? leading;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  /// When true the field can't be edited — its value is derived elsewhere.
  final bool readOnly;

  /// Static helper shown when the field is not AI-filled (e.g. "auto from URL").
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isAi = aiFilled.contains(fieldKey);
    final isPulsing = pulse.contains(fieldKey);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1600),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isPulsing
            ? scheme.tertiaryContainer
            : scheme.tertiaryContainer.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onChanged: (_) {
          if (aiFilled.contains(fieldKey)) onManualEdit(fieldKey);
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: leading != null ? Icon(leading, size: 20) : null,
          filled: readOnly,
          helperText: isAi ? '✦ Điền bởi AI — hãy kiểm tra lại' : helperText,
          helperStyle: TextStyle(color: scheme.tertiary),
          helperMaxLines: 2,
        ),
        validator: validator,
      ),
    );
  }
}

/// Tertiary "AI filled" note for non-field targets (amenities, hours).
class AiHint extends StatelessWidget {
  const AiHint({super.key});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Symbols.auto_awesome, size: 14, color: scheme.tertiary),
          const SizedBox(width: 6),
          Text(
            'AI đã điền — hãy kiểm tra lại',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.tertiary),
          ),
        ],
      ),
    );
  }
}

/// Responsive two-column row that stacks below 560px width.
class TwoCol extends StatelessWidget {
  const TwoCol({super.key, required this.left, required this.right});
  final Widget left;
  final Widget right;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 560) {
          return Column(
            children: [left, const SizedBox(height: 16), right],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 16),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

class HourDropdown extends StatelessWidget {
  const HourDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final IconData icon;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
      // 0–24 (00:00–24:00) so early-open / late-close venues are representable
      // and AI-extracted hours always have a matching dropdown entry.
      items: List.generate(25, (i) => i)
          .map((h) => DropdownMenuItem(value: h, child: Text(formatHour(h))))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
