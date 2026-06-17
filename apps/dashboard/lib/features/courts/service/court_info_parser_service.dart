import 'dart:convert';
import 'dart:typed_data';

import 'package:dashboard/core/debug/app_logger.dart';
import 'package:dashboard/core/env/env.dart';
import 'package:dashboard/features/setup/model/owner_court.dart';
import 'package:dio/dio.dart';

import '../model/court_parse_result.dart';

export '../model/court_parse_result.dart';

class CourtInfoParserService {
  /// [apiKey] overrides the compile-time [Env.geminiApiKey] — useful for driving
  /// the parser from an e2e/demo entrypoint that can't set dart-defines.
  /// [dio] lets tests inject a stubbed HTTP client instead of hitting the API.
  CourtInfoParserService({String? apiKey, Dio? dio})
      : _dio = dio ?? Dio(),
        _apiKey = apiKey ?? Env.geminiApiKey;

  final Dio _dio;
  final String _apiKey;

  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  static final _amenityList = kAmenities.join('", "');
  static final _sportList = kSportTypes.join('", "');

  static String get _courtPrompt => '''
Extract sports court/venue information from the provided content.
Return ONLY a valid JSON object — no markdown, no explanation, nothing else.

JSON fields:
- "name": string or null — court/venue name
- "address": string or null — full address (keep original language)
- "lat": number or null — latitude (-90 to 90)
- "lng": number or null — longitude (-180 to 180)
- "googleMapsUrl": string or null — URL starting with "http"
- "phone": string or null — contact phone number
- "description": string or null — description, notes, or other info
- "amenities": array — zero or more items from: ["$_amenityList"]
- "openHour": integer or null — opening hour in 24h time (0–23)
- "closeHour": integer or null — closing hour in 24h time (1–24, 24 = midnight), must be > openHour
- "venues": array — zero or more {"name": string, "sportType": one of ["$_sportList"], "pricePerHour": integer VND, "indoor": boolean}

Rules: missing field → null. "120k" → 120000. "6h" → 6. If the text states a
count (e.g. "4 sân pickleball giá 120k"), emit one numbered venue per court
(Sân 1, Sân 2, …). Only include amenities from the allowed list; [] if none.
''';

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Text tab.
  Future<CourtParseResult> parse(String text) async {
    final raw = await _generate([
      {'text': '$_courtPrompt\n\nContent:\n$text'},
    ]);
    return _parseCourtJson(raw);
  }

  /// Link tab. Client-side regex parse (lat/lng/name/url) wins over an LLM pass
  /// on the URL text.
  Future<CourtParseResult> parseFromLink(String url) async {
    final client = parseMapsUrl(url);
    CourtParseResult llm = const CourtParseResult();
    try {
      llm = await parse(
        'URL sân thể thao: $url\nTên nơi chốn (nếu có trong URL): ${client.name ?? ''}',
      );
    } catch (e, st) {
      appLogger.w('parseFromLink LLM pass failed, using client parse only',
          error: e, stackTrace: st);
    }
    return client.mergeOver(llm);
  }

  /// Photo tab — vision extraction from an uploaded image.
  Future<CourtParseResult> parseFromImage(Uint8List bytes, String mimeType) async {
    final raw = await _generate([
      {'text': _courtPrompt},
      {
        'inlineData': {
          'mimeType': mimeType,
          'data': base64Encode(bytes),
        },
      },
    ]);
    return _parseCourtJson(raw);
  }

  /// Reduced schema — venue-only bulk extraction.
  Future<List<VenueParseResult>> extractVenues(String text) async {
    final prompt = '''
Extract a list of sub-venues (sân con) from the Vietnamese text below.
Return ONLY JSON: {"venues":[{"name":string,"sportType":one of ["$_sportList"],"pricePerHour":integer VND,"indoor":boolean}]}
Rules: "120k" → 120000. If a count is given (e.g. "4 sân pickleball"), emit one
numbered venue each (Sân 1, Sân 2, …). Unknown indoor → false.

Content:
$text''';
    final raw = await _generate([
      {'text': prompt},
    ]);
    final json = _decode(raw);
    return _parseVenues(json['venues']);
  }

