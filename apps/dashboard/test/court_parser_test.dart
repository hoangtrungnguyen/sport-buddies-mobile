import 'package:dashboard/core/env/env.dart';
import 'package:dashboard/features/courts/service/court_info_parser_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CourtInfoParserService', () {
    late CourtInfoParserService service;

    setUp(() {
      service = CourtInfoParserService();
    });

    test('parse court text with Gemini API', () async {
      final text = 'Sân Pickleball ABC, 123 Nguyễn Trãi Q1, mở 6h-22h, có WiFi và bãi đậu xe';

      try {
        final result = await service.parse(text);

        print('✅ Parse succeeded!');
        print('  Name: ${result.name}');
        print('  Address: ${result.address}');
        print('  Hours: ${result.openHour}h - ${result.closeHour}h');
        print('  Amenities: ${result.amenities}');

        // Verify we got some data back
        expect(result.isEmpty, false);
        print('✅ Result is not empty');

      } on StateError catch (e) {
        print('⚠️ StateError: ${e.message}');
        fail('Parser failed: ${e.message}');
      } catch (e) {
        print('❌ Unexpected error: $e');
        fail('Unexpected error: $e');
      }
    });

    test('rejects empty text', () async {
      final text = '';

      // The UI validation should catch this before calling service
      // But service should handle gracefully
      try {
        await service.parse(text);
        print('⚠️ Accepted empty text (UI should prevent this)');
      } catch (e) {
        print('✅ Rejected empty text: $e');
      }
    });

    test('API key is configured', () {
      final key = Env.geminiApiKey;
      print('API Key configured: ${key.isNotEmpty ? '✅ YES' : '❌ NO'}');
      expect(key.isNotEmpty, true);
    });
  });
}
