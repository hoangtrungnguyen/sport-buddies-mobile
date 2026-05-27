import 'package:customer/core/l10n/locale_cubit.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'profile_avatar_picker.dart';
import 'profile_cubit.dart';
import 'profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<ProfileCubit>();
    if (cubit.state is ProfileLoading) {
      cubit.loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (_, current) =>
            current is ProfileUpdateError ||
            current is ProfileLoaded,
        listener: (context, state) {
          if (state is ProfileUpdateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        buildWhen: (_, current) => current is! ProfileUpdateError,
        builder: (context, state) {
          return switch (state) {
            ProfileLoading() ||
            ProfileSaving() =>
              const Center(child: CircularProgressIndicator()),
            ProfileLoaded(
              :final fullName,
              :final phone,
              :final email,
              :final avatarUrl,
            ) =>
              _ProfileBody(
                fullName: fullName,
                phone: phone,
                email: email,
                avatarUrl: avatarUrl,
              ),
            ProfileError(:final message) => Center(child: Text(message)),
            ProfileUpdateError() => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.fullName,
    required this.phone,
    required this.email,
    this.avatarUrl,
  });

  final String fullName;
  final String phone;
  final String email;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileHeader(
            fullName: fullName,
            phone: phone,
            email: email,
            avatarUrl: avatarUrl,
            onEditTap: () => _showEditNameSheet(context),
            onAvatarTap: () => _pickAndUploadAvatar(context),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProfileMenuCard(
                  children: [
                    _ProfileMenuRow(
                      icon: Icons.person_outline,
                      label: l10n.profilePersonalInfo,
                      subtitle: l10n.profilePersonalInfoSub,
                      onTap: () => _showEditNameSheet(context),
                    ),
                    const _RowDivider(),
                    _LanguageMenuRow(l10n: l10n),
                    const _RowDivider(),
                    _ProfileMenuRow(
                      icon: Icons.notifications_none,
                      label: l10n.profileNotificationsLabel,
                      subtitle: l10n.profileNotificationsLabelSub,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.profileActivitySection,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                _ProfileMenuCard(
                  children: [
                    _ProfileMenuRow(
                      icon: Icons.favorite_border,
                      label: l10n.profileFavourites,
                      value: '0',
                      onTap: () {},
                    ),
                    const _RowDivider(),
                    _ProfileMenuRow(
                      icon: Icons.group_outlined,
                      label: l10n.profilePlayTogether,
                      value: '0',
                      onTap: () {},
                    ),
                    const _RowDivider(),
                    _ProfileMenuRow(
                      icon: Icons.card_giftcard_outlined,
                      label: l10n.profileReferral,
                      subtitle: l10n.profileReferralSub,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.profileSupportSection,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                _ProfileMenuCard(
                  children: [
                    _ProfileMenuRow(
                      icon: Icons.help_outline,
                      label: l10n.profileHelpCenter,
                      onTap: () {},
                    ),
                    const _RowDivider(),
                    _ProfileMenuRow(
                      icon: Icons.description_outlined,
                      label: l10n.profileTerms,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextButton(
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) context.go('/login');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    minimumSize: const Size.fromHeight(44),
                  ),
                  child: Text(
                    l10n.profileSignOut,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'SportBuddies v1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadAvatar(BuildContext context) async {
    final result = await pickAvatarFile();
    if (result == null || !context.mounted) return;
    final (bytes, fileName, mimeType) = result;
    context
        .read<ProfileCubit>()
        .uploadAvatar(bytes, fileName, mimeType);
  }

  void _showEditNameSheet(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => BlocProvider.value(
        value: cubit,
        child: _EditNameSheet(currentName: fullName),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.onEditTap,
    required this.onAvatarTap,
    this.avatarUrl,
  });

  final String fullName;
  final String phone;
  final String email;
  final String? avatarUrl;
  final VoidCallback onEditTap;
  final VoidCallback onAvatarTap;

  String _getInitials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDCFCE7), Color(0xFFF9FAFB)],
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, topPad + 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).profileTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.22,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 22),
                onPressed: () {},
                color: const Color(0xFF374151),
                tooltip: 'Settings',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              GestureDetector(
                onTap: onAvatarTap,
                child: CircleAvatar(
                  radius: 36,
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  backgroundColor: Colors.transparent,
                  child: avatarUrl == null
                      ? Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF16A34A),
                                Color(0xFF4ADE80),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(fullName),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 28,
                              ),
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName.isEmpty ? '—' : fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            email,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (phone.isNotEmpty) ...[
                          const Text(
                            ' · ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            phone,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Menu card + row components
// ---------------------------------------------------------------------------

class _ProfileMenuCard extends StatelessWidget {
  const _ProfileMenuCard({required this.children});

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

class _RowDivider extends StatelessWidget {
  const _RowDivider();

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

class _ProfileMenuRow extends StatelessWidget {
  const _ProfileMenuRow({
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
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
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

class _LanguageMenuRow extends StatelessWidget {
  const _LanguageMenuRow({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        final isVi = locale.languageCode == 'vi';
        return _ProfileMenuRow(
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
// Edit name bottom sheet
// ---------------------------------------------------------------------------

class _EditNameSheet extends StatefulWidget {
  const _EditNameSheet({required this.currentName});

  final String currentName;

  @override
  State<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends State<_EditNameSheet> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.nameEditTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              key: const Key('editNameField'),
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.labelFullName,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                final isSaving = state is ProfileSaving;
                return FilledButton(
                  key: const Key('saveNameButton'),
                  onPressed: isSaving
                      ? null
                      : () {
                          final name = _nameController.text.trim();
                          if (name.isEmpty) return;
                          context.read<ProfileCubit>().updateFullName(name);
                        },
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.save),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
