import 'package:dashboard/core/widgets/button_spinner.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Active/inactive switch row shown in edit mode.
class ActiveToggle extends StatelessWidget {
  const ActiveToggle({
    super.key,
    required this.isActive,
    required this.saving,
    required this.onChanged,
  });
  final bool isActive;
  final bool saving;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trạng thái hoạt động',
                    style: Theme.of(context).textTheme.titleSmall),
                Text(
                  isActive
                      ? 'Sân đang hoạt động — khách có thể đặt.'
                      : 'Sân đang tạm ngưng — khách không thể đặt.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Semantics(
            label: 'court-active-toggle',
            toggled: isActive,
            child: Switch(
              value: isActive,
              onChanged: saving ? null : onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pinned bottom action bar with cancel + submit buttons.
class StickyFooter extends StatelessWidget {
  const StickyFooter({
    super.key,
    required this.saving,
    required this.isEdit,
    required this.onCancel,
    required this.onSubmit,
  });
  final bool saving;
  final bool isEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      // heightFactor:1 makes this shrink-wrap the button row's height. Without
      // it, Center fills the bottomSheet's loose vertical constraints and the
      // footer balloons into a full-height white box over the form.
      child: Align(
        alignment: Alignment.center,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Row(
            children: [
              TextButton(onPressed: onCancel, child: const Text('Huỷ')),
              const Spacer(),
              Semantics(
                label: 'court-form-submit-btn',
                button: true,
                child: FilledButton.icon(
                  icon: saving
                      ? const ButtonSpinner()
                      : const Icon(Symbols.check, size: 18),
                  label: Text(isEdit ? 'Lưu thay đổi' : 'Tạo sân'),
                  onPressed: onSubmit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline error banner shown at the top of the form on validation/save failure.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.message, {super.key});
  final String message;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Symbols.error, size: 18, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onErrorContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
