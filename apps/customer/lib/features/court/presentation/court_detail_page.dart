import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/court_repository.dart';
import '../data/fake_court_repository.dart';
import '../data/fake_slot_repository.dart';
import '../domain/court.dart';
import '../domain/time_slot.dart';
import '../theme/app_tokens.dart';
import '../theme/browse_pick_theme.dart';
import 'widgets/open_slot_section.dart';
import 'widgets/court_photo_carousel.dart';
import 'widgets/court_sport_chips.dart';
import 'widgets/court_title_block.dart';
import 'widgets/court_stat_cards.dart';
import 'widgets/court_info_sections.dart';

/// Screen 07 · Court detail (handoff SPB-040).
class CourtDetailPage extends StatefulWidget {
  const CourtDetailPage({
    super.key,
    required this.courtId,
    this.courtRepository,
    this.slotRepository,
  });

  final String courtId;
  final CourtRepository? courtRepository;
  final SlotRepository? slotRepository;

  @override
  State<CourtDetailPage> createState() => _CourtDetailPageState();
}

class _CourtDetailPageState extends State<CourtDetailPage> {
  late final CourtRepository _courtRepo =
      widget.courtRepository ?? FakeCourtRepository();
  late final SlotRepository _slotRepo =
      widget.slotRepository ?? FakeSlotRepository();

  late final Future<(Court, List<OpenGroupSlot>)> _future = _load();

  Future<(Court, List<OpenGroupSlot>)> _load() async {
    final results = await Future.wait([
      _courtRepo.getCourt(widget.courtId),
      _slotRepo.getOpenGroupSlots(widget.courtId),
    ]);
    return (results[0] as Court, results[1] as List<OpenGroupSlot>);
  }

  @override
  Widget build(BuildContext context) {
    return BrowsePickTheme(
      child: Scaffold(
        body: FutureBuilder<(Court, List<OpenGroupSlot>)>(
          future: _future,
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final (court, groupSlots) = snap.data!;
            return _Body(court: court, groupSlots: groupSlots);
          },
        ),
        bottomNavigationBar: _BookBar(courtId: widget.courtId),
      ),
    );
  }
}

/// Sticky "pick a slot" CTA → the slot picker for this court (edge E7).
class _BookBar extends StatelessWidget {
  const _BookBar({required this.courtId});

  final String courtId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: FilledButton(
          onPressed: () => context.push('/browse/court/$courtId/slots'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(
              double.infinity,
              AppTokens.buttonStickyHeight,
            ),
            shape: const StadiumBorder(),
          ),
          child: Text(AppLocalizations.of(context).courtDetailBookCta),
        ),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({required this.court, required this.groupSlots});

  final Court court;
  final List<OpenGroupSlot> groupSlots;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  int _photoIndex = 0;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final court = widget.court;
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        PhotoCarousel(
          photoCount: court.photoUrls.isEmpty ? 1 : court.photoUrls.length,
          index: _photoIndex,
          isFavorite: _isFavorite,
          onIndex: (i) => setState(() => _photoIndex = i),
          onFavorite: () => setState(() => _isFavorite = !_isFavorite),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SportChips(sports: court.sports),
              const SizedBox(height: 16),
              TitleBlock(court: court),
              const SizedBox(height: 16),
              StatCards(court: court),
              const SizedBox(height: 24),
              AmenitySection(amenities: court.amenities),
              const SizedBox(height: 24),
              AboutSection(description: court.description),
              const SizedBox(height: 24),
              ScheduleEntryCard(court: court),
              const SizedBox(height: 28),
              OpenSlotSection(
                slots: widget.groupSlots,
                helper: l10n.courtDetailOpenSlotsHelper,
                trailing: OpenSlotTrailing.joinButton,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
