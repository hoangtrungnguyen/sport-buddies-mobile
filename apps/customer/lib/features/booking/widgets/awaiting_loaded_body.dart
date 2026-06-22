// Main body of the awaiting-confirmation screen in the loaded state: pulsing
// clock, booking detail card, status timeline and "view bookings" escape hatch.
// Includes its private label/value detail row.
// Extracted from awaiting_confirmation_screen.dart.

import 'package:customer/features/booking/booking_stepper.dart';
import 'package:customer/features/booking/state/awaiting_confirmation_state.dart';
import 'package:customer/features/booking/widgets/awaiting_timeline_section.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class LoadedBody extends StatelessWidget {
  const LoadedBody({super.key, required this.state, required this.pulseAnim});

  final AwaitingLoaded state;
  final Animation<double> pulseAnim;

  static final _timeFmt = DateFormat('HH:mm');
  static final _dateFmt = DateFormat('EEE, dd/MM', 'vi');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shortId = state.bookingId.split('-').first.toUpperCase();

    return Column(
      children: [
        const BookingStepper(step: 2),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              children: [
                // Pulsing clock ring
                ScaleTransition(
                  scale: pulseAnim,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEF9C3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 104,
                        height: 104,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.schedule,
                          size: 52,
                          color: Color(0xFFCA8A04),
                        ),
                      ),
                      const Positioned(
                        top: 0,
                        child: CircleAvatar(
                          radius: 6,
                          backgroundColor: Color(0xFFCA8A04),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.wizardWaitingTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.awaitingBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 32),
                // Booking detail card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        label: l10n.wizardBookingId,
                        value: shortId,
                        valueStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _DetailRow(
                        label: l10n.wizardLabelCourt,
                        value: state.courtName,
                      ),
                      const SizedBox(height: 10),
                      _DetailRow(
                        label: l10n.paymentTime,
                        value:
                            '${_timeFmt.format(state.slotStart)} – ${_timeFmt.format(state.slotEnd)}',
                      ),
                      const SizedBox(height: 10),
                      _DetailRow(
                        label: l10n.wizardLabelDate,
                        value: _dateFmt.format(state.slotStart),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF9C3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 6,
                              color: Color(0xFFCA8A04),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              l10n.bookingStatusPendingHost,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                TimelineSection(submittedAt: state.slotStart),
              ],
            ),
          ),
        ),
        // Escape hatch — always visible
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: OutlinedButton(
            onPressed: () => context.go('/bookings/upcoming'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: Color(0xFFD1D5DB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              AppLocalizations.of(context).wizardViewBookings,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.valueStyle});

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        Text(
          value,
          style:
              valueStyle ??
              const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
        ),
      ],
    );
  }
}
