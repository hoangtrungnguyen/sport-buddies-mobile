import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../service/court_info_parser_service.dart';
import 'ai_assist_review.dart';
import 'ai_assist_tabs.dart';
import 'court_widgets.dart';

/// Opens the AI assist bottom sheet (variant A). [onApply] receives a
/// [CourtParseResult] already filtered to the rows the owner kept checked.
Future<void> showCourtAiSheet({
  required BuildContext context,
  required CourtInfoParserService service,
  required void Function(CourtParseResult checked) onApply,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 720),
    builder: (_) => _AiAssistSheet(service: service, onApply: onApply),
  );
}

enum _Phase { input, loading, review }

class _AiAssistSheet extends StatefulWidget {
  const _AiAssistSheet({required this.service, required this.onApply});
  final CourtInfoParserService service;
  final void Function(CourtParseResult checked) onApply;

  @override
  State<_AiAssistSheet> createState() => _AiAssistSheetState();
}

class _AiAssistSheetState extends State<_AiAssistSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this);
  final _textCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();

  _Phase _phase = _Phase.input;
  String? _error;
  String? _loadingLabel;
  CourtParseResult? _result;
  final Map<String, bool> _checked = {};

  @override
  void dispose() {
    _tabs.dispose();
    _textCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  Future<void> _run(String label, Future<CourtParseResult> Function() task) async {
    setState(() {
      _phase = _Phase.loading;
      _loadingLabel = label;
      _error = null;
    });
    try {
      final r = await task();
      if (!mounted) return;
      if (r.isEmpty) {
        setState(() {
          _phase = _Phase.input;
          _error = 'AI không tìm thấy thông tin nào. Thử nội dung khác nhé.';
        });
        return;
      }
      _checked.clear();
      setState(() {
        _result = r;
        _phase = _Phase.review;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.input;
        _error = e is StateError ? e.message : 'Có lỗi xảy ra. Thử lại nhé.';
      });
    }
  }

  Future<void> _pickImage() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final file = res?.files.firstOrNull;
    final bytes = file?.bytes;
    if (bytes == null) return;
    final ext = (file!.extension ?? 'jpg').toLowerCase();
    final mime = switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      _ => 'image/jpeg',
    };
    await _run('AI đang đọc ảnh…',
        () => widget.service.parseFromImage(bytes, mime));
  }

  void _showSnapshot(CourtParseResult r) {
    _checked.clear();
    setState(() {
      _result = r;
      _phase = _Phase.review;
    });
  }

  CourtParseResult _buildChecked() {
    final r = _result!;
    bool on(String k) => _checked[k] ?? true;
    return CourtParseResult(
      name: on('name') ? r.name : null,
      address: on('address') ? r.address : null,
      lat: on('location') ? r.lat : null,
      lng: on('location') ? r.lng : null,
      googleMapsUrl: on('location') ? r.googleMapsUrl : null,
      phone: on('phone') ? r.phone : null,
      description: on('description') ? r.description : null,
      amenities: on('amenities') ? r.amenities : const [],
      openHour: on('hours') ? r.openHour : null,
      closeHour: on('hours') ? r.closeHour : null,
      venues: on('venues') ? r.venues : const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxH = MediaQuery.sizeOf(context).height * 0.86;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetHeader(),
            Flexible(
              child: switch (_phase) {
                _Phase.loading => _LoadingView(label: _loadingLabel ?? ''),
                _Phase.review => ReviewView(
                    result: _result!,
                    checked: _checked,
                    onToggle: (k) => setState(
                        () => _checked[k] = !(_checked[k] ?? true)),
                    onBack: () => setState(() => _phase = _Phase.input),
                    onApply: () {
                      widget.onApply(_buildChecked());
                      Navigator.of(context).pop();
                    },
                  ),
                _Phase.input => InputView(
                    tabs: _tabs,
                    textCtrl: _textCtrl,
                    linkCtrl: _linkCtrl,
                    error: _error,
                    service: widget.service,
                    onAnalyzeText: () => _run('AI đang phân tích…',
                        () => widget.service.parse(_textCtrl.text.trim())),
                    onReadLink: () => _run('AI đang đọc liên kết…',
                        () => widget.service.parseFromLink(_linkCtrl.text.trim())),
                    onReadImage: _pickImage,
                    onSnapshot: _showSnapshot,
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _SheetHeader extends StatelessWidget {
  const _SheetHeader();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          const AiSparkTile(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nhập nhanh bằng AI', style: theme.textTheme.titleMedium),
                Text(
                  'Dán văn bản, liên kết hoặc ảnh — AI điền form, bạn duyệt lại',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(label, style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(
            'Đang trích xuất thông tin, vui lòng đợi…',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          const SizedBox(
            width: 220,
            child: LinearProgressIndicator(),
          ),
        ],
      ),
    );
  }
}