  /// Inline "Viết mô tả bằng AI" — composes from current form values.
  Future<String> writeDescription({
    required String name,
    required String address,
    required int openHour,
    required int closeHour,
    required List<String> amenities,
    required List<String> venueNames,
  }) async {
    final prompt = '''
Viết mô tả ngắn (2–3 câu, tiếng Việt, thân thiện, không dùng emoji, không phóng đại) cho sân thể thao sau để hiển thị cho khách đặt sân:
Tên: ${name.isEmpty ? 'chưa rõ' : name}. Địa chỉ: ${address.isEmpty ? 'chưa rõ' : address}. Giờ: ${openHour.toString().padLeft(2, '0')}:00–${closeHour.toString().padLeft(2, '0')}:00. Tiện ích: ${amenities.isEmpty ? 'chưa rõ' : amenities.join(', ')}. Sân con: ${venueNames.isEmpty ? 'chưa rõ' : venueNames.join(', ')}.
Chỉ trả về đoạn mô tả, không có gì khác.''';
    final raw = await _generate([
      {'text': prompt},
    ], jsonMime: false);
    return raw.trim().replaceAll(RegExp(r'^["’“]+|["’”]+$'), '');
  }

  /// Chat tab. Sends the full history + preamble, returns the assistant reply
  /// (JSON block stripped) plus the accumulated snapshot.
  Future<ChatTurn> chat(List<ChatMessage> history) async {
    final preamble = '''
Bạn là trợ lý nhập liệu của SportBuddies, giúp chủ sân Việt Nam khai báo sân thể thao. Trò chuyện tiếng Việt, ngắn gọn, thân thiện.
Thông tin cần thu thập: tên sân, địa chỉ, giờ mở/đóng cửa (số nguyên 6–22), số điện thoại, tiện ích (chỉ dùng: ${kAmenities.join(', ')}), các sân con (tên, môn trong ["$_sportList"], giá VND/giờ).
MỖI lượt trả lời PHẢI có 2 phần:
1. Một câu phản hồi ngắn + MỘT câu hỏi tiếp theo về thông tin còn thiếu. Khi đã đủ tên + địa chỉ + giờ, nói: "Đã đủ thông tin chính — bạn có thể bấm Hoàn tất."
2. Một khối ```json chứa TOÀN BỘ dữ liệu đã biết theo schema court ở trên (name, address, phone, openHour, closeHour, amenities[], venues[]).''';

    final contents = <Map<String, dynamic>>[
      {
        'role': 'user',
        'parts': [
          {'text': preamble},
        ],
      },
      for (final m in history)
        {
          'role': m.fromUser ? 'user' : 'model',
          'parts': [
            {'text': m.text},
          ],
        },
    ];
    final raw = await _generateContents(contents, jsonMime: false);
    final visible = _stripJsonBlock(raw);
    CourtParseResult? snapshot;
    try {
      snapshot = _parseCourtJson(raw);
    } catch (_) {/* snapshot optional */}
    return ChatTurn(
      reply: visible.isEmpty ? 'Đã ghi nhận!' : visible,
      snapshot: snapshot,
    );
  }

  // -------------------------------------------------------------------------
  // URL parsing (client-side; wins over LLM on lat/lng/name)
  // -------------------------------------------------------------------------

