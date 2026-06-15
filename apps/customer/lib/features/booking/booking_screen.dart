import 'package:customer/features/booking/booking_stepper.dart';
import 'package:customer/features/booking/state/booking_cubit.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/spb_core.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.slotId});

  final String slotId;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _populated = false;

  @override
  void initState() {
    super.initState();
    context.read<BookingCubit>().load(widget.slotId);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _populateControllers(BookingLoaded state) {
    if (_populated) return;
    _nameCtrl.text = state.name;
    _phoneCtrl.text = state.phone;
    _populated = true;
  }

  /// Name + phone are required so the court owner can reach the player.
  /// Phone must look like a VN number (9–11 digits, optional +).
  bool _validateContact(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    String? error;
    if (name.isEmpty) {
      error = l10n.bookingValidationName;
    } else if (phone.isEmpty) {
      error = l10n.bookingValidationPhone;
    } else if (!RegExp(r'^\+?\d{9,11}$').hasMatch(phone)) {
      error = l10n.bookingValidationPhoneInvalid;
    }
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is BookingLoaded) _populateControllers(state);
        if (state is BookingSlotTaken) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).bookingSlotTaken),
              backgroundColor: Colors.orange,
            ),
          );
          context.pop();
        }
        if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).bookingConfirmTitle),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const BackButton(),
          ),
          body: switch (state) {
            BookingLoading() => const Center(child: CircularProgressIndicator()),
            BookingLoaded(:final slot, :final pricePerHour, :final courtAddress) => Column(
                children: [
                  const BookingStepper(step: 0),
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 100),
                          child: _Step1Content(
                            slot: slot,
                            pricePerHour: pricePerHour,
                            nameCtrl: _nameCtrl,
                            phoneCtrl: _phoneCtrl,
                            notesCtrl: _notesCtrl,
                            courtAddress: courtAddress,
                          ),
                        ),
                        _BottomConfirmBtn(
                          submitting: false,
                          onConfirm: () {
                            if (!_validateContact(context)) return;
                            final durationMinutes = slot.endTime
                                .difference(slot.startTime)
                                .inMinutes;
                            final totalPrice = pricePerHour != null
                                ? pricePerHour * durationMinutes / 60
                                : null;
                            context.go(
                              '/booking/access-control/${widget.slotId}',
                              extra: {
                                'name': _nameCtrl.text.trim(),
                                'phone': _phoneCtrl.text.trim(),
                                'notes': _notesCtrl.text.trim().isEmpty
                                    ? null
                                    : _notesCtrl.text.trim(),
                                'courtId': slot.courtId,
                                'pricePerHour': pricePerHour,
                                'durationMinutes': durationMinutes,
                                'totalPrice': totalPrice,
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            BookingSubmitting() => Column(
                children: [
                  const BookingStepper(step: 0),
                  Expanded(
                    child: Stack(
                      children: [
                        const SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: 100),
                          child: SizedBox(),
                        ),
                        const _BottomConfirmBtn(submitting: true),
                      ],
                    ),
                  ),
                ],
              ),
            BookingError(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(message,
                      style: const TextStyle(color: Color(0xFF6B7280))),
                ),
              ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Step 1 content
// ---------------------------------------------------------------------------

class _Step1Content extends StatelessWidget {
  const _Step1Content({
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
  static final _priceFmt =
      NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final durationH =
        slot.endTime.difference(slot.startTime).inMinutes / 60.0;
    final hoursStr = durationH == durationH.roundToDouble()
        ? '${durationH.toInt()}'
        : durationH.toStringAsFixed(1);
    final durationLabel = l10n.bookingDurationHours(hoursStr);
    final totalPrice =
        pricePerHour != null ? pricePerHour! * durationH : null;

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9C3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.payments_outlined,
                    color: Color(0xFF92670B), size: 20),
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
          _ContactForm(
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
            child: const Icon(Icons.sports_tennis,
                color: Colors.white, size: 28),
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
                      fontSize: 12, color: Color(0xFF6B7280)),
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
        border:
            Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF6B7280))),
          Text(v,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              )),
        ],
      ),
    );
  }
}

class _ContactForm extends StatelessWidget {
  const _ContactForm({
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.notesCtrl,
  });

  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController notesCtrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _EditableField(
          label: l10n.bookingFieldName,
          controller: nameCtrl,
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 12),
        _EditableField(
          label: l10n.bookingFieldPhone,
          controller: phoneCtrl,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        _EditableField(
          label: l10n.bookingFieldNotes,
          controller: notesCtrl,
          hint: l10n.bookingNotesHint,
          multiline: true,
        ),
      ],
    );
  }
}

class _EditableField extends StatelessWidget {
  const _EditableField({
    required this.label,
    required this.controller,
    this.hint,
    this.prefixIcon,
    this.multiline = false,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? prefixIcon;
  final bool multiline;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: multiline ? 3 : 1,
          style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: const Color(0xFF6B7280))
                : null,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF16A34A)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _BottomConfirmBtn extends StatelessWidget {
  const _BottomConfirmBtn({this.submitting = false, this.onConfirm});

  final bool submitting;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: FilledButton(
          onPressed: submitting ? null : onConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
            disabledBackgroundColor: const Color(0xFFD1D5DB),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: submitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  AppLocalizations.of(context).bookingConfirmTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
