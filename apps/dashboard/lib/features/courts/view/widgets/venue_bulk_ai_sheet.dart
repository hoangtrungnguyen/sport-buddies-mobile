import 'package:dashboard/core/widgets/button_spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../bloc/venue_bloc.dart';
import '../../repository/venue_repository.dart';
import '../../service/court_info_parser_service.dart';
import '../../util/court_format.dart';
import 'court_widgets.dart';

/// Opens the AI bulk-create bottom sheet. Resolves repo + bloc up front so the
/// sheet route stays independent of the originating context.
void openBulkAiSheet(BuildContext context, String courtId) {
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
          indoor: rows[i].indoor,
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
          _header(theme, scheme),
          const SizedBox(height: 16),
          if (_rows == null) ..._inputPhase(scheme) else ..._reviewPhase(),
        ],
      ),
    );
  }

  /// AI spark tile + title/subtitle.
  Widget _header(ThemeData theme, ColorScheme scheme) {
    return Row(
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
    );
  }

  /// Free-text prompt + (optional) error + "Phân tích bằng AI" — shown before
  /// the AI returns any rows.
  List<Widget> _inputPhase(ColorScheme scheme) {
    return [
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
            ? const ButtonSpinner()
            : const Icon(Symbols.auto_awesome, size: 18),
        label: Text(_loading ? 'AI đang phân tích…' : 'Phân tích bằng AI'),
        onPressed: _loading ? null : _analyze,
      ),
    ];
  }

  /// Checklist of the parsed venues + "Tạo N sân con" — shown after analysis.
  List<Widget> _reviewPhase() {
    return [
      Flexible(
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (int i = 0; i < _rows!.length; i++)
                CheckboxListTile(
                  value: _checked[i],
                  onChanged: (v) => setState(() => _checked[i] = v ?? true),
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
            ? const ButtonSpinner()
            : const Icon(Symbols.playlist_add, size: 18),
        label: Text('Tạo ${_checked.where((c) => c).length} sân con'),
        onPressed: _saving ? null : _create,
      ),
    ];
  }
}
