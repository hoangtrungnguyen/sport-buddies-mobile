import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../model/profile_models.dart';
import 'widgets/edit_profile_dialog.dart';
import 'widgets/profile_footer.dart';
import 'widgets/profile_hero_card.dart';
import 'widgets/profile_info_sections.dart';
import 'widgets/profile_stat_tiles.dart';
import 'widgets/security_section.dart';
import 'widgets/subscription_card.dart';

/// Hồ sơ chủ sân (Owner profile). Read-first, edit-on-tap single column inside
/// the existing app shell; the only real mutation is the edit-profile dialog.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: switch (state) {
            ProfileInitial() || ProfileLoading() =>
              const Center(child: CircularProgressIndicator()),
            ProfileLoaded(:final profile, :final stats) =>
              _Loaded(profile: profile, stats: stats),
            ProfileFailure(:final message) =>
              Center(child: Text('Lỗi: $message')),
          },
        );
      },
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.profile, required this.stats});

  final OwnerProfile profile;
  final ProfileStats stats;

  static const _gap = SizedBox(height: 28);

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _outOfScope(BuildContext context, String what) =>
      _snack(context, '$what — ngoài phạm vi prototype');

  Future<void> _edit(BuildContext context) async {
    final bloc = context.read<ProfileBloc>();
    final draft = await EditProfileDialog.show(context, profile);
    if (draft == null || !context.mounted) return;
    bloc.add(ProfileEvent.editSubmitted(draft));
    _snack(context, 'Đã cập nhật hồ sơ');
  }

  Future<void> _signOut(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Không thể đăng xuất, thử lại sau.')),
      );
      return;
    }
    router.go('/login');
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await confirmDeleteAccount(context);
    if (!confirmed || !context.mounted) return;
    _outOfScope(context, 'Xoá tài khoản');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final hPad = width < 720 ? 16.0 : 32.0;
    final bloc = context.read<ProfileBloc>();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileHeroCard(
                profile: profile,
                clusters: stats.clusters,
                onEdit: () => _edit(context),
                onChangeAvatar: () => _outOfScope(context, 'Đổi ảnh đại diện'),
              ),
              _gap,
              ProfileStatTiles(stats: stats),
              _gap,
              ContactSection(profile: profile, onEdit: () => _edit(context)),
              _gap,
              BusinessSection(
                profile: profile,
                onDetails: () => _outOfScope(context, 'Chi tiết doanh nghiệp'),
              ),
              _gap,
              PayoutSection(
                profile: profile,
                onChangeAccount: () => _outOfScope(context, 'Đổi tài khoản'),
              ),
              _gap,
              SubscriptionCard(
                plan: profile.plan,
                onUpgrade: () => _outOfScope(context, 'Nâng cấp gói'),
              ),
              _gap,
              SecuritySection(
                profile: profile,
                onTwoFactor: (v) =>
                    bloc.add(ProfileEvent.twoFactorToggled(v)),
                onEmailNotif: (v) =>
                    bloc.add(ProfileEvent.emailNotifToggled(v)),
                onPlaceholderTap: (what) => _outOfScope(context, what),
              ),
              _gap,
              ProfileFooter(
                onSignOut: () => _signOut(context),
                onDeleteAccount: () => _deleteAccount(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
