// Step 2 · Play-together — "Chơi cùng ai?" (SPB-046, handoff doc 02 Step 2).

import 'package:customer/features/booking/wizard/cubit/booking_wizard_cubit.dart';
import 'package:customer/features/booking/wizard/domain/booking.dart';
import 'package:customer/features/court/theme/app_tokens.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Step2PlayTogether extends StatelessWidget {
  const Step2PlayTogether({super.key, required this.state});

  final BookingWizardState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final count = state.slotCount;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        // 2.1 success callout
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: AppTokens.radiusMd,
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 18, color: scheme.onPrimary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.wizardSelectedSlots(count),
                        style: text.labelLarge
                            ?.copyWith(color: scheme.onPrimaryContainer)),
                    const SizedBox(height: 2),
                    Text(
                      l10n.wizardPickPlayers,
                      style: text.bodySmall
                          ?.copyWith(color: scheme.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // 2.2 intro
        Text(l10n.wizardWhoCanJoin, style: text.titleMedium),
        const SizedBox(height: 4),
        Text(
          l10n.wizardAccessApplies(count),
          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        // 2.3 access radio cards
        _AccessCard(
          selected: state.access == AccessPolicy.private,
          title: l10n.wizardPrivate,
          subtitle: l10n.wizardPrivateDesc,
          onTap: () =>
              context.read<BookingWizardCubit>().selectAccess(AccessPolicy.private),
        ),
        const SizedBox(height: 12),
        _AccessCard(
          selected: state.access == AccessPolicy.open,
          title: l10n.wizardOpen,
          subtitle: l10n.wizardOpenDesc,
          onTap: () =>
              context.read<BookingWizardCubit>().selectAccess(AccessPolicy.open),
          reveal: _MaxPlayersStepper(value: state.maxPlayers),
          revealed: state.access == AccessPolicy.open,
        ),
      ],
    );
  }
}

class _AccessCard extends StatelessWidget {
  const _AccessCard({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.reveal,
    this.revealed = false,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? reveal;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppTokens.motionMed;

    return InkWell(
      onTap: onTap,
      borderRadius: AppTokens.radiusLg,
      child: AnimatedContainer(
        duration: duration,
        curve: AppTokens.easing,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? scheme.primaryContainer : Colors.transparent,
          borderRadius: AppTokens.radiusLg,
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Radio(selected: selected),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: text.labelLarge?.copyWith(
                          color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: text.bodySmall?.copyWith(
                          color: selected
                              ? scheme.onPrimaryContainer
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (reveal != null)
              AnimatedCrossFade(
                duration: duration,
                sizeCurve: AppTokens.easing,
                crossFadeState: revealed
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: reveal,
                ),
                secondChild: const SizedBox(width: double.infinity),
              ),
          ],
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? scheme.primary : Colors.transparent,
        border: Border.all(
          color: selected ? scheme.primary : scheme.outline,
          width: 2,
        ),
      ),
      child: selected
          ? Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: scheme.onPrimary,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

class _MaxPlayersStepper extends StatelessWidget {
  const _MaxPlayersStepper({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<BookingWizardCubit>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: AppTokens.radiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.wizardMaxPlayers,
              style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Row(
            children: [
              _StepBtn(
                icon: Icons.remove,
                filled: false,
                semantic: l10n.wizardDecrease,
                onTap: value > 2 ? () => cubit.setMaxPlayers(value - 1) : null,
              ),
              const SizedBox(width: 16),
              Text(
                '$value',
                style: text.headlineSmall?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFeatures: AppTokens.tnum,
                ),
              ),
              const SizedBox(width: 16),
              _StepBtn(
                icon: Icons.add,
                filled: true,
                semantic: l10n.wizardIncrease,
                onTap: () => cubit.setMaxPlayers(value + 1),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.wizardMaxPlayersHint,
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({
    required this.icon,
    required this.filled,
    required this.semantic,
    required this.onTap,
  });

  final IconData icon;
  final bool filled;
  final String semantic;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;
    return Semantics(
      label: semantic,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTokens.radiusSm,
        // 36px control padded to a ≥44px hit area (handoff CLAUDE.md §7).
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: filled
                  ? (enabled ? scheme.primary : scheme.surfaceContainerHighest)
                  : Colors.transparent,
              borderRadius: AppTokens.radiusSm,
              border: filled ? null : Border.all(color: scheme.outlineVariant),
            ),
            child: Icon(
              icon,
              size: 20,
              color: filled
                  ? scheme.onPrimary
                  : (enabled ? scheme.onSurfaceVariant : scheme.outlineVariant),
            ),
          ),
        ),
      ),
    );
  }
}
