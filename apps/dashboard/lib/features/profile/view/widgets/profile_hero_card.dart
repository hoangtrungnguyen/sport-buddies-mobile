import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../model/profile_models.dart';
import '../../util/profile_format.dart';
import 'profile_section.dart';

/// Hero card (header style = cover): a 116px gradient cover band with the 92px
/// avatar overlapping it, then name + "Đã xác minh" badge + meta, and the tonal
/// "Chỉnh sửa hồ sơ" button.
class ProfileHeroCard extends StatelessWidget {
  const ProfileHeroCard({
    super.key,
    required this.profile,
    required this.clusters,
    required this.onEdit,
    required this.onChangeAvatar,
    this.uploadingAvatar = false,
  });

  final OwnerProfile profile;

  /// Cluster count for the meta row ("· N cụm sân") — sourced from
  /// [ProfileStats.clusters] so it stays in step with the stat tile.
  final int clusters;

  final VoidCallback onEdit;
  final VoidCallback onChangeAvatar;

  /// True while an avatar upload is in flight — shows a spinner over the avatar.
  final bool uploadingAvatar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 135° spark gradient cover band (decorative).
          Container(
            height: 116,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [scheme.secondaryContainer, scheme.tertiaryContainer],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: const Offset(0, -44),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _Avatar(
                        initials: profile.initials,
                        avatarUrl: profile.avatarUrl,
                        uploading: uploadingAvatar,
                        onChange: onChangeAvatar,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _NameBlock(profile: profile),
                        ),
                      ),
                    ],
                  ),
                ),
                // Pull content back up under the overlapping avatar.
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MetaRow(profile: profile, clusters: clusters),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.tonalIcon(
                          onPressed: onEdit,
                          icon: const Icon(Symbols.edit, size: 18),
                          label: const Text('Chỉnh sửa hồ sơ'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initials,
    required this.avatarUrl,
    required this.uploading,
    required this.onChange,
  });
  final String initials;
  final String? avatarUrl;
  final bool uploading;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasImage = avatarUrl != null && avatarUrl!.isNotEmpty;
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              shape: BoxShape.circle,
              border: Border.all(color: scheme.surfaceContainerLowest, width: 4),
              image: hasImage
                  ? DecorationImage(
                      image: NetworkImage(avatarUrl!), fit: BoxFit.cover)
                  : null,
            ),
            alignment: Alignment.center,
            child: hasImage
                ? null
                : Text(
                    initials,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: scheme.onTertiaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          // Dim + spinner while an upload is in flight.
          if (uploading)
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
            ),
          // 30px camera FAB-style overlay, bottom-right.
          Positioned(
            right: -2,
            bottom: -2,
            child: Material(
              color: scheme.surfaceContainerLowest,
              shape: const CircleBorder(),
              elevation: 1,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: uploading ? null : onChange,
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: Icon(Symbols.photo_camera,
                      size: 17, color: scheme.onSurfaceVariant),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NameBlock extends StatelessWidget {
  const _NameBlock({required this.profile});
  final OwnerProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 6,
      children: [
        Text(
          profile.name,
          style: theme.textTheme.headlineSmall,
        ),
        if (profile.verified) const StatusPill(label: 'Đã xác minh'),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.profile, required this.clusters});
  final OwnerProfile profile;
  final int clusters;

  @override
  Widget build(BuildContext context) {
    final stats = '${profile.role} · $clusters cụm sân';
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        _MetaItem(icon: Symbols.stadium, text: stats),
        _MetaItem(icon: Symbols.location_on, text: profile.area),
        _MetaItem(
          icon: Symbols.schedule,
          text: 'Tham gia từ ${monthYear(profile.joinedAt)}',
        ),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: scheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          text,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
