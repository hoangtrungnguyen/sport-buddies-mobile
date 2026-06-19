// Step 1 (confirm details) content for the booking screen: court card, slot
// lines, price summary and the contact form. Extracted from booking_screen.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/spb_core.dart';

import 'booking_contact_form.dart';

class Step1Content extends StatelessWidget {
  const Step1Content({
    super.key,
    required this.slot,
    required this.pricePerHour,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.notesCtrl,
    this.courtAddress,
  });

  final Slot slot;
  final double? pricePerHour;
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController notesCtrl;
  final String? courtAddress;

  static final _timeFmt = DateFormat('HH:mm');
  static final _dateFmt = DateFormat('EEE, dd/MM', 'vi');
  static final _priceFmt = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final durationH = slot.endTime.difference(slot.startTime).inMinutes / 60.0;
    final hoursStr = durationH == durationH.roundToDouble()
        ? '${durationH.toInt()}'
        : durationH.toStringAsFixed(1);
    final durationLabel = l10n.bookingDurationHours(hoursStr);
    final totalPrice = pricePerHour != null ? pricePerHour! * durationH : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CourtCard(courtName: slot.courtName, address: courtAddress),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.bookingSelectedSlot,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  l10n.bookingSlotCountDuration(durationLabel),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SlotLine(
            time:
                '${_timeFmt.format(slot.startTime.toLocal())} – ${_timeFmt.format(slot.endTime.toLocal())}',
            date: _dateFmt.format(slot.startTime.toLocal()),
            sub: durationLabel,
            price: pricePerHour != null
                ? _priceFmt.format(pricePerHour! * durationH)
                : '—',
          ),
          const SizedBox(height: 16),
          _SummaryRow(k: l10n.bookingTotalDuration, v: durationLabel),
          _SummaryRow(
            k: l10n.bookingRentPrice,
            v: pricePerHour != null
                ? l10n.bookingPricePerHour(_priceFmt.format(pricePerHour!))
                : '—',
          ),
          _SummaryRow(k: l10n.bookingServiceFee, v: l10n.bookingFree),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.bookingTotalPayment,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
                Text(
                  totalPrice != null ? _priceFmt.format(totalPrice) : '—',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9C3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  color: Color(0xFF92670B),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.bookingCashAtCourt,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF92670B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.bookingContactInfo,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          ContactForm(
            nameCtrl: nameCtrl,
            phoneCtrl: phoneCtrl,
            notesCtrl: notesCtrl,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets
// ---------------------------------------------------------------------------

class _CourtCard extends StatelessWidget {
  const _CourtCard({required this.courtName, this.address});

  final String courtName;
  final String? address;

  @override
  Widget build(BuildContext context) {
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.sports_tennis,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courtName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                if (address != null && address!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    address!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotLine extends StatelessWidget {
  const _SlotLine({
    required this.time,
    required this.date,
    required this.sub,
    required this.price,
  });

  final String time;
  final String date;
  final String sub;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$date · $sub',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.k, required this.v});

  final String k;
  final String v;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            k,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          Text(
            v,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}
