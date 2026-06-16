// Booking detail — MD3 redesign.
// Route: /bookings/:id  (full-screen, no bottom nav)
// Design: EPIC-6 My Bookings.html → BookingDetail component

import 'package:customer/core/env/env.dart';
import 'package:customer/core/services/booking_api_client.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'booking_detail_cubit.dart';
import 'booking_detail_state.dart';
import 'booking_model.dart';

// ─── MD3 tokens ──────────────────────────────────────────────────────────────
const _mdSurface                 = Color(0xFFF7FBF2);
const _mdOnSurface               = Color(0xFF181D18);
const _mdOnSurfaceVariant        = Color(0xFF414941);
const _mdSurfaceContainerLowest  = Color(0xFFFFFFFF);
const _mdSurfaceContainer        = Color(0xFFEBEFE6);
const _mdSurfaceContainerHighest = Color(0xFFDCE1D7);
const _mdPrimary                 = Color(0xFF15803D);
const _mdOnPrimary               = Color(0xFFFFFFFF);
const _mdPrimaryContainer        = Color(0xFFBBF7D0);
const _mdOnPrimaryContainer      = Color(0xFF002111);
const _mdTertiary                = Color(0xFF3D6373);
const _mdTertiaryContainer       = Color(0xFFC1E8FA);
const _mdOnTertiaryContainer     = Color(0xFF001F2A);
const _mdError                   = Color(0xFFBA1A1A);
const _mdOutlineVariant          = Color(0xFFBFC9BA);
const _mdCornerMd = BorderRadius.all(Radius.circular(12));
const _mdCornerFull = BorderRadius.all(Radius.circular(9999));

// ─── Page entry point ────────────────────────────────────────────────────────

class BookingDetailPage extends StatelessWidget {
  const BookingDetailPage({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingDetailCubit(
        Supabase.instance.client,
        apiClient: BookingApiClient(
          supabase: Supabase.instance.client,
          baseUrl: Env.apiBaseUrl,
        ),
      )..loadBookingDetail(bookingId),
      child: const BookingDetailScreen(),
    );
  }
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mdSurface,
      appBar: AppBar(
        backgroundColor: _mdSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).bookingDetailTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _mdOnSurface),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _mdOnSurface),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: _mdOnSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<BookingDetailCubit, BookingDetailState>(
        listenWhen: (prev, curr) =>
            curr is BookingDetailLoaded && curr.actionError != null,
        listener: (context, state) {
          final msg = (state as BookingDetailLoaded).actionError!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: _mdError),
          );
        },
        builder: (context, state) => switch (state) {
          BookingDetailLoading() =>
            const Center(child: CircularProgressIndicator()),
          BookingDetailLoaded(
            :final booking,
            :final joinRequests,
            :final processing,
          ) =>
            _LoadedBody(
              booking: booking,
              joinRequests: joinRequests,
              processing: processing,
            ),
          BookingDetailError(:final message) => _ErrorBody(message: message),
        },
      ),
    );
  }
}

// ─── Loaded body ─────────────────────────────────────────────────────────────

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({
    required this.booking,
    required this.joinRequests,
    required this.processing,
  });

  final Booking? booking;
  final List<JoinRequest> joinRequests;
  final Set<String> processing;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          children: [
            if (booking != null) ...[
              _BookingInfoCard(booking: booking!),
              const SizedBox(height: 12),
              _ParticipantsCard(joinRequests: joinRequests),
              const SizedBox(height: 12),
              _JoinRequestsCard(
                joinRequests: joinRequests,
                slotId: booking!.slot.id,
                processing: processing,
              ),
            ],
          ],
        ),
        if (booking != null)
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _BottomActions(booking: booking!),
          ),
      ],
    );
  }
}

// ─── Booking info card ────────────────────────────────────────────────────────

class _BookingInfoCard extends StatelessWidget {
  const _BookingInfoCard({required this.booking});

  final Booking booking;

