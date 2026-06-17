import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../service/court_info_parser_service.dart';

class InputView extends StatelessWidget {
  const InputView({
    super.key,
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
