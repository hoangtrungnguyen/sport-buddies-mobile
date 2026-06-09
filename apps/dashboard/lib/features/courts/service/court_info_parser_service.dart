import 'dart:convert';

import 'package:dashboard/core/env/env.dart';
import 'package:dashboard/features/setup/model/owner_court.dart';
import 'package:dio/dio.dart';

class CourtParseResult {
  const CourtParseResult({
    this.name,
    this.address,
    this.lat,
    this.lng,
    this.googleMapsUrl,
    this.description,
    this.amenities = const [],
    this.openHour,
    this.closeHour,
  });

  final String? name;
  final String? address;
  final double? lat;
  final double? lng;
  final String? googleMapsUrl;
  final String? description;
  final List<String> amenities;
  final int? openHour;
  final int? closeHour;

  bool get isEmpty =>
      name == null &&
      address == null &&
      lat == null &&
      lng == null &&
      googleMapsUrl == null &&
      description == null &&
      amenities.isEmpty &&
      openHour == null &&
      closeHour == null;
}

class CourtInfoParserService {
  CourtInfoParserService() : _dio = Dio();

  final Dio _dio;

  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  static final _amenityList = kAmenities.join('", "');

  static String get _systemPrompt => '''
Extract sports court/venue information from the provided text.
Return ONLY a valid JSON object — no markdown, no explanation, nothing else.

JSON fields:
- "name": string or null — court/venue name
- "address": string or null — full address (keep original language)
- "lat": number or null — latitude (-90 to 90)
- "lng": number or null — longitude (-180 to 180)
- "googleMapsUrl": string or null — URL starting with "http"
- "description": string or null — description, notes, or other info
- "amenities": array — zero or more items from: ["$_amenityList"]
- "openHour": integer or null — opening hour (6–22)
- "closeHour": integer or null — closing hour (6–22), must be > openHour

Only include amenities that appear in the allowed list above. Return [] if none found.
''';

  Future<CourtParseResult> parse(String text) async {
    final apiKey = Env.geminiApiKey;
    if (apiKey.isEmpty) {
      throw StateError('GEMINI_API_KEY is not configured. Add it to your .local.env and re-run build_runner.');
    }

    final response = await _dio.post<Map<String, dynamic>>(
      _endpoint,
      queryParameters: {'key': apiKey},
      data: {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': '$_systemPrompt\n\nText:\n$text'},
            ],
          },
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'temperature': 0,
        },
      },
    );

    final body = response.data!;
    final candidates = body['candidates'] as List<dynamic>;
    final raw = candidates.first['content']['parts'].first['text'] as String;
    final json = jsonDecode(raw) as Map<String, dynamic>;

    return CourtParseResult(
      name: _str(json['name']),
      address: _str(json['address']),
      lat: _num(json['lat'])?.toDouble(),
      lng: _num(json['lng'])?.toDouble(),
      googleMapsUrl: _str(json['googleMapsUrl']),
      description: _str(json['description']),
      amenities: (json['amenities'] as List<dynamic>? ?? [])
          .whereType<String>()
          .where(kAmenities.contains)
          .toList(),
      openHour: _int(json['openHour']),
      closeHour: _int(json['closeHour']),
    );
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static num? _num(dynamic v) => v is num ? v : null;

  static int? _int(dynamic v) => v is int ? v : (v is num ? v.toInt() : null);
}
