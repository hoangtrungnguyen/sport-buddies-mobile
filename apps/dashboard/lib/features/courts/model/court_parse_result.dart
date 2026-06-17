// DTOs for the AI court-info parser (`CourtInfoParserService`): the extracted
// court/venue fields and the assistant chat turn. Pure data — no I/O.

/// Structured court fields extracted from free text / a link / a photo.
class CourtParseResult {
  const CourtParseResult({
    this.name,
    this.address,
    this.lat,
    this.lng,
    this.googleMapsUrl,
    this.phone,
    this.description,
    this.amenities = const [],
    this.openHour,
    this.closeHour,
    this.venues = const [],
  });

  final String? name;
  final String? address;
  final double? lat;
  final double? lng;
  final String? googleMapsUrl;
  final String? phone;
  final String? description;
  final List<String> amenities;
  final int? openHour;
  final int? closeHour;
  final List<VenueParseResult> venues;

  bool get isEmpty =>
      name == null &&
      address == null &&
      lat == null &&
      lng == null &&
      googleMapsUrl == null &&
      phone == null &&
      description == null &&
      amenities.isEmpty &&
      openHour == null &&
      closeHour == null &&
      venues.isEmpty;

  CourtParseResult mergeOver(CourtParseResult base) => CourtParseResult(
        name: name ?? base.name,
        address: address ?? base.address,
        lat: lat ?? base.lat,
        lng: lng ?? base.lng,
        googleMapsUrl: googleMapsUrl ?? base.googleMapsUrl,
        phone: phone ?? base.phone,
        description: description ?? base.description,
        amenities: amenities.isNotEmpty ? amenities : base.amenities,
        openHour: openHour ?? base.openHour,
        closeHour: closeHour ?? base.closeHour,
        venues: venues.isNotEmpty ? venues : base.venues,
      );
}

/// One venue parsed from free text (bulk-AI venue creation).
class VenueParseResult {
  const VenueParseResult({
    required this.name,
    required this.sportType,
    required this.pricePerHour,
    this.indoor = false,
  });

  final String name;
  final String sportType;
  final int pricePerHour;
  final bool indoor;
}

/// One chat bubble in the assistant conversation.
class ChatMessage {
  const ChatMessage({required this.fromUser, required this.text});
  final bool fromUser;
  final String text;
}

/// Assistant reply + the data snapshot parsed from its JSON block.
class ChatTurn {
  const ChatTurn({required this.reply, this.snapshot});
  final String reply;
  final CourtParseResult? snapshot;
}
