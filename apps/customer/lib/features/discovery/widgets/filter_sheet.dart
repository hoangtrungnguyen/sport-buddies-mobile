// Discovery filter sheet — draft state, live count CTA (doc 02 screen 03).
// Holds its own draft; nothing applies until the user taps the CTA.

import 'package:customer/features/discovery/discovery_filter_state.dart';
import 'package:customer/features/discovery/discovery_style.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:spb_core/spb_core.dart';

// Sport filter slugs ('' = all); labels resolved via [sportLabelFor].
const _kFilterSportSlugs = ['', 'football', 'pickleball', 'badminton', 'tennis', 'multi'];

const _kDistanceOptions = [1.0, 3.0, 5.0];

class FilterSheet extends StatefulWidget {
  const FilterSheet({
    super.key,
    required this.initialState,
    required this.courts,
    required this.userPos,
    required this.onApply,
  });

  final DiscoveryFilterState initialState;
  final List<CourtAvailability> courts;
  final LatLng? userPos;
  final void Function(DiscoveryFilterState) onApply;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late Set<String> _sports;
  late double? _distance;
  late bool _onlyOpen;

  @override
  void initState() {
    super.initState();
    _sports = Set.from(widget.initialState.selectedSports);
    _distance = widget.initialState.maxDistanceKm;
    _onlyOpen = widget.initialState.onlyWithOpenSlots;
  }

  int get _draftCount {
    final userPos = widget.userPos;
    return widget.courts.where((c) {
      if (_onlyOpen && c.openSlotCount == 0) return false;
      if (_sports.isNotEmpty && !c.sportTypes.any(_sports.contains)) {
        return false;
      }
      if (_distance != null && userPos != null) {
        final courtPos = LatLng(c.lat, c.lng);
        if (!userPos.isWithinRadius(courtPos, _distance!)) return false;
      }
      return true;
    }).length;
  }

  void _apply() {
    widget.onApply(DiscoveryFilterState(
      selectedSports: Set.from(_sports),
      maxDistanceKm: _distance,
      onlyWithOpenSlots: _onlyOpen,
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final count = _draftCount;
    return Container(
      decoration: const BoxDecoration(
        color: mdSurfaceContainerLow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(mdCornerXl)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: mdOutlineVariant,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.commonFilter,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: mdOnSurface,
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _sports = {};
                  _distance = null;
                  _onlyOpen = false;
                }),
                child: Text(
                  l10n.commonReset,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: mdPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.filterSports,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: mdOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kFilterSportSlugs.map((slug) {
              final isAll = slug.isEmpty;
              final active = isAll ? _sports.isEmpty : _sports.contains(slug);
              return GestureDetector(
                onTap: () => setState(() {
                  if (isAll) {
                    _sports = {};
                  } else if (_sports.contains(slug)) {
                    _sports = Set.from(_sports)..remove(slug);
                  } else {
                    _sports = Set.from(_sports)..add(slug);
                  }
                }),
                child: _SheetChip(
                    label: sportLabelFor(l10n, slug), active: active),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.filterDistance,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: mdOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: _kDistanceOptions.asMap().entries.map((e) {
              final km = e.value;
              final active = _distance == km;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: e.key < _kDistanceOptions.length - 1 ? 8 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _distance = active ? null : km),
                    child: _SheetChip(
                      label: l10n.distanceKm('${km.toInt()}'),
                      active: active,
                      centered: true,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.filterStatus,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: mdOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => _onlyOpen = !_onlyOpen),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _onlyOpen ? mdPrimary : Colors.white,
                    border: Border.all(
                      color: _onlyOpen ? mdPrimary : mdOutlineVariant,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _onlyOpen
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.filterOnlyOpen,
                    style: const TextStyle(
                        fontSize: 14, color: mdOnSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _apply,
              style: FilledButton.styleFrom(
                backgroundColor: count > 0 ? mdPrimary : mdOutline,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(mdCornerFull),
                ),
              ),
              child: Text(
                count > 0 ? l10n.filterApply(count) : l10n.filterApplyZero,
                style: const TextStyle(
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

class _SheetChip extends StatelessWidget {
  const _SheetChip({
    required this.label,
    required this.active,
    this.centered = false,
  });

  final String label;
  final bool active;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: active ? mdPrimaryContainer : Colors.transparent,
        border: active ? null : Border.all(color: mdOutlineVariant),
        borderRadius: BorderRadius.circular(mdCornerSm),
      ),
      child: Row(
        mainAxisSize: centered ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment:
            centered ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (active) ...[
            const Icon(Icons.check, size: 14, color: mdOnPrimaryContainer),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? mdOnPrimaryContainer : mdOnSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
