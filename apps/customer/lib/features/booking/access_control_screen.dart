import 'package:customer/features/booking/booking_stepper.dart';
import 'package:customer/features/booking/state/access_control_cubit.dart';
import 'package:customer/features/booking/state/access_control_state.dart';
import 'package:customer/features/booking/widgets/access_success_circle.dart';
import 'package:customer/features/booking/widgets/access_policy_card.dart';
import 'package:customer/features/booking/widgets/access_slot_taken_sheet.dart';
import 'package:customer/core/l10n/error_messages.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AccessControlScreen extends StatefulWidget {
  const AccessControlScreen({
    super.key,
    required this.slotId,
    required this.name,
    required this.phone,
    this.notes,
    required this.courtId,
    this.pricePerHour,
    required this.durationMinutes,
    this.totalPrice,
  });

  final String slotId;
  final String name;
  final String phone;
  final String? notes;
  final String courtId;
  final double? pricePerHour;
  final int durationMinutes;
  final double? totalPrice;

  @override
  State<AccessControlScreen> createState() => _AccessControlScreenState();
}

class _AccessControlScreenState extends State<AccessControlScreen> {
  String _policy = 'closed';
  int _maxPlayers = 4;

  void _setPolicy(String policy) => setState(() {
    _policy = policy;
  });

  void _incrementMaxPlayers() {
    if (_maxPlayers < 20) setState(() => _maxPlayers++);
  }

  void _decrementMaxPlayers() {
    if (_maxPlayers > 2) setState(() => _maxPlayers--);
  }

  void _save() {
    context.read<AccessControlCubit>().submitAndSave(
      slotId: widget.slotId,
      name: widget.name,
      phone: widget.phone,
      notes: widget.notes,
      courtId: widget.courtId,
      pricePerHour: widget.pricePerHour,
      durationMinutes: widget.durationMinutes,
      totalPrice: widget.totalPrice,
      policy: _policy,
      maxPlayers: _maxPlayers,
    );
  }

  void _skip() {
    context.read<AccessControlCubit>().submitAndSave(
      slotId: widget.slotId,
      name: widget.name,
      phone: widget.phone,
      notes: widget.notes,
      courtId: widget.courtId,
      pricePerHour: widget.pricePerHour,
      durationMinutes: widget.durationMinutes,
      totalPrice: widget.totalPrice,
      policy: 'closed',
      maxPlayers: 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccessControlCubit, AccessControlState>(
      listener: (context, state) {
        if (state is AccessControlSaved) {
          context.go('/booking/awaiting/${state.bookingId}');
        } else if (state is AccessControlSlotTaken) {
          showModalBottomSheet<void>(
            context: context,
            isDismissible: false,
            enableDrag: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (sheetCtx) => SlotTakenSheet(
              onPickAnother: () {
                Navigator.of(sheetCtx).pop();
                context.go('/court/${widget.courtId}/slots');
              },
            ),
          );
        } else if (state is AccessControlFailure) {
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
        final l10n = AppLocalizations.of(context);
        final isSaving = state is AccessControlSaving;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(l10n.wizardStepPlayTitle),
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              TextButton(
                onPressed: isSaving ? null : _skip,
                child: Text(
                  l10n.wizardSkip,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              const BookingStepper(step: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Owner confirmation banner
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const SuccessCircle(),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.accessSlotSelected,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                  Text(
                                    l10n.wizardPickPlayers,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF16A34A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.wizardWhoCanJoin,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.accessApplies,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 16),
                      PolicyCard(
                        value: 'closed',
                        label: l10n.wizardPrivate,
                        description: l10n.wizardPrivateDesc,
                        selected: _policy == 'closed',
                        onTap: isSaving ? null : () => _setPolicy('closed'),
                      ),
                      const SizedBox(height: 10),
                      PolicyCard(
                        value: 'open',
                        label: l10n.wizardOpen,
                        description: l10n.wizardOpenDesc,
                        selected: _policy == 'open',
                        onTap: isSaving ? null : () => _setPolicy('open'),
                        child: _policy == 'open'
                            ? MaxPlayersStepper(
                                value: _maxPlayers,
                                onIncrement: isSaving
                                    ? null
                                    : _incrementMaxPlayers,
                                onDecrement: isSaving
                                    ? null
                                    : _decrementMaxPlayers,
                              )
                            : null,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: FilledButton(
                  onPressed: isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: const Color(0xFF16A34A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.wizardSaveContinue,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
