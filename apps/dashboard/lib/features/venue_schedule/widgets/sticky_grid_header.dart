import 'package:flutter/widgets.dart';

/// Replicates the handoff's `position: sticky; top: 0; z-index: 6` of
/// `.day-head` / `.week-head` inside the page's single vertical scroll view.
///
/// Lays out `[header] above [body]` like a plain Column. While the grid
/// spans the viewport's top edge, a pinned copy of [header] is painted above
/// the body at the viewport top; once the grid end approaches it slides out
/// with the grid, exactly like CSS sticky ([maxStick] caps the travel — pass
/// the body height so `header bottom == grid bottom` at the limit).
///
/// Finds the nearest VERTICAL scrollable, so it keeps working when the grid
/// is additionally wrapped in a horizontal scroll view (<1024px breakpoint).
class StickyGridHeader extends StatefulWidget {
  const StickyGridHeader({
    super.key,
    required this.header,
    required this.body,
    required this.maxStick,
  });

  /// The grid header row — must paint its own opaque background.
  final Widget header;

  /// The grid body below the header.
  final Widget body;

  /// Maximum pin travel in logical px (the body height).
  final double maxStick;

  @override
  State<StickyGridHeader> createState() => _StickyGridHeaderState();
}

class _StickyGridHeaderState extends State<StickyGridHeader> {
  ScrollPosition? _position;

  /// How far the pinned header copy is pushed down from the grid top so it
  /// sits at the viewport top — 0 means "not stuck" (no copy painted).
  double _stick = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context, axis: Axis.vertical)?.position;
    if (!identical(position, _position)) {
      _position?.removeListener(_recompute);
      _position = position?..addListener(_recompute);
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_recompute);
    super.dispose();
  }

  void _recompute() {
    if (!mounted) return;
    final stick = _computeStick();
    if (stick != _stick) setState(() => _stick = stick);
  }

  /// Distance the grid top has scrolled past the viewport top, clamped to
  /// the sticky range. Uses paint transforms (which include the scroll
  /// offset) so it also works through an intermediate horizontal viewport.
  double _computeStick() {
    final box = context.findRenderObject();
    final scrollable = Scrollable.maybeOf(context, axis: Axis.vertical);
    if (box is! RenderBox || !box.attached || scrollable == null) return 0;
    final viewport = scrollable.context.findRenderObject();
    if (viewport is! RenderBox || !viewport.attached) return 0;
    final top = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
    return (-top).clamp(0.0, widget.maxStick);
  }

  @override
  Widget build(BuildContext context) {
    // Catch position changes that happen without a scroll event (resize,
    // content above the grid reflowing) — converges in one extra frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _recompute());
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [widget.header, widget.body],
        ),
        // Pinned copy — painted last so it covers the body (and the in-flow
        // header it has scrolled past), like the CSS z-index: 6.
        if (_stick > 0)
          Positioned(
            top: _stick,
            left: 0,
            right: 0,
            child: widget.header,
          ),
      ],
    );
  }
}