  static CourtParseResult parseMapsUrl(String url) {
    double? lat, lng;
    final m = RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)').firstMatch(url) ??
        RegExp(r'[?&]q=(-?\d+\.\d+),(-?\d+\.\d+)').firstMatch(url) ??
        RegExp(r'!3d(-?\d+\.\d+)!4d(-?\d+\.\d+)').firstMatch(url);
    if (m != null) {
      lat = double.tryParse(m.group(1)!);
      lng = double.tryParse(m.group(2)!);
    }
    String? name;
    final p = RegExp(r'/place/([^/@?]+)').firstMatch(url);
    if (p != null) {
      name = Uri.decodeComponent(p.group(1)!).replaceAll('+', ' ');
    }
    return CourtParseResult(
      googleMapsUrl: url.startsWith('http') ? url : null,
      lat: lat,
      lng: lng,
      name: name,
    );
  }

  // -------------------------------------------------------------------------
  // Gemini transport
  // -------------------------------------------------------------------------

  Future<String> _generate(List<Map<String, dynamic>> parts,
      {bool jsonMime = true}) {
    return _generateContents([
      {'role': 'user', 'parts': parts},
    ], jsonMime: jsonMime);
  }

  Future<String> _generateContents(List<Map<String, dynamic>> contents,
      {bool jsonMime = true}) async {
    final apiKey = _apiKey;
    if (apiKey.isEmpty) {
      throw StateError(
          'GEMINI_API_KEY is not configured. Add it to your .local.env and re-run build_runner.');
    }
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _endpoint,
        queryParameters: {'key': apiKey},
        data: {
          'contents': contents,
          'generationConfig': {
            if (jsonMime) 'responseMimeType': 'application/json',
            'temperature': 0,
          },
        },
        options: Options(
          sendTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 45),
        ),
      );
      final body = response.data;
      if (body == null) throw StateError('API returned empty response');
      final candidates = body['candidates'];
      if (candidates is! List || candidates.isEmpty) {
        throw StateError('No candidates in API response');
      }
      final content = (candidates.first as Map)['content'];
      if (content is! Map) throw StateError('Candidate content is invalid');
      final partsOut = content['parts'];
      if (partsOut is! List || partsOut.isEmpty) {
        throw StateError('Response parts are missing or empty');
      }
      final raw = (partsOut.first as Map)['text'];
      if (raw is! String) throw StateError('Response text is missing');
      return raw;
    } on DioException catch (e, st) {
      appLogger.e('Gemini API error: ${e.message}', error: e, stackTrace: st);
      final msg = switch (e.type) {
        DioExceptionType.connectionTimeout => 'Connection timed out. Check your network.',
        DioExceptionType.receiveTimeout => 'Server took too long to respond.',
        DioExceptionType.badResponse => 'API error: ${e.response?.statusCode}',
        _ => 'Network error: ${e.message}',
      };
      throw StateError(msg);
    } on StateError {
      rethrow;
    } catch (e, st) {
      appLogger.e('Unexpected parser error', error: e, stackTrace: st);
      throw StateError('Unexpected error parsing court info. Please try again.');
    }
  }

  // -------------------------------------------------------------------------
  // JSON → models
  // -------------------------------------------------------------------------

  Map<String, dynamic> _decode(String raw) {
    // Take the first { … last } to survive stray prose around the JSON.
    final a = raw.indexOf('{');
    final b = raw.lastIndexOf('}');
    final slice = (a != -1 && b > a) ? raw.substring(a, b + 1) : raw;
    try {
      return jsonDecode(slice) as Map<String, dynamic>;
    } on FormatException catch (e, st) {
      appLogger.e('JSON decode error: ${e.message}', error: e, stackTrace: st);
      throw StateError('AI không trả về JSON hợp lệ.');
    }
  }

  CourtParseResult _parseCourtJson(String raw) {
    final json = _decode(raw);
    return CourtParseResult(
      name: _str(json['name']),
      address: _str(json['address']),
      lat: _num(json['lat'])?.toDouble(),
      lng: _num(json['lng'])?.toDouble(),
      googleMapsUrl: _str(json['googleMapsUrl']),
      phone: _str(json['phone']),
      description: _str(json['description']),
      amenities: (json['amenities'] as List<dynamic>? ?? [])
          .whereType<String>()
          .where(kAmenities.contains)
          .toList(),
      openHour: _int(json['openHour']),
      closeHour: _int(json['closeHour']),
      venues: _parseVenues(json['venues']),
    );
  }

  List<VenueParseResult> _parseVenues(dynamic raw) {
    if (raw is! List) return const [];
    final out = <VenueParseResult>[];
    for (final v in raw) {
      if (v is! Map) continue;
      final name = _str(v['name']);
      if (name == null) continue;
      final sport = _str(v['sportType']);
      out.add(VenueParseResult(
        name: name,
        sportType: (sport != null && kSportTypes.contains(sport))
            ? sport
            : kSportTypes.first,
        pricePerHour: _int(v['pricePerHour']) ?? 0,
        indoor: v['indoor'] == true,
      ));
    }
    return out;
  }

  static String _stripJsonBlock(String text) => text
      .replaceAll(RegExp(r'```json[\s\S]*?```'), '')
      .replaceAll(RegExp(r'```[\s\S]*?```'), '')
      .trim();

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty || s.toLowerCase() == 'null' ? null : s;
  }

  static num? _num(dynamic v) => v is num ? v : null;

  static int? _int(dynamic v) => v is int ? v : (v is num ? v.toInt() : null);
}
