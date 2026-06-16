import 'dart:typed_data';

import 'package:dashboard/features/courts/service/court_info_parser_service.dart';
import 'package:dashboard/features/courts/view/widgets/ai_assist_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Canned parser — overrides only the network calls the sheet makes, so the
/// real Dio is never hit. Construction creates a Dio instance but issues no
/// request, so it is inert in tests.
class _FakeParser extends CourtInfoParserService {
  _FakeParser({this.result = const CourtParseResult(), this.chatTurn});

  final CourtParseResult result;
  final ChatTurn? chatTurn;

  @override
  Future<CourtParseResult> parse(String text) async => result;

  @override
  Future<CourtParseResult> parseFromLink(String url) async => result;

  @override
  Future<CourtParseResult> parseFromImage(Uint8List bytes, String mime) async =>
      result;

  @override
  Future<ChatTurn> chat(List<ChatMessage> history) async =>
      chatTurn ?? const ChatTurn(reply: 'Đã ghi nhận!');
}

Future<void> _open(
  WidgetTester tester, {
  required CourtInfoParserService service,
  required ValueChanged<CourtParseResult> onApply,
}) async {
  late BuildContext ctx;
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      }),
    ),
  ));
  showCourtAiSheet(context: ctx, service: service, onApply: onApply);
  await tester.pumpAndSettle();
}

/// Advances past the indeterminate-progress loading phase without
/// pumpAndSettle (which would spin forever on the progress indicators).
Future<void> _resolveLoading(WidgetTester tester) async {
  await tester.pump(); // run the tap handler → loading phase
  await tester.pump(); // flush the resolved future → review/input phase
}

void main() {
  testWidgets('text → review → toggle off address → apply drops it',
      (tester) async {
    CourtParseResult? applied;
    final service = _FakeParser(
      result: const CourtParseResult(
        name: 'Sân Pickleball ABC',
        address: '123 Nguyễn Trãi, Q1',
        phone: '0901234567',
        openHour: 6,
        closeHour: 22,
        amenities: ['WiFi', 'Bãi đậu xe'],
      ),
    );
    await _open(tester, service: service, onApply: (r) => applied = r);

    // Input phase, text tab active.
    expect(find.text('Phân tích bằng AI'), findsOneWidget);
    await tester.enterText(
        find.byType(TextField), 'Sân Pickleball ABC, 123 Nguyễn Trãi');
    await tester.tap(find.text('Phân tích bằng AI'));
    await _resolveLoading(tester);

    // Review phase shows the parsed rows.
    expect(find.text('Kiểm tra trước khi điền'), findsOneWidget);
    expect(find.text('Tên sân'), findsOneWidget);
    expect(find.text('Sân Pickleball ABC'), findsOneWidget);
    expect(find.text('Địa chỉ'), findsOneWidget);
    expect(find.text('123 Nguyễn Trãi, Q1'), findsOneWidget);
    expect(find.text('Giờ hoạt động'), findsOneWidget);

    // Owner unticks the address row, then fills the form.
    await tester.tap(find.text('Địa chỉ'));
    await tester.pump();
    await tester.tap(find.text('Điền vào form'));
    await tester.pumpAndSettle();

    // onApply receives everything except the unticked address.
    expect(applied, isNotNull);
    expect(applied!.name, 'Sân Pickleball ABC');
    expect(applied!.address, isNull);
    expect(applied!.phone, '0901234567');
    expect(applied!.openHour, 6);
    expect(applied!.closeHour, 22);
    expect(applied!.amenities, ['WiFi', 'Bãi đậu xe']);
    // Sheet closed after applying.
    expect(find.text('Điền vào form'), findsNothing);
  });

  testWidgets('empty AI result surfaces an error and stays on input',
      (tester) async {
    final service = _FakeParser(); // default = empty result
    await _open(tester, service: service, onApply: (_) {});

    await tester.enterText(find.byType(TextField), 'nội dung mơ hồ');
    await tester.tap(find.text('Phân tích bằng AI'));
    await _resolveLoading(tester);

    expect(find.textContaining('AI không tìm thấy thông tin'), findsOneWidget);
    // Did not advance to review.
    expect(find.text('Phân tích bằng AI'), findsOneWidget);
    expect(find.text('Kiểm tra trước khi điền'), findsNothing);
  });

  testWidgets('back from review returns to the input tabs', (tester) async {
    final service =
        _FakeParser(result: const CourtParseResult(name: 'Sân Q7'));
    await _open(tester, service: service, onApply: (_) {});

    await tester.enterText(find.byType(TextField), 'Sân Q7');
    await tester.tap(find.text('Phân tích bằng AI'));
    await _resolveLoading(tester);
    expect(find.text('Kiểm tra trước khi điền'), findsOneWidget);

    await tester.tap(find.text('Sửa lại'));
    await tester.pumpAndSettle();
    // Back on the input tabs.
    expect(find.text('Phân tích bằng AI'), findsOneWidget);
    expect(find.text('Kiểm tra trước khi điền'), findsNothing);
  });

  testWidgets('link tab reads a URL into review', (tester) async {
    final service = _FakeParser(
      result: const CourtParseResult(
        name: 'Sân Q7',
        googleMapsUrl: 'https://maps.google.com/?q=10,106',
      ),
    );
    await _open(tester, service: service, onApply: (_) {});

    await tester.tap(find.text('Liên kết'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byType(TextField), 'https://maps.google.com/?q=10,106');
    await tester.tap(find.text('Đọc liên kết'));
    await _resolveLoading(tester);

    expect(find.text('Kiểm tra trước khi điền'), findsOneWidget);
    expect(find.text('Tên sân'), findsOneWidget);
    expect(find.text('Sân Q7'), findsOneWidget);
  });

  testWidgets('chat tab: send → snapshot button → review', (tester) async {
    final service = _FakeParser(
      chatTurn: const ChatTurn(
        reply: 'Cảm ơn bạn!',
        snapshot: CourtParseResult(name: 'Sân Chat'),
      ),
    );
    await _open(tester, service: service, onApply: (_) {});

    await tester.tap(find.text('Hỏi đáp'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Sân tên ABC ở Q1');
    await tester.tap(find.byIcon(Symbols.send));
    await tester.pump(); // user bubble + busy
    await tester.pump(); // chat reply resolves
    await tester.pumpAndSettle();

    expect(find.text('Cảm ơn bạn!'), findsOneWidget);
    final snapshotBtn = find.text('Xem dữ liệu đã thu thập');
    expect(snapshotBtn, findsOneWidget);

    await tester.tap(snapshotBtn);
    await tester.pumpAndSettle();
    expect(find.text('Kiểm tra trước khi điền'), findsOneWidget);
    expect(find.text('Sân Chat'), findsOneWidget);
  });
}
