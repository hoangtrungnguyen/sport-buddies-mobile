import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../../setup/bloc/court_bloc.dart';
import '../../setup/bloc/court_event.dart';
import '../../setup/bloc/court_state.dart';
import '../../setup/model/owner_court.dart';
import '../../setup/repository/owner_court_repository.dart';
import '../bloc/venue_bloc.dart';
import '../model/venue.dart';

const _kSportColors = <String, Color>{
  'Bóng đá 5v5': Color(0xFF16A34A),
  'Bóng đá 7v7': Color(0xFF15803D),
  'Bóng đá 11v11': Color(0xFF14532D),
  'Pickleball': Color(0xFFF97316),
  'Tennis': Color(0xFFEC4899),
  'Cầu lông': Color(0xFFA855F7),
  'Bóng rổ': Color(0xFFEF4444),
  'Đa năng': Color(0xFF0EA5E9),
};

class CourtDetailScreen extends StatelessWidget {
  const CourtDetailScreen({super.key, required this.courtId});
  final String courtId;

  @override
  Widget build(BuildContext context) {
    // Look up court from shell-level CourtBloc.
    final court = context.select<CourtBloc, OwnerCourt?>(
      (bloc) => switch (bloc.state) {
        CourtLoaded(:final courts) =>
          courts.where((c) => c.id == courtId).firstOrNull,
        _ => null,
      },
    );

    if (court == null) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return BlocListener<VenueBloc, VenueState>(
      listener: (context, state) {
        if (state is VenueFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 320,
                    child: _CourtInfoCard(court: court),
                  ),
                  const SizedBox(width: 24),
                  Expanded(child: _VenuePanel(courtId: courtId)),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CourtInfoCard(court: court),
                const SizedBox(height: 20),
                _VenuePanel(courtId: courtId),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Court info card (left panel)
// ---------------------------------------------------------------------------

class _CourtInfoCard extends StatefulWidget {
  const _CourtInfoCard({required this.court});
  final OwnerCourt court;

  @override
  State<_CourtInfoCard> createState() => _CourtInfoCardState();
}

class _CourtInfoCardState extends State<_CourtInfoCard> {
  bool _editingMaps = false;
  bool _savingMaps = false;
  late final TextEditingController _mapsCtrl;

  @override
  void initState() {
    super.initState();
    _mapsCtrl = TextEditingController(
        text: widget.court.googleMapsUrl ?? '');
  }

  @override
  void didUpdateWidget(_CourtInfoCard old) {
    super.didUpdateWidget(old);
    if (!_editingMaps &&
        old.court.googleMapsUrl != widget.court.googleMapsUrl) {
      _mapsCtrl.text = widget.court.googleMapsUrl ?? '';
    }
  }

  @override
  void dispose() {
    _mapsCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveMapsUrl() async {
    setState(() => _savingMaps = true);
    try {
      final url = _mapsCtrl.text.trim();
      final merged = Map<String, dynamic>.from(widget.court.additionalInfo)
        ..['google_maps_url'] = url.isEmpty ? null : url;
      await context
          .read<OwnerCourtRepository>()
          .updateAdditionalInfo(widget.court.id, merged);
      if (!mounted) return;
      context.read<CourtBloc>().add(const CourtEvent.loadRequested());
      setState(() => _editingMaps = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu liên kết Google Maps'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể lưu. Vui lòng thử lại.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _savingMaps = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final court = widget.court;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neutral200),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.stadium_outlined,
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  court.name,
                  style: GoogleFonts.sora(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              if (!court.isActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'Tạm ngưng',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.neutral100),
          const SizedBox(height: 16),

          // Static info rows
          if (court.address != null && court.address!.isNotEmpty)
            _InfoRow(icon: Icons.location_on_outlined, text: court.address!),
          if (court.lat != null && court.lng != null)
            _InfoRow(
              icon: Icons.my_location_outlined,
              text:
                  '${court.lat!.toStringAsFixed(5)}, ${court.lng!.toStringAsFixed(5)}',
            ),
          _InfoRow(
            icon: Icons.access_time_outlined,
            text:
                '${court.openHour.toString().padLeft(2, '0')}:00 – ${court.closeHour.toString().padLeft(2, '0')}:00',
          ),
          if (court.amenities.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: court.amenities
                  .map((a) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.neutral100,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(a,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: AppColors.neutral600)),
                      ))
                  .toList(),
            ),
          ],
          if (court.description != null &&
              court.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              court.description!,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.neutral500,
                  height: 1.5),
            ),
          ],

          // Google Maps URL
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.neutral100),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.map_outlined,
                  size: 14, color: AppColors.neutral500),
              const SizedBox(width: 6),
              Text(
                'Google Maps',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral600,
                ),
              ),
              const Spacer(),
              if (!_editingMaps)
                GestureDetector(
                  onTap: () => setState(() => _editingMaps = true),
                  child: const Icon(Icons.edit_outlined,
                      size: 14, color: AppColors.neutral400),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_editingMaps) ...[
            TextField(
              controller: _mapsCtrl,
              style: GoogleFonts.plusJakartaSans(fontSize: 13),
              decoration: InputDecoration(
                hintText:
                    'https://maps.google.com/?q=...',
                hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: AppColors.neutral400),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 9),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.neutral200)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.neutral200)),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _savingMaps
                        ? null
                        : () {
                            _mapsCtrl.text =
                                court.googleMapsUrl ?? '';
                            setState(() => _editingMaps = false);
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.neutral600,
                      side: const BorderSide(
                          color: AppColors.neutral200),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 8),
                      textStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Huỷ'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _savingMaps ? null : _saveMapsUrl,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 8),
                      textStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600),
                    ),
                    child: _savingMaps
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white))
                        : const Text('Lưu'),
                  ),
                ),
              ],
            ),
          ] else if (court.googleMapsUrl != null &&
              court.googleMapsUrl!.isNotEmpty) ...[
            Text(
              court.googleMapsUrl!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ] else ...[
            Text(
              'Chưa có liên kết — nhấn ✏ để thêm',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5, color: AppColors.neutral400),
            ),
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.edit_outlined, size: 14),
              label: const Text('Chỉnh sửa thông tin sân'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.neutral700,
                side: const BorderSide(color: AppColors.neutral200),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                textStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600, fontSize: 13),
              ),
              onPressed: () => context.push(
                '/courts/${court.id}/edit',
                extra: court,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: AppColors.neutral400),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: AppColors.neutral600),
              ),
            ),
          ],
        ),
      );
}

