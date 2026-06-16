// Linked 4-dot progress header — shared chrome on every step (handoff doc 02 §0).
//
// Flutter's stock Stepper can't match this look, so it's a custom Row of dots
// + connectors. The active ring and connector fill animate on advance,
// respecting reduced motion.

import 'package:customer/features/court/theme/app_tokens.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class WizardStepper extends StatelessWidget {
  const WizardStepper({super.key, required this.currentStep});

  final int currentStep; // 0..3

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final labels = [
      l10n.wizardStepConfirm,
      l10n.wizardStepPlay,
      l10n.wizardStepAwait,
      l10n.wizardStepDone,
    ];
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppTokens.motionMed;

    final children = <Widget>[];
    for (var i = 0; i < labels.length; i++) {
      if (i > 0) {
        final filled = i <= currentStep;
        children.add(Expanded(
          child: AnimatedContainer(
            duration: duration,
            curve: AppTokens.easing,
            height: 2,
            margin: const EdgeInsets.only(top: 13, left: 6, right: 6),
            decoration: BoxDecoration(
              color: filled ? scheme.primary : scheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ));
      }
      children.add(_StepNode(
        index: i,
        currentStep: currentStep,
        label: labels[i],
        duration: duration,
      ));
    }

    return Container(
      color: scheme.surface,
      padding: const EdgeInsets.fromLTRB(26, 12, 26, 30),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.index,
    required this.currentStep,
    required this.label,
    required this.duration,
  });

  final int index;
  final int currentStep;
  final String label;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final done = index < currentStep;
    final active = index == currentStep;

    final Color fill;
    final Color fg;
    Border? border;
    if (done || active) {
      fill = scheme.primary;
      fg = scheme.onPrimary;
    } else {
      fill = Colors.transparent;
      fg = scheme.onSurfaceVariant;
      border = Border.all(color: scheme.outlineVariant, width: 2);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: duration,
          curve: AppTokens.easing,
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: border,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: scheme.primaryContainer,
                      spreadRadius: 4,
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: done
              ? Icon(Icons.check, size: 14, color: fg)
              : Text(
                  '${index + 1}',
                  style: text.labelMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 64,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: text.labelMedium?.copyWith(
              fontSize: 11,
              color: active ? scheme.primary : scheme.onSurfaceVariant,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
