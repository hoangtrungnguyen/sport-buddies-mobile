import 'package:customer/features/booking/booking_stepper.dart';
import 'package:customer/features/booking/state/booking_cubit.dart';
import 'package:customer/features/booking/widgets/booking_step1_content.dart';
import 'package:customer/features/booking/widgets/booking_confirm_button.dart';
import 'package:customer/core/l10n/error_messages.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
              content: Text(
                appErrorMessage(AppLocalizations.of(context), state.message),
              ),
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
            BookingLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            BookingLoaded(
              :final slot,
              :final pricePerHour,
              :final courtAddress,
            ) =>
              Column(
                children: [
                  const BookingStepper(step: 0),
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 100),
                          child: Step1Content(
                            slot: slot,
                            pricePerHour: pricePerHour,
                            nameCtrl: _nameCtrl,
                            phoneCtrl: _phoneCtrl,
                            notesCtrl: _notesCtrl,
                            courtAddress: courtAddress,
                          ),
                        ),
                        BottomConfirmBtn(
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
            BookingSubmitting() => const Column(
              children: [
                BookingStepper(step: 0),
                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: 100),
                        child: SizedBox(),
                      ),
                      BottomConfirmBtn(submitting: true),
                    ],
                  ),
                ),
              ],
            ),
            BookingError(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  message,
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        );
      },
    );
  }
}
