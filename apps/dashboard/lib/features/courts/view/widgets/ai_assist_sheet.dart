import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../service/court_info_parser_service.dart';
import '../../util/court_format.dart';
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
                _Phase.review => _ReviewView(
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
                _Phase.input => _InputView(
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

class _InputView extends StatelessWidget {
  const _InputView({
    required this.tabs,
    required this.textCtrl,
    required this.linkCtrl,
    required this.error,
    required this.service,
    required this.onAnalyzeText,
    required this.onReadLink,
    required this.onReadImage,
    required this.onSnapshot,
  });

  final TabController tabs;
  final TextEditingController textCtrl;
  final TextEditingController linkCtrl;
  final String? error;
  final CourtInfoParserService service;
  final VoidCallback onAnalyzeText;
  final VoidCallback onReadLink;
  final VoidCallback onReadImage;
  final ValueChanged<CourtParseResult> onSnapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar(
          controller: tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(icon: Icon(Symbols.notes, size: 20), text: 'Văn bản'),
            Tab(icon: Icon(Symbols.link, size: 20), text: 'Liên kết'),
            Tab(icon: Icon(Symbols.photo_camera, size: 20), text: 'Ảnh'),
            Tab(icon: Icon(Symbols.forum, size: 20), text: 'Hỏi đáp'),
          ],
        ),
        if (error != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        Flexible(
          child: TabBarView(
            controller: tabs,
            children: [
              _TextTab(controller: textCtrl, onAnalyze: onAnalyzeText),
              _LinkTab(controller: linkCtrl, onRead: onReadLink),
              _ImageTab(onPick: onReadImage),
              _ChatTab(service: service, onShowSnapshot: onSnapshot),
            ],
          ),
        ),
      ],
    );
  }
}

class _TextTab extends StatelessWidget {
  const _TextTab({required this.controller, required this.onAnalyze});
  final TextEditingController controller;
  final VoidCallback onAnalyze;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            maxLines: 6,
            minLines: 4,
            decoration: const InputDecoration(
              hintText:
                  'Ví dụ: Sân Pickleball ABC, 123 Nguyễn Trãi Q1, mở 6h-22h, có WiFi và bãi đậu xe. 4 sân giá 120k/giờ.',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mẹo: dán nguyên bài đăng Facebook, tin Zalo hoặc ghi chú…',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Symbols.auto_awesome, size: 18),
            label: const Text('Phân tích bằng AI'),
            onPressed: onAnalyze,
          ),
        ],
      ),
    );
  }
}

class _LinkTab extends StatelessWidget {
  const _LinkTab({required this.controller, required this.onRead});
  final TextEditingController controller;
  final VoidCallback onRead;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              hintText: 'https://maps.google.com/?q=...',
              prefixIcon: Icon(Symbols.link, size: 20),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toạ độ và tên địa điểm được đọc trực tiếp từ liên kết.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Symbols.travel_explore, size: 18),
            label: const Text('Đọc liên kết'),
            onPressed: onRead,
          ),
        ],
      ),
    );
  }
}

class _ImageTab extends StatelessWidget {
  const _ImageTab({required this.onPick});
  final VoidCallback onPick;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          InkWell(
            onTap: onPick,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                children: [
                  Icon(Symbols.document_scanner,
                      size: 36, color: scheme.onSurfaceVariant),
                  const SizedBox(height: 10),
                  Text('Chọn ảnh tờ rơi / bảng giá',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    'AI sẽ đọc và trích xuất thông tin từ ảnh',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Symbols.document_scanner, size: 18),
            label: const Text('Đọc ảnh'),
            onPressed: onPick,
          ),
        ],
      ),
    );
  }
}

