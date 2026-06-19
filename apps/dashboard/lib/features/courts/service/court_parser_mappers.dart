import 'dart:convert';

import 'package:dashboard/core/debug/app_logger.dart';
import 'package:dashboard/features/setup/model/owner_court.dart';

import '../model/court_parse_result.dart';

/// Pure AI-response → model parsing for [CourtInfoParserService]. No I/O — each
/// function takes the raw Gemini text / decoded JSON and returns a model, so
/// the lenient JSON-slicing + field-coercion rules are unit-testable in
/// isolation from the Gemini transport (see `court_parser_test.dart`).

/// Decodes the first `{ … }` block out of [raw], tolerating stray prose the
/// model may wrap around the JSON. Throws [StateError] when the slice is not
/// valid JSON.
Map<String, dynamic> decodeCourtJson(String raw) {
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

/// Parses a full court description from raw model text (decodes, then coerces
/// each field; unknown amenities are dropped).
CourtParseResult parseCourtJson(String raw) {
  final json = decodeCourtJson(raw);
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
    venues: parseVenues(json['venues']),
  );
}

/// Parses the `venues` array; entries without a name are skipped and an
/// unknown/absent sport falls back to the first known sport type.
List<VenueParseResult> parseVenues(dynamic raw) {
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

/// Strips fenced ```json``` / ``` code blocks so the chat stream shows only the
/// model's prose, never the raw JSON snapshot it emits alongside.
String stripJsonBlock(String text) => text
    .replaceAll(RegExp(r'```json[\s\S]*?```'), '')
    .replaceAll(RegExp(r'```[\s\S]*?```'), '')
    .trim();

// --- field coercion ---------------------------------------------------------

String? _str(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty || s.toLowerCase() == 'null' ? null : s;
}

num? _num(dynamic v) => v is num ? v : null;

int? _int(dynamic v) => v is int ? v : (v is num ? v.toInt() : null);
