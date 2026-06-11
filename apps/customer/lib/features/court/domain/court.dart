// EPIC-5 domain models — Court & SportsCenter (handoff doc 04 §1).

enum Sport { football, badminton, pickleball, tennis, multi }

class Court {
  const Court({
    required this.id,
    required this.centerId,
    required this.name,
    required this.address,
    required this.sports,
    required this.pricePerHourVnd,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.photoUrls,
    required this.amenities,
    required this.description,
    required this.openSlotsToday,
    required this.lat,
    required this.lng,
  });

  final String id;
  final String centerId;
  final String name;
  final String address;

  /// First entry is the primary sport (the selected chip on screen 07).
  final List<Sport> sports;
  final int pricePerHourVnd;
  final double rating;
  final int reviewCount;
  final double distanceKm;

  /// Supabase Storage URLs — empty ⇒ placeholder art.
  final List<String> photoUrls;
  final List<String> amenities;
  final String description;
  final int openSlotsToday;
  final double lat;
  final double lng;

  Sport get primarySport => sports.isNotEmpty ? sports.first : Sport.multi;
}

class SportsCenter {
  const SportsCenter({
    required this.id,
    required this.name,
    required this.courts,
  });

  final String id;
  final String name;

  /// Rows of the schedule grid (screen 08).
  final List<Court> courts;
}
