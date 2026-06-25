import 'package:dashboard/core/identity/owner_identity.dart';
import 'package:dashboard/features/profile/util/profile_format.dart';
import 'package:dashboard/features/setup/bloc/court_bloc.dart';
import 'package:dashboard/features/setup/bloc/court_state.dart';
import 'package:dashboard/features/subscription/cubit/subscription_cubit.dart';
import 'package:dashboard/features/subscription/cubit/subscription_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Bottom of the navigation drawer: the signed-in owner card + trial banner.
class NavDrawerFooter extends StatelessWidget {
  const NavDrawerFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: const [
          _UserCard(),
          SizedBox(height: 10),
          _TrialCard(),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final user = Supabase.instance.client.auth.currentUser;
    final name = ownerDisplayName(user) ?? 'Chủ sân';
    final initials = ownerInitials(name);

    final courtCount = context.select<CourtBloc, int>((bloc) {
      final s = bloc.state;
      return s is CourtLoaded ? s.courts.length : 0;
    });
    final subtitle = courtCount > 0 ? 'Chủ sân · $courtCount sân' : 'Chủ sân';

    // The owner row IS the entry to the profile screen, and shows the active
    // (secondaryContainer) indicator while that route is open.
    final active = GoRouterState.of(context).matchedLocation == '/profile';
    final fg = active ? scheme.onSecondaryContainer : null;

    return Material(
      color: active ? scheme.secondaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Non-clickable while active (already on the profile route).
        onTap: active ? null : () => context.go('/profile'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: scheme.tertiaryContainer,
                child: Text(
                  initials,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onTertiaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(color: fg),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: fg ?? scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Symbols.logout, size: 20),
                color: fg ?? scheme.onSurfaceVariant,
                tooltip: 'Đăng xuất',
                onPressed: () async {
                  try {
                    await Supabase.instance.client.auth.signOut();
                  } catch (_) {}
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrialCard extends StatelessWidget {
  const _TrialCard();

  @override
  Widget build(BuildContext context) {
    // Same source as the profile "Gói dịch vụ" card (shell-scoped cubit). Hidden
    // until loaded so the banner never flashes stale/placeholder text.
    final subscription = context.select<SubscriptionCubit, SubscriptionState>(
      (c) => c.state,
    );
    if (subscription is! SubscriptionLoaded) return const SizedBox.shrink();
    final plan = subscription.subscription;

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.name,
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.hasWindow
                      ? 'Hết hạn ${dayMonthYear(plan.expiresAt!)}'
                      : 'Không giới hạn',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onPrimaryContainer),
                ),
              ),
              InkWell(
                onTap: () {},
                child: Text(
                  'Nâng cấp',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
