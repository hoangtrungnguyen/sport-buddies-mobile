// Map screen — CAPP-030 grava-c9ca.2.1 + CAPP-032 grava-c9ca.3.1
//
// Renders a flutter_map widget centred on Ho Chi Minh City with:
//   - Colour-coded court availability markers (green=open, grey=full)
//   - Sport-type filter bar at the top
//   - Filter bottom sheet (sport, distance, status)
//   - Selected court preview panel
//   - Map / Slot trống view toggle
//
// Tile source strategy:
//   • When [Env.vietmapApiKey] is non-empty, uses VietMap raster tiles.
//   • When the key is empty (dev/CI), falls back to OpenStreetMap tiles.
//
// The API key is a compile-time constant injected via:
//   --dart-define=VIETMAP_API_KEY=<key>

import 'package:customer/core/env/env.dart';
import 'package:customer/features/map/cubit/map_cubit.dart';
import 'package:customer/features/map/map_filter_cubit.dart';
import 'package:customer/features/map/map_filter_state.dart';
import 'package:customer/features/map/sport_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:spb_core/spb_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Default map centre: Ho Chi Minh City, Vietnam.
const _hcmcLatLng = ll.LatLng(10.7769, 106.7009);
const _defaultZoom = 13.0;

const _vietmapTileUrl =
    'https://maps.vietmap.vn/api/maps/raster/v1/{z}/{x}/{y}.png?apikey={key}';
const _osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

String _tileUrlTemplate() {
  const key = Env.vietmapApiKey;
  if (key.isEmpty) return _osmTileUrl;
  return _vietmapTileUrl.replaceAll('{key}', key);
}

/// Map screen — zoomable HCMC map with colour-coded court markers and sport filters.
///
/// Court availability markers are rendered when a [MapCubit] is present in the
/// widget tree above this screen. Without a cubit the map renders normally with
/// no markers (graceful degradation for tests).
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapFilterCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bản đồ sân gần bạn'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterSheet(context),
              tooltip: 'Bộ lọc',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              tooltip: 'Sign out',
            ),
          ],
        ),
        body: const _MapBody(),
      ),
    );
  }

  static void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FilterSheet(),
    );
  }
}

class _MapBody extends StatefulWidget {
  const _MapBody();

  @override
  State<_MapBody> createState() => _MapBodyState();
}

