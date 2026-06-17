import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/court_repository.dart';
import '../data/fake_court_repository.dart';
import '../data/fake_slot_repository.dart';
import '../domain/court.dart';
import '../domain/time_slot.dart';
import '../theme/app_tokens.dart';
import '../theme/browse_pick_theme.dart';
import 'widgets/open_slot_section.dart';
import 'widgets/sport_style.dart';

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
            minimumSize: const Size(double.infinity, AppTokens.buttonStickyHeight),
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
        _PhotoCarousel(
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
              _SportChips(sports: court.sports),
              const SizedBox(height: 16),
              _TitleBlock(court: court),
              const SizedBox(height: 16),
              _StatCards(court: court),
              const SizedBox(height: 24),
              _AmenitySection(amenities: court.amenities),
              const SizedBox(height: 24),
              _AboutSection(description: court.description),
              const SizedBox(height: 24),
              _ScheduleEntryCard(court: court),
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

// ── §1 Photo carousel ────────────────────────────────────────────────────────

class _PhotoCarousel extends StatelessWidget {
  const _PhotoCarousel({
    required this.photoCount,
    required this.index,
    required this.isFavorite,
    required this.onIndex,
    required this.onFavorite,
  });

  final int photoCount;
  final int index;
  final bool isFavorite;
  final ValueChanged<int> onIndex;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: photoCount,
            onPageChanged: onIndex,
            itemBuilder: (_, i) => _CourtPhotoPlaceholder(
                label: AppLocalizations.of(context)
                    .courtDetailPhoto(i + 1, photoCount)),
          ),
          Positioned(
            top: top + 12,
            left: 12,
            right: 12,
            child: Row(
              children: [
                _FloatingIconButton(
                  icon: Icons.arrow_back,
                  tooltip: l10n.commonBack,
                  onTap: () => context.pop(),
                ),
                const Spacer(),
                _FloatingIconButton(
                  icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                  tooltip: l10n.courtDetailFavorite,
                  onTap: onFavorite,
                ),
                const SizedBox(width: 8),
                _FloatingIconButton(
                  icon: Icons.ios_share,
                  tooltip: l10n.courtDetailShare,
                  onTap: () {},
                ),
              ],
            ),
          ),
          if (photoCount > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < photoCount; i++)
                    AnimatedContainer(
                      duration: AppTokens.motionMed,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: i == index ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withValues(alpha: i == index ? 1 : 0.6),
                        borderRadius: AppTokens.radiusFull,
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

class _CourtPhotoPlaceholder extends StatelessWidget {
  const _CourtPhotoPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16A34A), Color(0xFF0EA5E9)],
        ),
      ),
      child: CustomPaint(
        painter: _CourtLinesPainter(),
        child: Center(
          child: Text(
            '[ $label ]',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}

class _CourtLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final r = Rect.fromLTWH(
        size.width * 0.1, size.height * 0.21, size.width * 0.8, size.height * 0.6);
    canvas.drawRect(r, p);
    canvas.drawLine(Offset(r.center.dx, r.top), Offset(r.center.dx, r.bottom), p);
    canvas.drawCircle(r.center, size.height * 0.12, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FloatingIconButton extends StatelessWidget {
  const _FloatingIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: tooltip,
      child: Material(
        color: scheme.surfaceContainerLow,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 20, color: scheme.onSurface),
          ),
        ),
      ),
    );
  }
}

// ── §2 Sport chips ───────────────────────────────────────────────────────────

class _SportChips extends StatelessWidget {
  const _SportChips({required this.sports});

