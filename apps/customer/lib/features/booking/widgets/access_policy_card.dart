// Access-policy card (auto/manual approval) and the max-players stepper for
// the access-control screen. Extracted from access_control_screen.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PolicyCard extends StatelessWidget {
  const PolicyCard({
    super.key,
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

class MaxPlayersStepper extends StatelessWidget {
  const MaxPlayersStepper({
    super.key,
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
