// Full-screen live search over court names, distance-sorted (doc 02 screen 05).
// Ignores the active filters; renders results as [CourtCard]s.

import 'package:customer/features/discovery/cubit/discovery_cubit.dart';
import 'package:customer/features/discovery/discovery_style.dart';
import 'package:customer/features/discovery/widgets/court_card.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spb_core/spb_core.dart';

class SearchOverlay extends StatefulWidget {
  const SearchOverlay({
    super.key,
    required this.userPos,
    required this.onBack,
    required this.onTapCourt,
  });

  final LatLng? userPos;
  final VoidCallback onBack;
  final void Function(CourtAvailability) onTapCourt;

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: mdN50,
      child: BlocBuilder<DiscoveryCubit, DiscoveryState>(
        builder: (context, mapState) {
          final l10n = AppLocalizations.of(context);
          final allCourts =
              mapState is DiscoveryLoaded ? mapState.courts : <CourtAvailability>[];
          final q = _query.trim().toLowerCase();
          // Search ignores the map filters; matches name, distance-sorted.
          final results = (q.isEmpty
              ? [...allCourts]
              : allCourts
                  .where((c) => c.name.toLowerCase().contains(q))
                  .toList());
          final userPos = widget.userPos;
          if (userPos != null) {
            results.sort((a, b) => courtDistanceKm(a, userPos)!
                .compareTo(courtDistanceKm(b, userPos)!));
          }

          final topPad = MediaQuery.of(context).padding.top;

          return Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(12, topPad + 12, 12, 12),
                decoration: const BoxDecoration(
                  color: mdSurface,
                  border: Border(bottom: BorderSide(color: mdOutlineVariant)),
                ),
                child: Row(
                  children: [
                    Semantics(
                      label: l10n.commonBack,
                      button: true,
                      child: GestureDetector(
                        onTap: widget.onBack,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: mdSurfaceContainerHigh,
                          ),
                          child: const Icon(Icons.arrow_back,
                              size: 20, color: mdOnSurfaceVariant),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: mdSurfaceContainerHighest,
                          borderRadius: BorderRadius.circular(mdCornerFull),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x12000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            const Icon(Icons.search,
                                size: 18, color: mdOnSurfaceVariant),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _ctrl,
                                autofocus: true,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: l10n.searchHint,
                                  hintStyle: const TextStyle(
                                    fontSize: 14,
                                    color: mdOnSurfaceVariant,
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: mdOnSurface,
                                ),
                                onChanged: (v) => setState(() => _query = v),
                              ),
                            ),
                            if (_query.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _ctrl.clear();
                                  setState(() => _query = '');
                                },
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: const BoxDecoration(
                                    color: mdSurfaceContainerHigh,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      size: 14, color: mdOnSurfaceVariant),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    q.isEmpty
                        ? l10n.searchAllCourts(allCourts.length)
                        : l10n.searchResultsFor(results.length, _query),
                    style: const TextStyle(
                        fontSize: 12, color: mdOnSurfaceVariant),
                  ),
                ),
              ),
              Expanded(
                child: results.isEmpty
                    ? _SearchEmpty(query: _query)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) => CourtCard(
                          court: results[i],
                          distanceKm: courtDistanceKm(results[i], userPos),
                          onTap: () => widget.onTapCourt(results[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SearchEmpty extends StatelessWidget {
  const _SearchEmpty({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: mdSurfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off,
                size: 32, color: mdOnSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.searchNoResults(query),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: mdOnSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.searchTryOther,
            style: const TextStyle(fontSize: 13, color: mdOnSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