// ---------------------------------------------------------------------------
// Venue panel (right panel)
// ---------------------------------------------------------------------------

class _VenuePanel extends StatelessWidget {
  const _VenuePanel({required this.courtId});
  final String courtId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VenueBloc, VenueState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Panel header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(Icons.grid_view_rounded,
                          size: 16, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Khu sân',
                        style: GoogleFonts.sora(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral900,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add_rounded, size: 14),
                      label: const Text('Thêm khu sân'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.neutral700,
                        side: const BorderSide(color: AppColors.neutral200),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: Size.zero,
                        textStyle: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600, fontSize: 12.5),
                      ),
                      onPressed: () => context
                          .push('/courts/$courtId/venues/new')
                          .then((ok) {
                        if (ok == true && context.mounted) {
                          context
                              .read<VenueBloc>()
                              .add(const VenueEvent.reloadRequested());
                        }
                      }),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.neutral100),

              // Content
              switch (state) {
                VenueInitial() || VenueLoading() => const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary)),
                  ),
                VenueLoaded(:final venues) when venues.isEmpty =>
                  _EmptyVenueState(courtId: courtId),
                VenueLoaded(:final venues) => Column(
                    children: venues
                        .map((v) => _VenueRow(
                              venue: v,
                              onEdit: () => context
                                  .push(
                                    '/courts/$courtId/venues/${v.id}/edit',
                                    extra: v,
                                  )
                                  .then((ok) {
                                if (ok == true && context.mounted) {
                                  context.read<VenueBloc>().add(
                                      const VenueEvent.reloadRequested());
                                }
                              }),
                            ))
                        .toList(),
                  ),
                VenueFailure(:final message) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(message,
                        style: GoogleFonts.plusJakartaSans(
                            color: AppColors.danger, fontSize: 13)),
                  ),
              },
            ],
          ),
        );
      },
    );
  }
}

class _VenueRow extends StatelessWidget {
  const _VenueRow({required this.venue, required this.onEdit});
  final Venue venue;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final vnd = NumberFormat('#,###', 'vi_VN');
    final color = _kSportColors[venue.sportType] ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.neutral100)),
      ),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: venue.isActive ? color : AppColors.neutral300,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue.name,
                  style: GoogleFonts.sora(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: venue.isActive
                        ? AppColors.neutral900
                        : AppColors.neutral400,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${venue.sportType} · ${vnd.format(venue.pricePerHour)}đ/giờ · ${venue.capacity} người',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          if (!venue.isActive) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                'Ngưng',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral500,
                ),
              ),
            ),
          ],
          OutlinedButton(
            onPressed: onEdit,
            style: OutlinedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: AppColors.neutral700,
              side: const BorderSide(color: AppColors.neutral200),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              textStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600, fontSize: 12.5),
            ),
            child: const Text('Sửa'),
          ),
        ],
      ),
    );
  }
}

class _EmptyVenueState extends StatelessWidget {
  const _EmptyVenueState({required this.courtId});
  final String courtId;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        child: Column(
          children: [
            const Icon(Icons.grid_view_rounded,
                size: 32, color: AppColors.neutral300),
            const SizedBox(height: 12),
            Text(
              'Chưa có khu sân nào',
              style: GoogleFonts.sora(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Thêm khu sân đầu tiên để nhận booking.',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: AppColors.neutral400),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Thêm khu sân'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                textStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600, fontSize: 13),
              ),
              onPressed: () => context
                  .push('/courts/$courtId/venues/new')
                  .then((ok) {
                if (ok == true && context.mounted) {
                  context
                      .read<VenueBloc>()
                      .add(const VenueEvent.reloadRequested());
                }
              }),
            ),
          ],
        ),
      );
}
