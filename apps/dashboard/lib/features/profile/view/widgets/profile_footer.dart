import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Footer: "Đăng xuất" + danger "Xoá tài khoản" text buttons over a centered
/// version line.
class ProfileFooter extends StatelessWidget {
  const ProfileFooter({
    super.key,
    required this.onSignOut,
    required this.onDeleteAccount,
  });

  final VoidCallback onSignOut;
  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: onSignOut,
          icon: const Icon(Symbols.logout, size: 18),
          label: const Text('Đăng xuất'),
        ),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: onDeleteAccount,
          icon: const Icon(Symbols.delete_forever, size: 18),
          label: const Text('Xoá tài khoản'),
          style: TextButton.styleFrom(foregroundColor: scheme.error),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'SportBuddies cho Chủ sân · v2.4.0 · Điều khoản & Bảo mật',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

/// Error-toned confirm before any destructive account action.
Future<bool> confirmDeleteAccount(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final scheme = Theme.of(ctx).colorScheme;
      return AlertDialog(
        title: const Text('Xoá tài khoản?'),
        content: const Text(
          'Hành động này không thể hoàn tác. Toàn bộ dữ liệu sân, lịch và '
          'lịch sử đặt sẽ bị xoá vĩnh viễn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            child: const Text('Xoá tài khoản'),
          ),
        ],
      );
    },
  );
  return ok ?? false;
}
