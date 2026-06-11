import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../setup/bloc/court_bloc.dart';
import '../../setup/bloc/court_event.dart';
import '../../setup/bloc/court_state.dart';
import '../../setup/model/owner_court.dart';
import '../bloc/venue_bloc.dart';
import '../model/venue.dart';
import '../repository/venue_repository.dart';
import '../service/court_info_parser_service.dart';
import '../util/court_format.dart';
import 'widgets/court_widgets.dart';

class CourtDetailScreen extends StatelessWidget {
  const CourtDetailScreen({super.key, required this.courtId});
  final String courtId;

  @override
  Widget build(BuildContext context) {
    final court = context.select<CourtBloc, OwnerCourt?>(
      (bloc) => switch (bloc.state) {
        CourtLoaded(:final courts) =>
          courts.where((c) => c.id == courtId).firstOrNull,
        _ => null,
      },
    );

    if (court == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocListener<VenueBloc, VenueState>(
      listenWhen: (a, b) => b is VenueFailure,
      listener: (context, state) {
        if (state is VenueFailure) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Symbols.arrow_back),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/courts'),
          ),
          title: Text('Sân con · ${court.name}'),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 28, 32, 120),
              child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 820;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 340, child: _CourtInfoCard(court: court)),
                      const SizedBox(width: 24),
                      Expanded(child: _VenuePanel(court: court)),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CourtInfoCard(court: court),
                    const SizedBox(height: 20),
                    _VenuePanel(court: court),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Court info card
// ---------------------------------------------------------------------------

class _CourtInfoCard extends StatelessWidget {
  const _CourtInfoCard({required this.court});
  final OwnerCourt court;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Symbols.stadium,
                      size: 22, color: scheme.onSecondaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(court.name, style: theme.textTheme.titleMedium)),
              ],
            ),
            const SizedBox(height: 12),
            CourtStatusChip(
              status: court.isActive
                  ? CourtChipStatus.active
                  : CourtChipStatus.inactive,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            if (court.address != null && court.address!.isNotEmpty)
              _InfoRow(icon: Symbols.location_on, text: court.address!),
            if (court.lat != null && court.lng != null)
              _InfoRow(
                icon: Symbols.my_location,
                text:
                    '${court.lat!.toStringAsFixed(5)}, ${court.lng!.toStringAsFixed(5)}',
              ),
            if ((court.additionalInfo['phone'] as String?)?.isNotEmpty ?? false)
              _InfoRow(
                  icon: Symbols.call,
                  text: court.additionalInfo['phone'] as String),
            _InfoRow(
              icon: Symbols.schedule,
              text:
                  '${formatHour(court.openHour)} – ${formatHour(court.closeHour)}',
            ),
            if (court.amenities.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final a in court.amenities)
                    Chip(
                      avatar: Icon(amenityIcon(a), size: 16),
                      label: Text(a),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ],
            if (court.description != null && court.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(court.description!,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant, height: 1.5)),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _AutoApproveRow(court: court),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Symbols.edit, size: 18),
                label: const Text('Chỉnh sửa thông tin sân'),
                onPressed: () =>
                    context.go('/courts/${court.id}/edit', extra: court),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _AutoApproveRow extends StatelessWidget {
  const _AutoApproveRow({required this.court});
  final OwnerCourt court;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loading = context.select<CourtBloc, bool>((b) => b.state is CourtLoading);
    final on = court.autoApproveSingle;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: on ? scheme.primaryContainer : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: on ? scheme.primary : scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tự động duyệt đặt sân', style: theme.textTheme.titleSmall),
                Text(
                  on
                      ? 'Đặt sân một lần được duyệt tự động.'
                      : 'Cần duyệt thủ công từng yêu cầu.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Semantics(
            label: 'court-auto-approve-toggle',
            toggled: on,
            child: Switch(
              value: on,
              onChanged: loading
                  ? null
                  : (v) {
                      context.read<CourtBloc>().add(
                          CourtEvent.autoApproveToggled(court.id, value: v));
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã lưu cài đặt')));
                    },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Venue panel
// ---------------------------------------------------------------------------

class _VenuePanel extends StatelessWidget {
  const _VenuePanel({required this.court});
  final OwnerCourt court;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return BlocBuilder<VenueBloc, VenueState>(
      builder: (context, state) {
        final venues = state is VenueLoaded ? state.venues : const <Venue>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sân con · ${court.name}',
                          style: theme.textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text(
                        '${venues.length} sân · mở cửa ${formatHour(court.openHour)}–${formatHour(court.closeHour)}',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonalIcon(
                  icon: const Icon(Symbols.auto_awesome, size: 18),
                  label: const Text('Tạo nhanh bằng AI'),
                  onPressed: () => _openBulkAiSheet(context, court.id),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Symbols.add, size: 18),
                  label: const Text('Thêm sân con'),
                  onPressed: () => _openVenueDialog(context, court.id),
                ),
              ],
            ),
            const SizedBox(height: 16),
            switch (state) {
              VenueInitial() || VenueLoading() => const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator()),
                ),
              VenueLoaded(:final venues) when venues.isEmpty =>
                _EmptyVenues(courtId: court.id),
              VenueLoaded(:final venues) => _VenueGroups(
                  courtId: court.id, venues: venues),
              VenueFailure(:final message) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(message,
                      style: TextStyle(color: scheme.error)),
                ),
            },
          ],
        );
      },
    );
  }
}

