import 'package:flutter/widgets.dart';

/// Tracks pointer hover and rebuilds [builder] with the current state, so a
/// widget can restyle on hover without its own `StatefulWidget` + `_hovered`
/// + [MouseRegion] boilerplate.
///
/// [enabled] gates both the cursor and the reported hover: when false the
/// builder always receives `false` and the [disabledCursor] is shown (handy
/// for buttons whose `onTap` is null).
///
/// ```dart
/// HoverBuilder(
///   enabled: onTap != null,
///   builder: (context, hovered) => GestureDetector(
///     onTap: onTap,
///     child: ColoredBox(color: hovered ? hot : cold),
///   ),
/// );
/// ```
class HoverBuilder extends StatefulWidget {
  const HoverBuilder({
    super.key,
    required this.builder,
    this.enabled = true,
    this.cursor = SystemMouseCursors.click,
    this.disabledCursor = SystemMouseCursors.basic,
  });

  /// Rebuilt on hover enter/exit; receives the effective hover state (always
  /// `false` while [enabled] is false).
  final Widget Function(BuildContext context, bool hovered) builder;

  /// When false, hover is suppressed (always `false`) and [disabledCursor] is
  /// used.
  final bool enabled;

  /// Cursor while [enabled].
  final MouseCursor cursor;

  /// Cursor while not [enabled].
  final MouseCursor disabledCursor;

  @override
  State<HoverBuilder> createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<HoverBuilder> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.enabled ? widget.cursor : widget.disabledCursor,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: widget.builder(context, _hovered && widget.enabled),
    );
  }
}
