// M3 Slot detail screen — SPB-035 / SPB-054.
// Design: EPIC-4 Slot Detail · Material 3 · slotDetailM3Base component.

import 'package:customer/features/slots/cubit/slot_detail_cubit.dart';
import 'package:customer/features/slots/slots_style.dart';
import 'package:customer/features/slots/widgets/slot_hero_section.dart';
import 'package:customer/features/slots/widgets/slot_time_card.dart';
import 'package:customer/features/slots/widgets/slot_players_card.dart';
import 'package:customer/features/slots/widgets/slot_host_message_card.dart';
import 'package:customer/features/slots/widgets/slot_sticky_cta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spb_core/spb_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SlotDetailScreen extends StatefulWidget {
  const SlotDetailScreen({super.key, required this.slotId});

  final String slotId;

  @override
  State<SlotDetailScreen> createState() => _SlotDetailScreenState();
}

class _SlotDetailScreenState extends State<SlotDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SlotDetailCubit>().loadSlot(widget.slotId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SlotDetailCubit, SlotDetailState>(
      listenWhen: (prev, curr) =>
          curr is SlotDetailLoaded && curr.errorMessage != null,
      listener: (context, state) {
        final msg = (state as SlotDetailLoaded).errorMessage!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      },
      builder: (context, state) => Scaffold(
        backgroundColor: mdSurface,
        appBar: AppBar(
          backgroundColor: mdSurface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: mdOnSurfaceVariant,
            onPressed: () => context.pop(),
          ),
          centerTitle: true,
          title: const Text(
            'Chi tiết slot',
            style: TextStyle(
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
        body: switch (state) {
          SlotDetailLoading() || SlotDetailInitial() => const Center(
            child: CircularProgressIndicator(),
          ),
          SlotDetailError(message: final msg) => Center(
            child: Text(msg, style: const TextStyle(color: mdOnSurfaceVariant)),
          ),
          SlotDetailLoaded(
            slot: final slot,
            joinStatus: final joinStatus,
            joining: final joining,
          ) =>
            _Body(slot: slot, joinStatus: joinStatus, joining: joining),
        },
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({
    required this.slot,
    required this.joinStatus,
    required this.joining,
  });

  final Slot slot;
  final SlotJoinStatus joinStatus;
  final bool joining;

  @override
  Widget build(BuildContext context) {
    final joined = slot.currentPlayers;
    final max = slot.maxPlayers;
    final isFull = slot.isFull;
    final empties = isFull ? 0 : max - joined;
    final currentUserId = Supabase.instance.client.auth.currentSession?.user.id;
    final isOwner = slot.hostId != null && slot.hostId == currentUserId;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeroSection(slot: slot),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TimeCard(slot: slot),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PlayersCard(
                  joined: joined,
                  max: max,
                  isFull: isFull,
                  empties: empties,
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: HostMessageCard(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        StickyCtaBar(
          isFull: isFull,
          slotId: slot.id,
          isOwner: isOwner,
          isOpen: slot.accessPolicy == 'open',
          joinStatus: joinStatus,
          joining: joining,
        ),
      ],
    );
  }
}