  static final _timeFmt = DateFormat('HH:mm');
  static final _dateFmt = DateFormat("EEEE, dd/MM", 'vi');
  static final _priceFmt =
      NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0);

  String _formatPrice(double? price) {
    if (price == null || price == 0) return '—';
    return '${_priceFmt.format(price).trim()} đ';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final start = booking.slot.startTime.toLocal();
    final end = booking.slot.endTime.toLocal();
    final statusLabel = switch (booking.status) {
      'confirmed' => l10n.bookingStatusConfirmed,
      'pending'   => l10n.bookingStatusPendingHost,
      'cancelled' => l10n.bookingStatusCancelled,
      _           => booking.status,
    };

    return Container(
      decoration: BoxDecoration(
        color: _mdSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _mdOutlineVariant),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _M3Badge(status: booking.status, label: statusLabel),
                Text(
                  '#SPB-${booking.id.substring(0, booking.id.length.clamp(0, 8)).toUpperCase()}',
                  style: const TextStyle(fontSize: 12, color: _mdOnSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              booking.slot.court.name,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _mdOnSurface),
            ),
            const SizedBox(height: 2),
            Text(
              _dateFmt.format(start),
              style: const TextStyle(fontSize: 13, color: _mdOnSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: _mdOutlineVariant),
            const SizedBox(height: 12),
            // Slot time row
            _BookedSlot(
              time: '${_timeFmt.format(start)} – ${_timeFmt.format(end)}',
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: _mdOutlineVariant),
            const SizedBox(height: 12),
            _SummaryRow(label: l10n.bookingDetailMode, value: l10n.wizardOpen),
            const SizedBox(height: 6),
            _SummaryRow(
              label: l10n.wizardLabelTotal,
              value: _formatPrice(booking.totalPrice),
              bold: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone_outlined, size: 16),
                    label: Text(l10n.bookingDetailCallOwner),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _mdOnSurface,
                      side: const BorderSide(color: _mdOutlineVariant),
                      shape: const RoundedRectangleBorder(borderRadius: _mdCornerMd),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: Text(l10n.slotPickerDirections),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _mdOnSurface,
                      side: const BorderSide(color: _mdOutlineVariant),
                      shape: const RoundedRectangleBorder(borderRadius: _mdCornerMd),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BookedSlot extends StatelessWidget {
  const _BookedSlot({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _mdSurfaceContainer,
        borderRadius: _mdCornerMd,
      ),
      child: Row(
        children: [
          Container(
            width: 4, height: 32,
            decoration: BoxDecoration(color: _mdPrimary, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 10),
          Text(time, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _mdOnSurface)),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: _mdOnSurfaceVariant)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: bold ? _mdOnSurface : _mdOnSurfaceVariant,
            fontFamily: bold ? 'Sora' : null,
          ),
        ),
      ],
    );
  }
}

// ─── Participants card ────────────────────────────────────────────────────────

class _ParticipantsCard extends StatelessWidget {
  const _ParticipantsCard({required this.joinRequests});

  final List<JoinRequest> joinRequests;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final approved = joinRequests.where((r) => r.status == 'approved').toList();

