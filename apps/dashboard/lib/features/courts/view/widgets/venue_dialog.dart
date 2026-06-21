import 'package:dashboard/core/widgets/button_spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../setup/model/owner_court.dart';
import '../../bloc/venue_bloc.dart';
import '../../model/venue.dart';
import '../../repository/venue_repository.dart';
import '../../util/court_format.dart';

/// Opens the add/edit venue dialog. Resolves the repo + bloc from [context]
/// before pushing so the dialog (a separate route) doesn't depend on them.
Future<void> openVenueDialog(BuildContext context, String courtId,
    {Venue? venue}) {
  final repo = context.read<VenueRepository>();
  final bloc = context.read<VenueBloc>();
  return showDialog<void>(
    context: context,
    builder: (_) => _VenueDialog(
      courtId: courtId,
      venue: venue,
      repo: repo,
      bloc: bloc,
    ),
  );
}

class _VenueDialog extends StatefulWidget {
  const _VenueDialog({
    required this.courtId,
    required this.venue,
    required this.repo,
    required this.bloc,
  });
  final String courtId;
  final Venue? venue;
  final VenueRepository repo;
  final VenueBloc bloc;

  @override
  State<_VenueDialog> createState() => _VenueDialogState();
}

class _VenueDialogState extends State<_VenueDialog> {
  late final TextEditingController _name =
      TextEditingController(text: widget.venue?.name ?? '');
  late final TextEditingController _price = TextEditingController(
      text: widget.venue != null ? widget.venue!.pricePerHour.toString() : '');
  late final TextEditingController _capacity = TextEditingController(
      text: widget.venue != null ? widget.venue!.capacity.toString() : '1');
  late String _sport = widget.venue?.sportType.isNotEmpty == true
      ? widget.venue!.sportType
      : kSportTypes.first;
  late bool _indoor = widget.venue?.indoor ?? false;
  bool _saving = false;

  bool get _isEdit => widget.venue != null;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _capacity.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    try {
      final price = int.tryParse(_price.text.trim()) ?? 0;
      final capacity = int.tryParse(_capacity.text.trim()) ?? 1;
      if (_isEdit) {
        await widget.repo.update(widget.venue!.id,
            name: _name.text.trim(),
            sportType: _sport,
            capacity: capacity,
            pricePerHour: price,
            indoor: _indoor);
      } else {
        await widget.repo.create(
            courtId: widget.courtId,
            name: _name.text.trim(),
            sportType: _sport,
            capacity: capacity,
            pricePerHour: price,
            indoor: _indoor);
      }
      widget.bloc.add(const VenueEvent.reloadRequested());
      nav.pop();
      messenger.showSnackBar(SnackBar(
          content: Text(_isEdit ? 'Đã lưu thay đổi' : 'Đã thêm sân con')));
    } catch (e) {
      // Surface the real cause (e.g. PostgREST permission / RLS message) — the
      // repository already logs it; a bare "thử lại" hides why the save failed.
      if (mounted) {
        setState(() => _saving = false);
        messenger.showSnackBar(SnackBar(content: Text('Không thể lưu: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      icon: CircleAvatar(
        radius: 24,
        backgroundColor: scheme.secondaryContainer,
        child: Icon(Symbols.sports_tennis, color: scheme.onSecondaryContainer),
      ),
      title: Text(_isEdit ? 'Sửa sân con' : 'Thêm sân con'),
      content: _content(),
      actions: _actions(),
    );
  }

  /// Name + sport + price/capacity + indoor-outdoor form fields.
  Widget _content() {
    return SizedBox(
      width: 380,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _nameField(),
          const SizedBox(height: 16),
          _sportField(),
          const SizedBox(height: 16),
          _priceCapacityRow(),
          const SizedBox(height: 16),
          _indoorOutdoorToggle(),
        ],
      ),
    );
  }

  Widget _nameField() {
    return TextField(
      controller: _name,
      autofocus: true,
      decoration: const InputDecoration(labelText: 'Tên sân con'),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _sportField() {
    return DropdownButtonFormField<String>(
      initialValue: _sport,
      decoration: const InputDecoration(labelText: 'Môn thể thao'),
      items: [
        for (final s in kSportTypes) DropdownMenuItem(value: s, child: Text(s)),
      ],
      onChanged: (v) => setState(() => _sport = v ?? _sport),
    );
  }

  /// Price (with a formatted-amount helper line) beside the capacity field.
  Widget _priceCapacityRow() {
    final priceVal = int.tryParse(_price.text.trim());
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _price,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Giá / giờ',
              helperText: priceVal != null && priceVal > 0
                  ? formatPricePerHour(priceVal)
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 110,
          child: TextField(
            controller: _capacity,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Sức chứa'),
          ),
        ),
      ],
    );
  }

  Widget _indoorOutdoorToggle() {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(
          value: true,
          icon: Icon(Symbols.roofing, size: 18),
          label: Text('Trong nhà'),
        ),
        ButtonSegment(
          value: false,
          icon: Icon(Symbols.sunny, size: 18),
          label: Text('Ngoài trời'),
        ),
      ],
      selected: {_indoor},
      onSelectionChanged: (s) => setState(() => _indoor = s.first),
    );
  }

  /// Huỷ + Lưu dialog actions.
  List<Widget> _actions() {
    return [
      TextButton(
        onPressed: _saving ? null : () => Navigator.of(context).pop(),
        child: const Text('Huỷ'),
      ),
      FilledButton(
        onPressed: (_saving || _name.text.trim().isEmpty) ? null : _save,
        child: _saving ? const ButtonSpinner() : const Text('Lưu'),
      ),
    ];
  }
}