class _MapBodyState extends State<_MapBody> {
  MapCubit? _cubit;
  bool _showSlotList = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cubit ??= _tryReadCubit(context);
    if (_cubit?.state is MapInitial) {
      _cubit!.loadCourts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<MapFilterCubit, MapFilterState>(
          builder: (context, filterState) => SportFilterBar(
            selectedSports: filterState.selectedSports,
            onSportsChanged: (sports) =>
                context.read<MapFilterCubit>().filterBySports(sports.toList()),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              _buildMapArea(context),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _showSlotList
                    ? _SlotListPanel(onClose: () => setState(() => _showSlotList = false))
                    : _CourtPreviewPanel(),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: _showSlotList ? 340 : 168,
                child: Center(
                  child: _ViewToggle(
                    isSlotView: _showSlotList,
                    onToggle: (val) => setState(() => _showSlotList = val),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapArea(BuildContext context) {
    if (_cubit == null) {
      return _buildMap(courts: const []);
    }

    return BlocConsumer<MapCubit, MapState>(
      listener: (context, state) {
        if (state is MapError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final courts =
            state is MapLoaded ? state.courts : <CourtAvailability>[];
        final isLoading = state is MapLoading;
        final isEmpty = state is MapLoaded && state.courts.isEmpty;

        if (isEmpty) {
          return const _EmptyState();
        }

        return Stack(
          children: [
            _buildMap(courts: courts),
            if (isLoading)
              const Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }

  static MapCubit? _tryReadCubit(BuildContext context) {
    try {
      return BlocProvider.of<MapCubit>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  static Widget _buildMap({required List<CourtAvailability> courts}) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: _hcmcLatLng,
        initialZoom: _defaultZoom,
      ),
      children: [
        TileLayer(
          urlTemplate: _tileUrlTemplate(),
          userAgentPackageName: 'vn.sportbuddies.customer',
        ),
        MarkerLayer(
          markers: courts.map(_buildMarker).toList(),
        ),
      ],
    );
  }

  static Marker _buildMarker(CourtAvailability court) {
    return Marker(
      point: ll.LatLng(court.lat, court.lng),
      width: 24,
      height: 24,
      child: Tooltip(
        message: court.name,
        child: Container(
          decoration: BoxDecoration(
            color: court.markerColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state widget shown when no courts are found in range.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy sân gần bạn',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Thử phóng to bản đồ hoặc thay đổi bộ lọc',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.isSlotView, required this.onToggle});

  final bool isSlotView;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleBtn(
            label: 'Bản đồ',
            active: !isSlotView,
            onTap: () => onToggle(false),
          ),
          const SizedBox(width: 2),
          _ToggleBtn(
            label: 'Slot trống · 18',
            active: isSlotView,
            onTap: () => onToggle(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF16A34A) : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : const Color(0xFF374151),
            ),
          ),
        ),
      ),
    );
  }
}

class _CourtPreviewPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.sports_tennis,
                  size: 32,
                  color: Colors.white,
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
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pickle Hub Q1',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '123 Nguyễn Du, Q.1 · 1.2 km',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '4 slot trống',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Icon(Icons.star,
                            size: 14, color: Color(0xFFEAB308)),
                        SizedBox(width: 4),
                        Text(
                          '4.8',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Text(
                          ' (126)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '·',
                          style: TextStyle(color: Color(0xFFD1D5DB)),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '180k',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Text(
                          '/giờ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: FilledButton(
                        onPressed: () => context.push('/court/1'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Xem sân & đặt',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
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

class _SlotListPanel extends StatelessWidget {
  const _SlotListPanel({required this.onClose});

  final VoidCallback onClose;

  static const _slots = [
    _SlotEntry(
      court: 'Pickle Hub Q1 · Sân B',
      sport: 'pickleball',
      time: 'Hôm nay · 19:00 – 20:30',
      distance: '1.2 km',
      price: '250k',
      joined: 3,
      max: 6,
    ),
    _SlotEntry(
      court: 'Sân Tao Đàn · Bóng 7v7',
      sport: 'football',
      time: 'Ngày mai · 20:00 – 21:30',
      distance: '2.4 km',
      price: '120k/người',
      joined: 9,
      max: 14,
    ),
    _SlotEntry(
      court: 'Badminton Pro · Sân 3',
      sport: 'badminton',
      time: 'T5, 16/05 · 18:00 – 19:30',
      distance: '3.1 km',
      price: '90k/người',
      joined: 2,
      max: 4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 340),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Slot trống · 18',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close,
                      size: 20, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: _slots.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _SlotCard(slot: _slots[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.slot});

  final _SlotEntry slot;

  static const _sportColors = {
    'pickleball': Color(0xFF0EA5E9),
    'football': Color(0xFF16A34A),
    'badminton': Color(0xFFEF4444),
    'tennis': Color(0xFFEAB308),
  };

  @override
  Widget build(BuildContext context) {
    final color = _sportColors[slot.sport] ?? const Color(0xFF6B7280);
    final isFull = slot.joined >= slot.max;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.sports, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.court,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  slot.time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${slot.joined}/${slot.max} người',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      slot.distance,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                slot.price,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color:
                      isFull ? const Color(0xFF9CA3AF) : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 32,
                child: FilledButton(
                  onPressed: isFull ? null : () => context.push('/slot/1'),
                  style: FilledButton.styleFrom(
                    backgroundColor: isFull
                        ? const Color(0xFFE5E7EB)
                        : const Color(0xFF16A34A),
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Text(
                    isFull ? 'Đã đủ' : 'Xem',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isFull
                          ? const Color(0xFF9CA3AF)
                          : Colors.white,
                    ),
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

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bộ lọc',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Đặt lại',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Môn thể thao',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _FilterChip(label: 'Tất cả', active: true),
              _FilterChip(label: 'Bóng đá'),
              _FilterChip(label: 'Cầu lông', active: true),
              _FilterChip(label: 'Pickleball', active: true),
              _FilterChip(label: 'Tennis'),
              _FilterChip(label: 'Đa năng'),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Khoảng cách',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Expanded(child: _FilterChip(label: '1 km', centered: true)),
              SizedBox(width: 8),
              Expanded(child: _FilterChip(label: '3 km', centered: true)),
              SizedBox(width: 8),
              Expanded(
                  child: _FilterChip(label: '5 km', active: true, centered: true)),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Trạng thái',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          _CheckboxRow(label: 'Chỉ hiển thị sân còn slot trống', checked: true),
          const SizedBox(height: 12),
          _CheckboxRow(label: 'Có slot mở chơi ghép', checked: false),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Hiển thị 12 sân',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.active = false,
    this.centered = false,
  });

  final String label;
  final bool active;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF111827) : Colors.white,
        border: Border.all(
          color: active ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
        ),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        textAlign: centered ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : const Color(0xFF374151),
        ),
      ),
    );
  }
}

class _CheckboxRow extends StatelessWidget {
  const _CheckboxRow({required this.label, required this.checked});

  final String label;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: checked ? const Color(0xFF16A34A) : Colors.white,
            border: Border.all(
              color: checked
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFD1D5DB),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: checked
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
        ),
      ],
    );
  }
}

class _SlotEntry {
  const _SlotEntry({
    required this.court,
    required this.sport,
    required this.time,
    required this.distance,
    required this.price,
    required this.joined,
    required this.max,
  });

  final String court;
  final String sport;
  final String time;
  final String distance;
  final String price;
  final int joined;
  final int max;
}
