// Profile menu building blocks: settings card, rows, divider and the
// language picker (row + bottom sheet). Extracted from profile_screen.dart.

import 'package:customer/core/l10n/locale_cubit.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class RowDivider extends StatelessWidget {
  const RowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      color: Color(0xFFE5E7EB),
    );
  }
}

class ProfileMenuRow extends StatelessWidget {
  const ProfileMenuRow({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF374151)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                ],
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 8),
              Text(
                value!,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFFD1D5DB)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Language row
// ---------------------------------------------------------------------------

class LanguageMenuRow extends StatelessWidget {
  const LanguageMenuRow({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        final isVi = locale.languageCode == 'vi';
        return ProfileMenuRow(
          icon: Icons.language_outlined,
          label: l10n.language,
          subtitle: isVi ? l10n.languageVietnamese : l10n.languageEnglish,
          value: isVi ? 'VI' : 'EN',
          onTap: () => _showLanguagePicker(context, isVi, l10n),
        );
      },
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    bool isVi,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => BlocProvider.value(
        value: context.read<LocaleCubit>(),
        child: _LanguagePickerSheet(l10n: l10n),
      ),
    );
  }
}

class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        final isVi = locale.languageCode == 'vi';
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 16),
            _LangOption(
              code: 'VI',
              label: l10n.languageVietnamese,
              selected: isVi,
              onTap: () {
                context.read<LocaleCubit>().setLocale(const Locale('vi'));
                Navigator.of(context).pop();
              },
            ),
            _LangOption(
              code: 'EN',
              label: l10n.languageEnglish,
              selected: !isVi,
              onTap: () {
                context.read<LocaleCubit>().setLocale(const Locale('en'));
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.code,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF16A34A);
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: selected ? primary : const Color(0xFFF3F4F6),
        child: Text(
          code,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF374151),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: selected
          ? const Icon(Icons.check, color: primary, size: 20)
          : null,
      onTap: onTap,
    );
  }
}

// ---------------------------------------------------------------------------
// Edit personal info bottom sheet (name + phone)
// ---------------------------------------------------------------------------
