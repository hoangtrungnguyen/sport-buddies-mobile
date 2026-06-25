import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/feature_flags/feature_flag_service.dart';
import '../../../core/di/injection.dart';
import '../../billing/view/checkout_dialog.dart';
import '../../subscription/cubit/subscription_cubit.dart';
import '../../subscription/cubit/subscription_state.dart';
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
    return BlocConsumer<ProfileBloc, ProfileState>(
      // Avatar upload is a one-off side effect → snackbar on success/failure.
      listenWhen: (prev, next) =>
          prev is ProfileLoaded &&
          next is ProfileLoaded &&
          prev.avatar != next.avatar,
      listener: (context, state) {
        if (state is! ProfileLoaded) return;
        final msg = switch (state.avatar) {
          AvatarUpload.success => 'Đã cập nhật ảnh đại diện',
          AvatarUpload.error => 'Không thể cập nhật ảnh — vui lòng thử lại.',
          AvatarUpload.idle || AvatarUpload.uploading => null,
        };
        if (msg != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(msg)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: switch (state) {
            ProfileInitial() || ProfileLoading() =>
              const Center(child: CircularProgressIndicator()),
            ProfileLoaded(:final profile, :final stats, :final avatar) =>
              _Loaded(profile: profile, stats: stats, avatar: avatar),
            ProfileFailure(:final message) =>
              Center(child: Text('Lỗi: $message')),
          },
        );
      },
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({
    required this.profile,
    required this.stats,
    required this.avatar,
  });

  final OwnerProfile profile;
  final ProfileStats stats;
  final AvatarUpload avatar;

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

  /// Pick a JPEG/PNG and hand the bytes to the bloc for upload. `withData`
  /// ensures bytes are available on web (no file path there).
  Future<void> _changeAvatar(BuildContext context) async {
    final bloc = context.read<ProfileBloc>();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;
    bloc.add(ProfileEvent.avatarChangeRequested(bytes, filename: file.name));
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
                uploadingAvatar: avatar == AvatarUpload.uploading,
                onEdit: () => _edit(context),
                onChangeAvatar: () => _changeAvatar(context),
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
              if (sl<FeatureFlagService>()
                  .isEnabled('profile_payout_account')) ...[
                _gap,
                PayoutSection(
                  profile: profile,
                  onChangeAccount: () => _outOfScope(context, 'Đổi tài khoản'),
                ),
              ],
              _gap,
              BlocBuilder<SubscriptionCubit, SubscriptionState>(
                builder: (context, state) => switch (state) {
                  SubscriptionLoaded(:final subscription) => SubscriptionCard(
                      plan: subscription,
                      onUpgrade: () => showCheckoutDialog(context),
                    ),
                  SubscriptionFailure() => const SizedBox.shrink(),
                  _ => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                },
              ),
              if (sl<FeatureFlagService>()
                  .isEnabled('profile_security_section')) ...[
                _gap,
                SecuritySection(
                  profile: profile,
                  onTwoFactor: (v) =>
                      bloc.add(ProfileEvent.twoFactorToggled(v)),
                  onEmailNotif: (v) =>
                      bloc.add(ProfileEvent.emailNotifToggled(v)),
                  onPlaceholderTap: (what) => _outOfScope(context, what),
                ),
              ],
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
