import 'package:flutter/widgets.dart';

/// Tracks AI-assisted fill for the court form: which field keys were written by
/// AI (the ✦ mark, [aiFilled]) and which are showing the one-shot highlight
/// ([pulse]). Owns the 1.6s pulse-clear timing so the three fill paths — AI
/// parse, AI description, Maps-URL coord sync — don't each re-implement it.
///
/// Both sets are passed straight to `AiField` / `AiHint`, so the host
/// [State] only needs to mutate them through [flashFields] / [clearAiMark].
mixin CourtFormAiFill<T extends StatefulWidget> on State<T> {
  /// Field keys whose value was written by AI and not yet manually edited.
  final Set<String> aiFilled = {};

  /// Field keys currently showing the tertiaryContainer pulse.
  final Set<String> pulse = {};

  static const _pulseDuration = Duration(milliseconds: 1600);

  /// Drops the ✦ mark when the owner manually edits [key].
  void clearAiMark(String key) {
    if (aiFilled.remove(key)) setState(() {});
  }

  /// Flash [keys]: show the pulse highlight now and auto-clear it after 1.6s.
  /// When [markFilled] is set the keys also gain the persistent ✦ mark.
  ///
  /// Each flash clears only its own keys, so overlapping flashes (e.g. a Maps
  /// coord sync landing during an AI parse) don't wipe each other.
  void flashFields(Set<String> keys, {bool markFilled = false}) {
    if (keys.isEmpty) return;
    setState(() {
      if (markFilled) aiFilled.addAll(keys);
      pulse.addAll(keys);
    });
    Future.delayed(_pulseDuration, () {
      if (mounted) setState(() => pulse.removeAll(keys));
    });
  }
}
