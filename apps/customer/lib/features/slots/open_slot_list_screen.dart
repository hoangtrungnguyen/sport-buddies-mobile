// M3 "Slot trống" — open group slot discovery screen (SPB-034/035).
// Design: EPIC-4 Slot Detail · Material 3 · M3DiscoverSlots component.

import 'package:customer/features/slots/cubit/open_slot_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/spb_core.dart';

// ── MD3 tokens (same palette as map_screen) ──────────────────────────────────
const _mdSurface              = Color(0xFFF7FBF2);
const _mdOnSurface            = Color(0xFF181D17);
const _mdOnSurfaceVariant     = Color(0xFF42493F);
const _mdSurfaceContainerLow  = Color(0xFFF1F6EC);
const _mdSurfaceContainer     = Color(0xFFEBF0E6);
const _mdSurfaceContainerHigh = Color(0xFFE5EAE1);
const _mdSurfaceContainerHighest = Color(0xFFDFE4DA);
const _mdPrimary              = Color(0xFF15803D);
const _mdPrimaryContainer     = Color(0xFFC9F2D2);
const _mdOnPrimaryContainer   = Color(0xFF00210B);
const _mdOutlineVariant       = Color(0xFFC2C8BB);
const _mdCornerSm             = 8.0;
const _mdCornerMd             = 12.0;
const _mdCornerFull           = 9999.0;

// ── Sport colour palette ──────────────────────────────────────────────────────
const _sportColors = <String, Color>{
  'football':   Color(0xFF22C55E),
  'badminton':  Color(0xFFEF4444),
  'pickleball': Color(0xFF0EA5E9),
  'tennis':     Color(0xFFEAB308),
  'multi':      Color(0xFF6B7280),
};

const _sportLabels = <String, String>{
  'football':   'Bóng đá',
  'badminton':  'Cầu lông',
  'pickleball': 'Pickleball',
  'tennis':     'Tennis',
  'multi':      'Đa năng',
};

const _filterLabels = ['Tất cả', 'Bóng đá', 'Pickleball', 'Cầu lông', 'Tennis'];

class OpenSlotListScreen extends StatefulWidget {
  const OpenSlotListScreen({super.key});

  @override
  State<OpenSlotListScreen> createState() => _OpenSlotListScreenState();
}

