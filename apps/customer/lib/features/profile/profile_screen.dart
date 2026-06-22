import 'package:customer/core/l10n/error_messages.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'profile_avatar_picker.dart';
import 'profile_cubit.dart';
import 'profile_state.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_menu.dart';
import 'widgets/edit_personal_info_sheet.dart';

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
            current is ProfileUpdateError || current is ProfileLoaded,
        listener: (context, state) {
          if (state is ProfileUpdateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  appErrorMessage(AppLocalizations.of(context), state.message),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        buildWhen: (_, current) => current is! ProfileUpdateError,
        builder: (context, state) {
          return switch (state) {
            ProfileLoading() ||
            ProfileSaving() => const Center(child: CircularProgressIndicator()),
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
            ProfileError(:final message) => Center(
              child: Text(appErrorMessage(AppLocalizations.of(context), message)),
            ),
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
          ProfileHeader(
            fullName: fullName,
            phone: phone,
            email: email,
            avatarUrl: avatarUrl,
            onEditTap: () =>
                _showEditPersonalInfoSheet(context, fullName, phone),
            onAvatarTap: () => _pickAndUploadAvatar(context),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileMenuCard(
                  children: [
                    ProfileMenuRow(
                      icon: Icons.person_outline,
                      label: l10n.profilePersonalInfo,
                      subtitle: l10n.profilePersonalInfoSub,
                      onTap: () =>
                          _showEditPersonalInfoSheet(context, fullName, phone),
                    ),
                    const RowDivider(),
                    LanguageMenuRow(l10n: l10n),
                    const RowDivider(),
                    ProfileMenuRow(
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
                ProfileMenuCard(
                  children: [
                    ProfileMenuRow(
                      icon: Icons.favorite_border,
                      label: l10n.profileFavourites,
                      value: '0',
                      onTap: () {},
                    ),
                    const RowDivider(),
                    ProfileMenuRow(
                      icon: Icons.group_outlined,
                      label: l10n.profilePlayTogether,
                      value: '0',
                      onTap: () {},
                    ),
                    const RowDivider(),
                    ProfileMenuRow(
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
                ProfileMenuCard(
                  children: [
                    ProfileMenuRow(
                      icon: Icons.help_outline,
                      label: l10n.profileHelpCenter,
                      onTap: () {},
                    ),
                    const RowDivider(),
                    ProfileMenuRow(
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
    try {
      final result = await pickAvatarFile();
      if (result == null || !context.mounted) return;
      final (bytes, fileName, mimeType) = result;
      context.read<ProfileCubit>().uploadAvatar(bytes, fileName, mimeType);
    } catch (e) {
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context);
      final String errorMsg;
      if (e == 'invalid_format') {
        errorMsg = l10n.errorAvatarFormat;
      } else if (e == 'file_too_large') {
        errorMsg = l10n.errorAvatarSize;
      } else {
        errorMsg = e.toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    }
  }

  void _showEditPersonalInfoSheet(
    BuildContext context,
    String currentName,
    String currentPhone,
  ) {
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
        child: EditPersonalInfoSheet(
          currentName: currentName,
          currentPhone: currentPhone,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------