class _ChatTab extends StatefulWidget {
  const _ChatTab({required this.service, required this.onShowSnapshot});
  final CourtInfoParserService service;
  final ValueChanged<CourtParseResult> onShowSnapshot;
  @override
  State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> {
  final _msgs = <ChatMessage>[
    const ChatMessage(
      fromUser: false,
      text:
          'Xin chào! Tôi sẽ giúp bạn khai báo sân mới. Trước tiên, sân của bạn tên gì và ở địa chỉ nào?',
    ),
  ];
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _busy = false;
  CourtParseResult? _snapshot;

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _busy) return;
    setState(() {
      _msgs.add(ChatMessage(fromUser: true, text: text));
      _ctrl.clear();
      _busy = true;
    });
    _jumpToEnd();
    try {
      final turn = await widget.service.chat(_msgs);
      if (!mounted) return;
      setState(() {
        _msgs.add(ChatMessage(fromUser: false, text: turn.reply));
        if (turn.snapshot != null && !turn.snapshot!.isEmpty) {
          _snapshot = turn.snapshot;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _msgs.add(const ChatMessage(
            fromUser: false,
            text: 'Xin lỗi, tôi gặp lỗi khi xử lý. Bạn thử lại nhé.',
          )));
    } finally {
      if (mounted) setState(() => _busy = false);
      _jumpToEnd();
    }
  }

  void _jumpToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            itemCount: _msgs.length + (_busy ? 1 : 0),
            itemBuilder: (context, i) {
              if (i == _msgs.length) {
                return const _Bubble(fromUser: false, text: 'Đang suy nghĩ…');
              }
              final m = _msgs[i];
              return _Bubble(fromUser: m.fromUser, text: m.text);
            },
          ),
        ),
        if (_snapshot != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                icon: const Icon(Symbols.fact_check, size: 18),
                label: const Text('Xem dữ liệu đã thu thập'),
                onPressed: () => widget.onShowSnapshot(_snapshot!),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: 'Nhập câu trả lời…',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _busy ? null : _send,
                icon: const Icon(Symbols.send, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.fromUser, required this.text});
  final bool fromUser;
  final String text;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: fromUser
              ? scheme.primaryContainer
              : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(fromUser ? 16 : 4),
            bottomRight: Radius.circular(fromUser ? 4 : 16),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: fromUser
                    ? scheme.onPrimaryContainer
                    : scheme.onSurface,
              ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Review step
// ---------------------------------------------------------------------------

class _ReviewRow {
  const _ReviewRow(this.key, this.label, this.value);
  final String key;
  final String label;
  final String value;
}

List<_ReviewRow> _reviewRows(CourtParseResult r) {
  final rows = <_ReviewRow>[];
  void add(String k, String label, String? v) {
    if (v != null && v.trim().isNotEmpty) rows.add(_ReviewRow(k, label, v));
  }

  add('name', 'Tên sân', r.name);
  add('address', 'Địa chỉ', r.address);
  if (r.lat != null && r.lng != null) {
    add('location', 'Toạ độ',
        '${r.lat!.toStringAsFixed(5)}, ${r.lng!.toStringAsFixed(5)}');
  } else if (r.googleMapsUrl != null) {
    add('location', 'Google Maps', r.googleMapsUrl);
  }
  add('phone', 'Điện thoại', r.phone);
  add('description', 'Mô tả', r.description);
  if (r.amenities.isNotEmpty) {
    add('amenities', 'Tiện ích', r.amenities.join(' · '));
  }
  if (r.openHour != null && r.closeHour != null) {
    add('hours', 'Giờ hoạt động',
        '${formatHour(r.openHour!)}–${formatHour(r.closeHour!)}');
  }
  if (r.venues.isNotEmpty) {
    add(
      'venues',
      'Sân con',
      '${r.venues.length} sân: ${r.venues.map((v) => '${v.name} (${v.sportType} · ${formatPricePerHour(v.pricePerHour)})').join(', ')}',
    );
  }
  return rows;
}

class _ReviewView extends StatelessWidget {
  const _ReviewView({
    required this.result,
    required this.checked,
    required this.onToggle,
    required this.onBack,
    required this.onApply,
  });

  final CourtParseResult result;
  final Map<String, bool> checked;
  final ValueChanged<String> onToggle;
  final VoidCallback onBack;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final rows = _reviewRows(result);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Symbols.fact_check, size: 20, color: scheme.tertiary),
                    const SizedBox(width: 8),
                    Text('Kiểm tra trước khi điền',
                        style: theme.textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Bỏ chọn những dòng không đúng — chỉ các dòng được chọn sẽ điền vào form.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'AI không tìm thấy thông tin nào trong nội dung này.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < rows.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          _ReviewTile(
                            row: rows[i],
                            checked: checked[rows[i].key] ?? true,
                            onToggle: () => onToggle(rows[i].key),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        _ReviewFooter(onBack: onBack, onApply: onApply),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.row,
    required this.checked,
    required this.onToggle,
  });
  final _ReviewRow row;
  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onToggle,
      child: Opacity(
        opacity: checked ? 1 : 0.4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                checked ? Symbols.check_circle : Symbols.radio_button_unchecked,
                size: 22,
                color: checked ? scheme.primary : scheme.outline,
                fill: checked ? 1 : 0,
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 96,
                child: Text(
                  row.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  row.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    decoration: checked ? null : TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewFooter extends StatelessWidget {
  const _ReviewFooter({required this.onBack, required this.onApply});
  final VoidCallback onBack;
  final VoidCallback onApply;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Row(
        children: [
          TextButton(onPressed: onBack, child: const Text('Sửa lại')),
          const Spacer(),
          FilledButton.icon(
            icon: const Icon(Symbols.auto_awesome, size: 18),
            label: const Text('Điền vào form'),
            onPressed: onApply,
          ),
        ],
      ),
    );
  }
}
