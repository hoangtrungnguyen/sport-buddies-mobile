// Profile header: avatar, name, contact rows and the edit affordance.
// Extracted from profile_screen.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
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
            children: [
              if (context.canPop())
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 22),
                  onPressed: () => context.pop(),
                  color: const Color(0xFF374151),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).profileTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.22,
                  ),
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
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl!)
                      : null,
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
                              colors: [Color(0xFF16A34A), Color(0xFF4ADE80)],
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
                    const SizedBox(height: 6),
                    DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF374151),
                      ),
                      child: Row(
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: '12 ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: AppLocalizations.of(context)
                                      .profileGamesCount(12)
                                      .replaceFirst('12 ', '')
                                      .replaceFirst('12', ''),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '4.8 ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: '⭐'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: '3 ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: AppLocalizations.of(context)
                                      .profileFavouritesCount(3)
                                      .replaceFirst('3 ', '')
                                      .replaceFirst('3', ''),
                                ),
                              ],
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
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Menu card + row components
// ---------------------------------------------------------------------------
