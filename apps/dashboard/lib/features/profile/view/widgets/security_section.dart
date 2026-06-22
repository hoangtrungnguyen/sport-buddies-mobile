import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../model/profile_models.dart';
import '../../util/profile_format.dart';
import 'profile_section.dart';

/// "Tuỳ chọn & bảo mật" — two optimistic [_SwitchRow]s (2FA, email notif) over
/// tappable nav rows (password, devices, language).
class SecuritySection extends StatelessWidget {
  const SecuritySection({
    super.key,
    required this.profile,
    required this.onTwoFactor,
    required this.onEmailNotif,
    required this.onPlaceholderTap,
  });

  final OwnerProfile profile;
  final ValueChanged<bool> onTwoFactor;
  final ValueChanged<bool> onEmailNotif;

  /// Out-of-scope nav rows fire this (password / devices / language).
  final ValueChanged<String> onPlaceholderTap;

  @override
  Widget build(BuildContext context) {
    final changed = profile.passwordChangedAt;
    return ProfileSection(
      icon: Symbols.shield,
      title: 'Tuỳ chọn & bảo mật',
      rows: [
        _SwitchRow(
          icon: Symbols.encrypted,
          title: 'Xác thực 2 lớp',
          description: 'Bảo vệ tài khoản bằng mã OTP khi đăng nhập',
          value: profile.twoFactor,
          onChanged: onTwoFactor,
        ),
        _SwitchRow(
          icon: Symbols.mark_email_unread,
          title: 'Thông báo qua email',
          description: 'Nhận email khi có đặt sân hoặc thay đổi quan trọng',
          value: profile.emailNotif,
          onChanged: onEmailNotif,
        ),
        InfoRow(
          icon: Symbols.password,
          label: 'Mật khẩu',
          value: changed == null
              ? 'Chưa đổi'
              : 'Đổi lần cuối ${dayMonthYear(changed)}',
          muted: true,
          editable: true,
          onTap: () => onPlaceholderTap('Đổi mật khẩu'),
          semanticsLabel: 'profile-row-password',
        ),
        InfoRow(
          icon: Symbols.devices,
          label: 'Thiết bị đăng nhập',
          value: '${profile.activeDevices} thiết bị đang hoạt động',
          muted: true,
          trailing: const _Chevron(),
          onTap: () => onPlaceholderTap('Thiết bị đăng nhập'),
          semanticsLabel: 'profile-row-devices',
        ),
        InfoRow(
          icon: Symbols.language,
          label: 'Ngôn ngữ',
          value: 'Tiếng Việt',
          muted: true,
          trailing: const _Chevron(),
          onTap: () => onPlaceholderTap('Ngôn ngữ'),
          semanticsLabel: 'profile-row-language',
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();
  @override
  Widget build(BuildContext context) {
    return Icon(Symbols.chevron_right,
        size: 22, color: Theme.of(context).colorScheme.onSurfaceVariant);
  }
}
