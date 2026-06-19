// Participant management screen — host-only view for an open group slot.
// Covers: OwnerManage (pre-game) — slot summary, confirmed roster,
// join-request approve/reject, and an animated toast.

import 'package:customer/features/slots/cubit/participant_management_cubit.dart';
import 'package:customer/features/slots/cubit/participant_management_state.dart';
import 'package:customer/features/slots/slots_style.dart';
import 'package:customer/features/slots/widgets/participant_slot_summary_card.dart';
import 'package:customer/features/slots/widgets/confirmed_players_card.dart';
import 'package:customer/features/slots/widgets/participant_join_requests_card.dart';
import 'package:customer/features/slots/widgets/participant_toast.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class ParticipantManagementScreen extends StatelessWidget {
  const ParticipantManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mdSurface,
      appBar: AppBar(
        backgroundColor: mdSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: mdOnSurfaceVariant,
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).slotsManageTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: mdOnSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            color: mdOnSurfaceVariant,
            onPressed: () {},
          ),
        ],
      ),
      body:
          BlocConsumer<ParticipantManagementCubit, ParticipantManagementState>(
            listener: (context, state) {
              if (state is ParticipantManagementLoaded &&
                  state.toastMessage != null) {
                Future.delayed(const Duration(milliseconds: 2600), () {
                  if (context.mounted) {
                    context.read<ParticipantManagementCubit>().clearToast();
                  }
                });
              }
            },
            builder: (context, state) {
              return switch (state) {
                ParticipantManagementLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                ParticipantManagementError() => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: mdOnSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ParticipantManagementLoaded() => _LoadedBody(state: state),
              };
            },
          ),
    );
  }
}

// ── Loaded body ───────────────────────────────────────────────────────────────

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.state});

  final ParticipantManagementLoaded state;

  @override
  Widget build(BuildContext context) {
    final isShowingToast = state.toastMessage != null;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SlotSummaryCard(slot: state.slot),
              const SizedBox(height: 12),
              ConfirmedPlayersCard(
                confirmed: state.confirmed,
                maxPlayers: state.maxPlayers,
              ),
              const SizedBox(height: 12),
              JoinRequestsCard(
                pending: state.pending,
                confirmed: state.confirmed,
                maxPlayers: state.maxPlayers,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        // Animated toast
        AnimatedPositioned(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutBack,
          bottom: isShowingToast ? 20 : -80,
          left: 16,
          right: 16,
          child: ToastWidget(
            message: state.toastMessage ?? '',
            isDanger: state.toastDanger,
          ),
        ),
      ],
    );
  }
}
