import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../domain/court.dart';

/// Per-sport colour / glyph / label (prototype `cm3SportColor` + common.jsx).
abstract final class SportStyle {
  SportStyle._();

  static Color color(Sport sport) => switch (sport) {
    Sport.pickleball => const Color(0xFF0EA5E9),
    Sport.tennis => const Color(0xFFEAB308),
    Sport.football => const Color(0xFF22C55E),
    Sport.badminton => const Color(0xFFEF4444),
    Sport.multi => const Color(0xFF42493F),
  };

  static IconData icon(Sport sport) => switch (sport) {
    Sport.football => Icons.sports_soccer,
    Sport.badminton => Icons.sports_tennis,
    Sport.pickleball => Icons.sports_tennis,
    Sport.tennis => Icons.sports_tennis,
    Sport.multi => Icons.sports,
  };

  static String label(AppLocalizations l10n, Sport sport) => switch (sport) {
    Sport.football => l10n.sportFootball,
    Sport.badminton => l10n.sportBadminton,
    Sport.pickleball => l10n.sportPickleball,
    Sport.tennis => l10n.sportTennis,
    Sport.multi => l10n.sportMulti,
  };
}
