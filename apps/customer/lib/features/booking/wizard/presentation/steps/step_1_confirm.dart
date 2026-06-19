// Step 1 · Confirm — "Xác nhận đặt sân" (SPB-042, handoff doc 02 Step 1).

import 'package:customer/features/booking/wizard/cubit/booking_wizard_cubit.dart';
import 'package:customer/features/booking/wizard/domain/booking.dart';
import 'package:customer/features/booking/wizard/domain/play_session.dart';
import 'package:customer/features/booking/wizard/presentation/widgets/common.dart';
import 'package:customer/features/booking/wizard/presentation/wizard_format.dart';
import 'package:customer/features/court/domain/booking_draft.dart';
import 'package:customer/features/court/theme/app_tokens.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Step1Confirm extends StatelessWidget {
  const Step1Confirm({super.key, required this.state});

  final BookingWizardState state;

  @override
  Widget build(BuildContext context) {
    final draft = state.draft;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final merged = hasMerge(draft.slots);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        _CourtSummaryCard(draft: draft),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.bookingSelectedSlot, style: text.titleMedium),
            CountBadge(
              label: countLabel(l10n, state.slotCount, draft.totalDuration),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...List.generate(draft.slots.length, (i) {
          final s = draft.slots[i];
          final adjacent =
              i > 0 &&
              draft.slots[i - 1].courtId == s.courtId &&
              draft.slots[i - 1].end == s.start;
          return Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
            child: _SlotLine(slot: s, adjacent: adjacent),
          );
        }),
        if (merged) ...[
          const SizedBox(height: 10),
          _MergeNotice(slots: draft.slots),
        ],
        const SizedBox(height: 16),
        SummaryRow(
          label: l10n.bookingTotalDuration,
          value: durationLabel(l10n, draft.totalDuration),
        ),
        SummaryRow(label: l10n.wizardTotalRent, value: vnd(draft.totalVnd)),
        SummaryRow(label: l10n.bookingServiceFee, value: l10n.bookingFree),
        const SizedBox(height: 12),
        _TotalBar(totalVnd: draft.totalVnd),
        const SizedBox(height: 10),
        CashNotice(title: l10n.bookingCashAtCourt),
        const SizedBox(height: 24),
        Text(l10n.bookingContactInfo, style: text.titleMedium),
        const SizedBox(height: 10),
        _ContactForm(contact: state.contact),
        const SizedBox(height: 8),
        // soft hint to anchor the bottom on short drafts
        Text(
          l10n.wizardContactHint,
          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _CourtSummaryCard extends StatelessWidget {
  const _CourtSummaryCard({required this.draft});

  final BookingDraft draft;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: AppTokens.radiusMd,
        boxShadow: AppTokens.elev1,
      ),
      child: Row(
        children: [
          SportTile(sport: draft.sport),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(draft.courtLabel, style: text.titleSmall),
                const SizedBox(height: 2),
                Text(
                  draft.address,
                  style: text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotLine extends StatelessWidget {
  const _SlotLine({required this.slot, required this.adjacent});

  final SlotSelection slot;
  final bool adjacent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final sub = [
      dateLabel(l10n, slot.date),
      slot.courtLabel,
      durationLabel(l10n, slot.duration),
      if (adjacent) l10n.wizardAdjacent,
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: AppTokens.radiusMd,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeRange(slot.start, slot.end),
                  style: text.labelLarge?.copyWith(
                    fontFeatures: AppTokens.tnum,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            vnd(slot.priceVnd),
            style: text.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: AppTokens.tnum,
            ),
          ),
        ],
      ),
    );
  }
}

class _MergeNotice extends StatelessWidget {
  const _MergeNotice({required this.slots});

  final List<SlotSelection> slots;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    // Derived copy — name the slots composing the first merged run.
    final session = mergeSessions(slots).firstWhere((s) => s.isMerged);
    final parts = slots
        .where(
          (s) =>
              !s.start.isBefore(session.start) && !s.end.isAfter(session.end),
        )
        .map((s) => timeRange(s.start, s.end))
        .toList();
    final names = parts.join(' ${l10n.wizardAnd} ');
    final copy = l10n.wizardMergeNotice(
      names,
      durationLabel(l10n, session.duration),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: AppTokens.radiusMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚡', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              copy,
              style: text.bodySmall?.copyWith(color: scheme.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalBar extends StatelessWidget {
  const _TotalBar({required this.totalVnd});

  final int totalVnd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: AppTokens.radiusMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context).bookingTotalPayment,
            style: text.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
          Text(
            vnd(totalVnd),
            style: text.headlineSmall?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: scheme.primary,
              fontFeatures: AppTokens.tnum,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactForm extends StatefulWidget {
  const _ContactForm({required this.contact});

  final ContactInfo contact;

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
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