    return Container(
      decoration: BoxDecoration(
        color: _mdSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _mdOutlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.bookingDetailPlayers,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _mdOnSurface),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '· ${approved.length + 1}/4',
                      style: const TextStyle(fontSize: 16, color: _mdOnSurfaceVariant, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: _mdPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                  child: Text(l10n.bookingDetailInvite, style: const TextStyle(fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Host row (placeholder - real data would come from booking)
            _PlayerRow(
              name: l10n.bookingDetailYouHost,
              sub: l10n.bookingDetailHostRole,
              initials: 'TM',
              color: _mdPrimary,
              isHost: true,
            ),
            if (approved.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (final req in approved) ...[
                _PlayerRow(
                  name: req.userName,
                  sub: l10n.bookingDetailAcceptedAt(req.createdAt),
                  initials: _initials(req.userName),
                  color: _mdSurfaceContainerHighest,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return (parts.first[0] + parts.last[0]).toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.name,
    required this.sub,
    required this.initials,
    required this.color,
    this.isHost = false,
  });

  final String name;
  final String sub;
  final String initials;
  final Color color;
  final bool isHost;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                color: isHost ? _mdOnPrimary : _mdOnSurface,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _mdOnSurface)),
                  if (isHost) ...[
                    const SizedBox(width: 6),
                    Container(
                      height: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      decoration: BoxDecoration(color: _mdPrimaryContainer, borderRadius: _mdCornerFull),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context).bookingDetailHostRole,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _mdOnPrimaryContainer),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(sub, style: const TextStyle(fontSize: 12, color: _mdOnSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Join requests card ───────────────────────────────────────────────────────

class _JoinRequestsCard extends StatelessWidget {
  const _JoinRequestsCard({
    required this.joinRequests,
    required this.slotId,
    required this.processing,
  });

  final List<JoinRequest> joinRequests;
  final String slotId;
  final Set<String> processing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pending = joinRequests.where((r) => r.status == 'pending').toList();

    return Container(
      decoration: BoxDecoration(
        color: _mdSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _mdOutlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.bookingDetailJoinRequests,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _mdOnSurface),
                ),
                if (pending.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(color: _mdTertiaryContainer, borderRadius: _mdCornerFull),
                    child: Center(
                      child: Text(
                        l10n.bookingDetailNewCount(pending.length),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _mdOnTertiaryContainer),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (pending.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n.bookingDetailNoRequests,
                  style: const TextStyle(fontSize: 13, color: _mdOnSurfaceVariant),
                ),
              )
            else
              for (int i = 0; i < pending.length; i++) ...[
                if (i > 0) ...[
                  const SizedBox(height: 12),
                  Container(height: 1, color: _mdOutlineVariant),
                  const SizedBox(height: 12),
                ],
                _RequestRow(
                  request: pending[i],
                  slotId: slotId,
                  busy: processing.contains(pending[i].id),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({
    required this.request,
    required this.slotId,
    required this.busy,
  });

  final JoinRequest request;
  final String slotId;

  /// An approve/reject call for this request is in flight.
  final bool busy;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return (parts.first[0] + parts.last[0]).toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: _mdSurfaceContainerHighest, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  _initials(request.userName),
                  style: const TextStyle(color: _mdOnSurface, fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request.userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _mdOnSurface)),
                  Text(request.status, style: const TextStyle(fontSize: 12, color: _mdOnSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: busy
                    ? null
                    : () => context
                        .read<BookingDetailCubit>()
                        .reject(request.id, slotId),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _mdError,
                  side: const BorderSide(color: _mdOutlineVariant),
                  shape: const RoundedRectangleBorder(borderRadius: _mdCornerMd),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: Text(l10n.bookingJoinRejected, style: const TextStyle(fontSize: 13)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: busy
                    ? null
                    : () => context
                        .read<BookingDetailCubit>()
                        .approve(request.id, slotId),
                style: FilledButton.styleFrom(
                  backgroundColor: _mdPrimary,
                  foregroundColor: _mdOnPrimary,
                  disabledBackgroundColor: _mdSurfaceContainerHighest,
                  shape: const RoundedRectangleBorder(borderRadius: _mdCornerMd),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _mdOnPrimary,
                        ),
                      )
                    : Text(l10n.bookingDetailAccept, style: const TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Bottom actions ───────────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: _mdSurface,
        border: Border(top: BorderSide(color: _mdOutlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.push('/slot/${booking.slot.id}/manage'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _mdOnSurface,
                side: const BorderSide(color: _mdOutlineVariant),
                shape: const RoundedRectangleBorder(borderRadius: _mdCornerFull),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(l10n.bookingDetailManagePlayers),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.map_outlined, size: 18),
              label: Text(l10n.slotPickerDirections),
              style: FilledButton.styleFrom(
                backgroundColor: _mdPrimary,
                foregroundColor: _mdOnPrimary,
                shape: const RoundedRectangleBorder(borderRadius: _mdCornerFull),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── M3Badge ──────────────────────────────────────────────────────────────────

class _M3Badge extends StatelessWidget {
  const _M3Badge({required this.status, required this.label});

  /// Raw DB status ('confirmed' | 'pending' | 'cancelled') — drives colours.
  final String status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, dot) = switch (status) {
      'confirmed' => (
          const Color(0xFFBBF7D0),
          const Color(0xFF002111),
          const Color(0xFF15803D),
        ),
      'pending' => (
          _mdTertiaryContainer,
          _mdOnTertiaryContainer,
          _mdTertiary,
        ),
      _ => (
          _mdSurfaceContainerHighest,
          _mdOnSurfaceVariant,
          _mdOnSurfaceVariant,
        ),
    };

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: bg, borderRadius: _mdCornerFull),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }
}

// ─── Error body ───────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: _mdOnSurfaceVariant)),
      ),
    );
  }
}