class _OpenSlotListScreenState extends State<OpenSlotListScreen> {
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    context.read<SlotListCubit>().loadAllGroupSlots();
  }

  List<Slot> _filtered(List<Slot> slots) {
    if (_selectedFilter == 0) return slots;
    final sport = ['football', 'pickleball', 'badminton', 'tennis'][_selectedFilter - 1];
    return slots.where((s) => s.sportType == sport).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mdSurface,
      body: Column(
        children: [
          _Header(
            selectedFilter: _selectedFilter,
            onFilterSelected: (i) => setState(() => _selectedFilter = i),
          ),
          Expanded(
            child: BlocBuilder<SlotListCubit, SlotListState>(
              builder: (context, state) => switch (state) {
                SlotListInitial() || SlotListLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                SlotListError(message: final msg) => _ErrorView(message: msg),
                SlotListLoaded(slots: final slots) => RefreshIndicator(
                    color: _mdPrimary,
                    onRefresh: () =>
                        context.read<SlotListCubit>().loadAllGroupSlots(),
                    child: _SlotBody(slots: _filtered(slots)),
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.selectedFilter, required this.onFilterSelected});

  final int selectedFilter;
  final ValueChanged<int> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _mdSurfaceContainerLow,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 8),
          // Title row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 4, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Slot trống',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _mdOnSurface,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Slot đang tìm người chơi cùng',
                        style: TextStyle(fontSize: 12, color: _mdOnSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list_outlined),
                  color: _mdOnSurfaceVariant,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  color: _mdOnSurfaceVariant,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Filter chips
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: _filterLabels.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                if (i < _filterLabels.length) {
                  return _FilterChip(
                    label: _filterLabels[i],
                    selected: selectedFilter == i,
                    onTap: () => onFilterSelected(i),
                  );
                }
                // Distance chip (non-interactive for now)
                return _FilterChip(
                  label: 'Trong 5 km',
                  selected: false,
                  onTap: () {},
                );
              },
            ),
          ),
          Divider(height: 1, color: _mdOutlineVariant.withAlpha(128)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? _mdPrimaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(_mdCornerSm),
          border: Border.all(
            color: selected ? _mdPrimary : _mdOutlineVariant,
            width: selected ? 0 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check, size: 14, color: _mdOnPrimaryContainer),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? _mdOnPrimaryContainer : _mdOnSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotBody extends StatelessWidget {
  const _SlotBody({required this.slots});

  final List<Slot> slots;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: const _EmptyView(),
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: slots.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '${slots.length} slot · Sắp xếp: Sớm nhất ↓',
              style: const TextStyle(fontSize: 12, color: _mdOnSurfaceVariant),
            ),
          );
        }
        return _SlotCard(
          slot: slots[i - 1],
          onTap: () => context.push('/slot/${slots[i - 1].id}'),
        );
      },
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.slot, required this.onTap});

  final Slot slot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sportColor = _sportColors[slot.sportType] ?? const Color(0xFF6B7280);
    final sportLabel = _sportLabels[slot.sportType] ?? slot.sportType;
    final isFull = slot.isFull;

    final timeFmt = DateFormat('HH:mm');
    final dateFmt = DateFormat('EEE, dd/MM', 'vi');
    final timeLabel =
        '${dateFmt.format(slot.startTime)} · ${timeFmt.format(slot.startTime)} – ${timeFmt.format(slot.endTime)}';

    return Material(
      color: const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(_mdCornerMd),
      elevation: 1,
      shadowColor: const Color(0x1A000000),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_mdCornerMd),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sport icon container
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: sportColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(_mdCornerMd),
                    ),
                    child: Icon(
                      _sportIcon(slot.sportType),
                      color: sportColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                slot.courtName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _mdOnSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _FullnessBadge(
                              joined: slot.currentPlayers,
                              max: slot.maxPlayers,
                              isFull: isFull,
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          timeLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _mdOnSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.sports,
                              size: 13,
                              color: _mdOnSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              sportLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                color: _mdOnSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Divider(height: 1, color: _mdOutlineVariant.withAlpha(128)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _mdSurfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 16,
                        color: _mdOnSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Chủ slot mời chơi cùng',
                        style: TextStyle(
                          fontSize: 12,
                          color: _mdOnSurfaceVariant,
                        ),
                      ),
                    ),
                    if (slot.accessPolicy == 'open')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _mdSurfaceContainerHigh,
                          borderRadius: BorderRadius.circular(_mdCornerSm),
                        ),
                        child: const Text(
                          '🌐 Mở ghép',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _mdOnSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _sportIcon(String sport) => switch (sport) {
        'football'   => Icons.sports_soccer,
        'badminton'  => Icons.sports_tennis,
        'pickleball' => Icons.sports_tennis,
        'tennis'     => Icons.sports_tennis,
        _            => Icons.sports,
      };
}

class _FullnessBadge extends StatelessWidget {
  const _FullnessBadge({
    required this.joined,
    required this.max,
    required this.isFull,
  });

  final int joined;
  final int max;
  final bool isFull;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isFull ? _mdSurfaceContainerHighest : _mdPrimaryContainer,
        borderRadius: BorderRadius.circular(_mdCornerFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFull ? const Color(0xFF72796C) : _mdPrimary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isFull ? 'Đã đủ người' : '$joined/$max người',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isFull ? _mdOnSurfaceVariant : _mdOnPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _mdSurfaceContainer,
                borderRadius: BorderRadius.circular(_mdCornerMd),
              ),
              child: const Icon(
                Icons.group_outlined,
                size: 36,
                color: _mdOnSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Không có slot trống',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _mdOnSurface,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Không có slot nào đang tìm người trong khu vực của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _mdOnSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: const TextStyle(color: _mdOnSurfaceVariant)),
    );
  }
}