class _VenueGroups extends StatelessWidget {
  const _VenueGroups({required this.courtId, required this.venues});
  final String courtId;
  final List<Venue> venues;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final groups = <String, List<Venue>>{};
    for (final v in venues) {
      groups.putIfAbsent(v.sportType.isEmpty ? 'Khác' : v.sportType, () => [])
          .add(v);
    }
    final keys = groups.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final sport in keys) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              children: [
                Icon(sportIcon(sport), size: 18, color: scheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text('$sport · ${groups[sport]!.length} sân',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          Card(
            color: scheme.surfaceContainerLowest,
            child: Column(
              children: [
                for (int i = 0; i < groups[sport]!.length; i++) ...[
                  if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                  _VenueRow(courtId: courtId, venue: groups[sport]![i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _VenueRow extends StatelessWidget {
  const _VenueRow({required this.courtId, required this.venue});
  final String courtId;
  final Venue venue;

  Future<void> _delete(BuildContext context) async {
    final repo = context.read<VenueRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final bloc = context.read<VenueBloc>();
    try {
      await repo.deactivate(venue.id);
      bloc.add(const VenueEvent.reloadRequested());
      messenger.showSnackBar(
        SnackBar(
          content: Text('Đã xoá ${venue.name}'),
          action: SnackBarAction(
            label: 'Hoàn tác',
            onPressed: () async {
              await repo.reactivate(venue.id);
              bloc.add(const VenueEvent.reloadRequested());
            },
          ),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Không thể xoá. Thử lại nhé.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(sportIcon(venue.sportType),
                size: 22, color: scheme.onSecondaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(venue.name, style: theme.textTheme.titleSmall),
                Text(
                  '${venue.sportType} · ${venue.capacity} người',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(formatPricePerHour(venue.pricePerHour),
              style: theme.textTheme.bodyMedium),
          IconButton(
            icon: const Icon(Symbols.edit, size: 20),
            tooltip: 'Sửa',
            onPressed: () =>
                _openVenueDialog(context, courtId, venue: venue),
          ),
          IconButton(
            icon: const Icon(Symbols.delete, size: 20),
            tooltip: 'Xoá',
            onPressed: () => _delete(context),
          ),
        ],
      ),
    );
  }
}

class _EmptyVenues extends StatelessWidget {
  const _EmptyVenues({required this.courtId});
  final String courtId;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(Symbols.grid_view, size: 36, color: scheme.outline),
          const SizedBox(height: 12),
          Text('Chưa có sân con nào', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Thêm từng sân, hoặc mô tả tất cả trong một câu để AI tạo giúp.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.tonalIcon(
                icon: const Icon(Symbols.auto_awesome, size: 18),
                label: const Text('Tạo nhanh bằng AI'),
                onPressed: () => _openBulkAiSheet(context, courtId),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                icon: const Icon(Symbols.add, size: 18),
                label: const Text('Thêm sân con'),
                onPressed: () => _openVenueDialog(context, courtId),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add / edit dialog
// ---------------------------------------------------------------------------

Future<void> _openVenueDialog(BuildContext context, String courtId,
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
            pricePerHour: price);
      } else {
        await widget.repo.create(
            courtId: widget.courtId,
            name: _name.text.trim(),
            sportType: _sport,
            capacity: capacity,
            pricePerHour: price);
      }
      widget.bloc.add(const VenueEvent.reloadRequested());
      nav.pop();
      messenger.showSnackBar(SnackBar(
          content: Text(_isEdit ? 'Đã lưu thay đổi' : 'Đã thêm sân con')));
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        messenger.showSnackBar(
            const SnackBar(content: Text('Không thể lưu. Thử lại nhé.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final priceVal = int.tryParse(_price.text.trim());
    return AlertDialog(
      icon: CircleAvatar(
        radius: 24,
        backgroundColor: scheme.secondaryContainer,
        child: Icon(Symbols.sports_tennis,
            color: scheme.onSecondaryContainer),
      ),
      title: Text(_isEdit ? 'Sửa sân con' : 'Thêm sân con'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Tên sân con'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _sport,
              decoration: const InputDecoration(labelText: 'Môn thể thao'),
              items: [
                for (final s in kSportTypes)
                  DropdownMenuItem(value: s, child: Text(s)),
              ],
              onChanged: (v) => setState(() => _sport = v ?? _sport),
            ),
            const SizedBox(height: 16),
            Row(
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
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Huỷ'),
        ),
        FilledButton(
          onPressed: (_saving || _name.text.trim().isEmpty) ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Lưu'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bulk AI sheet
// ---------------------------------------------------------------------------

void _openBulkAiSheet(BuildContext context, String courtId) {
  final repo = context.read<VenueRepository>();
  final bloc = context.read<VenueBloc>();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) => _BulkVenueSheet(courtId: courtId, repo: repo, bloc: bloc),
  );
}

class _BulkVenueSheet extends StatefulWidget {
  const _BulkVenueSheet({
    required this.courtId,
    required this.repo,
    required this.bloc,
  });
  final String courtId;
  final VenueRepository repo;
  final VenueBloc bloc;

  @override
  State<_BulkVenueSheet> createState() => _BulkVenueSheetState();
}

class _BulkVenueSheetState extends State<_BulkVenueSheet> {
  final _service = CourtInfoParserService();
  final _ctrl = TextEditingController();
  bool _loading = false;
  bool _saving = false;
  String? _error;
  List<VenueParseResult>? _rows;
  late List<bool> _checked;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _service.extractVenues(text);
      if (!mounted) return;
      if (rows.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'AI không tìm thấy sân con nào.';
        });
        return;
      }
      setState(() {
        _rows = rows;
        _checked = List<bool>.filled(rows.length, true);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e is StateError ? e.message : 'Có lỗi xảy ra. Thử lại nhé.';
      });
    }
  }

  Future<void> _create() async {
    final rows = _rows!;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => _saving = true);
    var created = 0;
    try {
      for (int i = 0; i < rows.length; i++) {
        if (!_checked[i]) continue;
        await widget.repo.create(
          courtId: widget.courtId,
          name: rows[i].name,
          sportType: rows[i].sportType,
          capacity: 1,
          pricePerHour: rows[i].pricePerHour,
        );
        created++;
      }
      widget.bloc.add(const VenueEvent.reloadRequested());
      nav.pop();
      messenger.showSnackBar(
          SnackBar(content: Text('Đã tạo $created sân con bằng AI')));
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        messenger.showSnackBar(
            const SnackBar(content: Text('Không thể tạo. Thử lại nhé.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const AiSparkTile(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tạo nhanh sân con bằng AI',
                        style: theme.textTheme.titleMedium),
                    Text('Mô tả tất cả sân con trong một câu',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_rows == null) ...[
            TextField(
              controller: _ctrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Ví dụ: 4 sân pickleball 120k/giờ và 2 sân cầu lông 80k/giờ',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: scheme.error)),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Symbols.auto_awesome, size: 18),
              label: Text(_loading ? 'AI đang phân tích…' : 'Phân tích bằng AI'),
              onPressed: _loading ? null : _analyze,
            ),
          ] else ...[
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (int i = 0; i < _rows!.length; i++)
                      CheckboxListTile(
                        value: _checked[i],
                        onChanged: (v) =>
                            setState(() => _checked[i] = v ?? true),
                        title: Text(_rows![i].name),
                        subtitle: Text(
                            '${_rows![i].sportType} · ${formatPricePerHour(_rows![i].pricePerHour)}'),
                        secondary: Icon(sportIcon(_rows![i].sportType)),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Symbols.playlist_add, size: 18),
              label: Text(
                  'Tạo ${_checked.where((c) => c).length} sân con'),
              onPressed: _saving ? null : _create,
            ),
          ],
        ],
      ),
    );
  }
}