  final List<Sport> sports;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < sports.length; i++)
          _Chip(
            selected: i == 0,
            icon: SportStyle.icon(sports[i]),
            label: SportStyle.label(sports[i]),
            scheme: scheme,
            text: text,
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.selected,
    required this.icon,
    required this.label,
    required this.scheme,
    required this.text,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final ColorScheme scheme;
  final TextTheme text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppTokens.chipHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: selected ? scheme.primaryContainer : scheme.surface,
        borderRadius: AppTokens.radiusSm,
        border: selected ? null : Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14,
              color:
                  selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: text.labelLarge?.copyWith(
              color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── §3 Title block ───────────────────────────────────────────────────────────

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.court});

  final Court court;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final muted = text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(court.name, style: text.headlineSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.star_rounded, size: 18, color: scheme.tertiary),
            const SizedBox(width: 4),
            Text(
              court.rating.toStringAsFixed(1),
              style: text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
                fontFeatures: AppTokens.tnum,
              ),
            ),
            _Sep(scheme: scheme),
            Text(l10n.courtDetailReviews(court.reviewCount), style: muted),
            _Sep(scheme: scheme),
            Text(l10n.distanceKm(court.distanceKm.toStringAsFixed(1)),
                style: muted),
          ],
        ),
        const SizedBox(height: 12),
        // Tap the address → open it in an external map app (doc: directions).
        InkWell(
          onTap: () => _openCourtInMaps(context, court),
          borderRadius: AppTokens.radiusSm,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined,
                    size: 18, color: scheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(child: Text(court.address, style: muted)),
                const SizedBox(width: 6),
                Icon(Icons.directions_outlined, size: 18, color: scheme.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Opens the court's location in the user's chosen map app. Presents a sheet so
/// the user picks Apple Maps or Google Maps; launches a coordinate-based URL.
Future<void> _openCourtInMaps(BuildContext context, Court court) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final label = Uri.encodeComponent(court.name);
  final appleUrl =
      Uri.parse('https://maps.apple.com/?ll=${court.lat},${court.lng}&q=$label');
  final googleUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${court.lat},${court.lng}');

  final choice = await showModalBottomSheet<Uri>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      final text = Theme.of(ctx).textTheme;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.courtDetailOpenAddressIn,
                    style: text.titleMedium),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: Text(l10n.courtDetailAppleMaps),
              onTap: () => Navigator.of(ctx).pop(appleUrl),
            ),
            ListTile(
              leading: const Icon(Icons.navigation_outlined),
              title: Text(l10n.courtDetailGoogleMaps),
              onTap: () => Navigator.of(ctx).pop(googleUrl),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );

  if (choice == null) return;
  final launched = await launchUrl(choice, mode: LaunchMode.externalApplication);
  if (!launched) {
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.courtDetailMapsUnavailable)),
    );
  }
}

class _Sep extends StatelessWidget {
  const _Sep({required this.scheme});
  final ColorScheme scheme;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text('·', style: TextStyle(color: scheme.outlineVariant)),
      );
}

// ── §4 Stat cards ────────────────────────────────────────────────────────────

class _StatCards extends StatelessWidget {
  const _StatCards({required this.court});

  final Court court;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    // IntrinsicHeight bounds the Row's (otherwise unbounded) cross-axis so
    // CrossAxisAlignment.stretch can give the two cards equal height without
    // forcing an infinite constraint.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatCard(
              label: l10n.courtDetailPricePerHour,
              value: '${_thousands(court.pricePerHourVnd)} đ',
              valueColor: scheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: l10n.courtDetailOpenToday,
              value: l10n.courtDetailSlotCount(court.openSlotsToday),
              valueColor: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: AppTokens.radiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(
            value,
            style: text.priceMedium(scheme).copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}

// ── §5 Amenities ─────────────────────────────────────────────────────────────

class _AmenitySection extends StatelessWidget {
  const _AmenitySection({required this.amenities});

  final List<String> amenities;

  static const _emoji = <String, String>{
    'Có mái che': '🏠',
    'Đèn đêm': '💡',
    'Thuê vợt': '🎾',
    'Wifi': '📶',
    'Đồ uống': '🥤',
    'Bãi giữ xe': '🅿️',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).courtDetailAmenities,
            style: text.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in amenities)
              Container(
                height: AppTokens.chipHeight,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: AppTokens.radiusSm,
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_emoji[a] ?? '•',
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      a,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ── §6 About ─────────────────────────────────────────────────────────────────

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).courtDetailAbout,
            style: text.titleMedium),
        const SizedBox(height: 8),
        Text(description,
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
      ],
    );
  }
}

// ── §7 Schedule entry card → 08 (edge E3) ────────────────────────────────────

class _ScheduleEntryCard extends StatelessWidget {
  const _ScheduleEntryCard({required this.court});

  final Court court;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.courtDetailScheduleTitle, style: text.titleMedium),
        const SizedBox(height: 10),
        Material(
          color: scheme.primaryContainer,
          borderRadius: AppTokens.radiusLg,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () =>
                context.push('/browse/center/${court.centerId}/schedule'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: scheme.primary, shape: BoxShape.circle),
                    child: Icon(Icons.calendar_month,
                        size: 24, color: scheme.onPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.courtDetailViewAllCourts,
                            style: text.labelLarge
                                ?.copyWith(color: scheme.onPrimaryContainer)),
                        const SizedBox(height: 2),
                        Text(
                          l10n.courtDetailScheduleSubtitle,
                          style: text.bodySmall?.copyWith(
                            color:
                                scheme.onPrimaryContainer.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: scheme.onPrimaryContainer),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// "180000" → "180.000" (vi thousands).
String _thousands(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}
