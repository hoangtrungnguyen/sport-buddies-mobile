// Contact info form (name / phone / notes) for the confirm step, pushing edits
// into the wizard cubit (doc 02 §1). Extracted from step_1_confirm.dart.

import 'package:customer/features/booking/wizard/cubit/booking_wizard_cubit.dart';
import 'package:customer/features/booking/wizard/domain/booking.dart';
import 'package:customer/features/court/theme/app_tokens.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactForm extends StatefulWidget {
  const ContactForm({super.key, required this.contact});

  final ContactInfo contact;

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  late final _name = TextEditingController(text: widget.contact.name);
  late final _phone = TextEditingController(text: widget.contact.phone);
  late final _note = TextEditingController(text: widget.contact.note ?? '');

  void _push() {
    context.read<BookingWizardCubit>().updateContact(
      ContactInfo(
        name: _name.text,
        phone: _phone.text,
        note: _note.text.isEmpty ? null : _note.text,
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _Field(
          label: l10n.bookingFieldName,
          controller: _name,
          onChanged: (_) => _push(),
        ),
        const SizedBox(height: 12),
        _Field(
          label: l10n.bookingFieldPhone,
          controller: _phone,
          keyboardType: TextInputType.phone,
          icon: Icons.phone,
          onChanged: (_) => _push(),
        ),
        const SizedBox(height: 12),
        _Field(
          label: l10n.bookingFieldNotes,
          controller: _note,
          hint: l10n.bookingNotesHint,
          maxLines: 2,
          onChanged: (_) => _push(),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: text.bodyMedium?.copyWith(fontSize: 16),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            filled: true,
            fillColor: scheme.surfaceContainerHighest,
            prefixIcon: icon == null ? null : Icon(icon, size: 20),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppTokens.cornerSm),
              ),
              borderSide: BorderSide.none,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: scheme.outline),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: scheme.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
