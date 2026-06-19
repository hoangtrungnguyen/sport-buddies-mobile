// Booking info card for the booking detail screen: court/time summary, booked
// slots, summary rows and the status badge. Extracted from
// booking_detail_screen.dart.

import 'package:customer/features/bookings/booking_model.dart';
import 'package:customer/features/bookings/bookings_style.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingInfoCard extends StatelessWidget {
  const BookingInfoCard({super.key, required this.booking});

  final Booking booking;

  static final _timeFmt = DateFormat('HH:mm');
  static final _dateFmt = DateFormat("EEEE, dd/MM", 'vi');
  static final _priceFmt = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '',
    decimalDigits: 0,
  );

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
      'pending' => l10n.bookingStatusPendingHost,
      'cancelled' => l10n.bookingStatusCancelled,
      _ => booking.status,
    };

    return Container(
      decoration: BoxDecoration(
        color: mdSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mdOutlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: mdOnSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              booking.slot.court.name,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: mdOnSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _dateFmt.format(start),
              style: const TextStyle(fontSize: 13, color: mdOnSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: mdOutlineVariant),
            const SizedBox(height: 12),
            // Slot time row
            _BookedSlot(
              time: '${_timeFmt.format(start)} – ${_timeFmt.format(end)}',
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: mdOutlineVariant),
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
                      foregroundColor: mdOnSurface,
                      side: const BorderSide(color: mdOutlineVariant),
                      shape: const RoundedRectangleBorder(
                        borderRadius: mdCornerMd,
                      ),
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
                      foregroundColor: mdOnSurface,
                      side: const BorderSide(color: mdOutlineVariant),
                      shape: const RoundedRectangleBorder(
                        borderRadius: mdCornerMd,
                      ),
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
      decoration: const BoxDecoration(
        color: mdSurfaceContainer,
        borderRadius: mdCornerMd,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: mdPrimary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: mdOnSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: mdOnSurfaceVariant),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: bold ? mdOnSurface : mdOnSurfaceVariant,
            fontFamily: bold ? 'Sora' : null,
          ),
        ),
      ],
    );
  }
}

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
      'pending' => (mdTertiaryContainer, mdOnTertiaryContainer, mdTertiary),
      _ => (mdSurfaceContainerHighest, mdOnSurfaceVariant, mdOnSurfaceVariant),
    };

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: bg, borderRadius: mdCornerFull),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
