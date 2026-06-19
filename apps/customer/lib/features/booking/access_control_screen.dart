import 'package:customer/features/booking/booking_stepper.dart';
import 'package:customer/features/booking/state/access_control_cubit.dart';
import 'package:customer/features/booking/state/access_control_state.dart';
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
            builder: (sheetCtx) => _SlotTakenSheet(
              onPickAnother: () {
                Navigator.of(sheetCtx).pop();
                context.go('/court/${widget.courtId}/slots');
              },
            ),
          );
        } else if (state is AccessControlFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
                            const _SuccessCircle(),
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
                      _PolicyCard(
                        value: 'closed',
                        label: l10n.wizardPrivate,
                        description: l10n.wizardPrivateDesc,
                        selected: _policy == 'closed',
                        onTap: isSaving ? null : () => _setPolicy('closed'),
                      ),
                      const SizedBox(height: 10),
                      _PolicyCard(
                        value: 'open',
                        label: l10n.wizardOpen,
                        description: l10n.wizardOpenDesc,
                        selected: _policy == 'open',
                        onTap: isSaving ? null : () => _setPolicy('open'),
                        child: _policy == 'open'
                            ? _MaxPlayersStepper(
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

class _SuccessCircle extends StatelessWidget {
  const _SuccessCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xFF16A34A),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({
    required this.value,
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
    this.child,
  });

  final String value;
  final String label;
  final String description;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
          border: Border.all(
            color: selected ? const Color(0xFF16A34A) : const Color(0xFFE5E7EB),
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RadioCircle(selected: selected),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? const Color(0xFF15803D)
                          : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  if (child != null) ...[const SizedBox(height: 14), child!],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioCircle extends StatelessWidget {
  const _RadioCircle({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? const Color(0xFF16A34A) : Colors.white,
        border: Border.all(
          color: selected ? const Color(0xFF16A34A) : const Color(0xFFD1D5DB),
          width: 2,
        ),
      ),
      child: selected
          ? const Center(
              child: SizedBox(
                width: 8,
                height: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _MaxPlayersStepper extends StatelessWidget {
  const _MaxPlayersStepper({
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int value;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).wizardMaxPlayers,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _StepperButton(
                icon: Icons.remove,
                onTap: onDecrement,
                active: false,
              ),
              Expanded(
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              _StepperButton(icon: Icons.add, onTap: onIncrement, active: true),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context).wizardMaxPlayersHint,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.active,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF16A34A) : Colors.white,
          border: Border.all(
            color: active ? const Color(0xFF16A34A) : const Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: active ? Colors.white : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}

class _SlotTakenSheet extends StatelessWidget {
  const _SlotTakenSheet({required this.onPickAnother});

  final VoidCallback onPickAnother;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 40,
                color: Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.accessSlotTakenTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.accessSlotTakenBody,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: onPickAnother,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: const Color(0xFF16A34A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                l10n.wizardPickAnotherTime,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
