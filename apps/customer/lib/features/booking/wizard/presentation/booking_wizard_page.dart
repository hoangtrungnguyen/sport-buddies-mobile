// The ONE booking-wizard route (handoff doc 03 §1). Replaces the Browse &
// Pick `/browse/booking/confirm` placeholder. Internal `currentStep` 0→3
// drives the step header + which step body renders; no four pushed routes.

import 'package:customer/features/booking/wizard/cubit/booking_wizard_cubit.dart';
import 'package:customer/features/booking/wizard/presentation/steps/step_1_confirm.dart';
import 'package:customer/features/booking/wizard/presentation/steps/step_2_play_together.dart';
import 'package:customer/features/booking/wizard/presentation/steps/step_3_awaiting.dart';
import 'package:customer/features/booking/wizard/presentation/steps/step_4_done.dart';
import 'package:customer/features/booking/wizard/presentation/widgets/wizard_stepper.dart';
import 'package:customer/features/court/theme/app_tokens.dart';
import 'package:customer/features/court/theme/browse_pick_theme.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

const _myBookingsRoute = '/bookings/upcoming';
const _mapRoute = '/';

class BookingWizardPage extends StatelessWidget {
  const BookingWizardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BrowsePickTheme(
      child: BlocConsumer<BookingWizardCubit, BookingWizardState>(
        listenWhen: (a, b) => a.effect != b.effect,
        listener: _onEffect,
        builder: (context, state) {
          final step = state.currentStep;
          return PopScope(
            // Step 2 (Play-together) back is internal → Step 1.
            canPop: step != 1,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) context.read<BookingWizardCubit>().back();
            },
            child: Scaffold(
              appBar: _buildAppBar(context, state),
              body: Column(
                children: [
                  WizardStepper(currentStep: step),
                  Expanded(child: _buildBody(context, state)),
                  _buildStickyBar(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Effects (doc 03 §3.4 / §3.5) ──────────────────────────────────────
  void _onEffect(BuildContext context, BookingWizardState state) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    switch (state.effect) {
      case WizardEffect.raceLost:
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Text(l10n.wizardRaceLost),
            backgroundColor: scheme.inverseSurface,
          ));
        context.read<BookingWizardCubit>().clearEffect();
        context.pop(); // back to the slot picker so the user can re-pick
      case WizardEffect.networkFailed:
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Text(l10n.wizardNetworkFailed),
            backgroundColor: scheme.inverseSurface,
            action: SnackBarAction(
              label: l10n.commonRetry,
              textColor: scheme.inversePrimary,
              onPressed: () => context.read<BookingWizardCubit>().submit(),
            ),
          ));
        context.read<BookingWizardCubit>().clearEffect();
      case WizardEffect.none:
        break;
    }
  }

  // ── Per-step app bar (doc 03 §5) ──────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, BookingWizardState s) {
    final cubit = context.read<BookingWizardCubit>();
    final l10n = AppLocalizations.of(context);
    final titles = [
      l10n.bookingConfirmTitle,
      l10n.wizardStepPlayTitle,
      l10n.wizardStepAwaitingTitle,
      l10n.wizardStepDone,
    ];
    final isDone = s.currentStep == 3;

    return AppBar(
      title: Text(titles[s.currentStep]),
      leading: IconButton(
        icon: Icon(isDone ? Icons.close : Icons.arrow_back),
        tooltip: isDone ? l10n.commonClose : l10n.commonBack,
        onPressed: () {
          switch (s.currentStep) {
            case 1:
              cubit.back(); // → Step 1
            case 3:
              context.go(_myBookingsRoute); // close ✕ → bookings, no re-entry
            default:
              context.pop(); // Step 1 → picker · Step 3 → leave (booking persists)
          }
        },
      ),
      actions: [
        if (s.currentStep == 1)
          TextButton(
            onPressed: s.submitting ? null : () => cubit.submit(skip: true),
            child: Text(l10n.wizardSkip),
          ),
      ],
    );
  }

  // ── Step body ─────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context, BookingWizardState s) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppTokens.motionSlow;
    final child = switch (s.currentStep) {
      0 => Step1Confirm(state: s, key: const ValueKey(0)),
      1 => Step2PlayTogether(state: s, key: const ValueKey(1)),
      2 => Step3Awaiting(state: s, key: const ValueKey(2)),
      _ => Step4Done(state: s, key: const ValueKey(3)),
    };
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: AppTokens.easing,
      transitionBuilder: (c, anim) => FadeTransition(opacity: anim, child: c),
      child: child,
    );
  }

  // ── Per-step sticky action bar (doc 01 §5) ────────────────────────────
  Widget _buildStickyBar(BuildContext context, BookingWizardState s) {
    final scheme = Theme.of(context).colorScheme;
    final cubit = context.read<BookingWizardCubit>();
    final l10n = AppLocalizations.of(context);

    Widget bar(List<Widget> children) => Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(top: BorderSide(color: scheme.outlineVariant)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Row(children: children),
        );

    Widget filled(String label, VoidCallback? onTap, {Widget? child}) => Expanded(
          child: FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 52),
              shape: const StadiumBorder(),
            ),
            child: child ?? Text(label),
          ),
        );

    Widget tonal(String label, VoidCallback? onTap) => Expanded(
          child: FilledButton.tonal(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 52),
              backgroundColor: scheme.secondaryContainer,
              foregroundColor: scheme.onSecondaryContainer,
              shape: const StadiumBorder(),
            ),
            child: Text(label),
          ),
        );

    switch (s.currentStep) {
      case 0:
        return bar([filled(l10n.bookingConfirmTitle, cubit.confirm)]);
      case 1:
        return bar([
          filled(
            l10n.wizardSaveContinue,
            s.submitting ? null : () => cubit.submit(),
            child: s.submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : null,
          ),
        ]);
      case 2:
        return bar([tonal(l10n.wizardViewBookings, () => context.go(_myBookingsRoute))]);
      default:
        return bar([
          tonal(l10n.wizardBackToMap, () => context.go(_mapRoute)),
          const SizedBox(width: 10),
          filled(l10n.wizardViewBookings, () => context.go(_myBookingsRoute)),
        ]);
    }
  }
}
