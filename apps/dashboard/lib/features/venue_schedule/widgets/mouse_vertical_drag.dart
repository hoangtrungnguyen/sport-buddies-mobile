import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Vertical-drag recognizer limited to MOUSE pointers.
///
/// The Day/Week grids claim vertical drags for drag-to-block; recognising
/// touch pans too would scroll-lock the page over the 1020px-tall grid on
/// touch devices (the prototype never `preventDefault()`s touch, so native
/// scrolling survives there). Restricting to [PointerDeviceKind.mouse] lets
/// touch pans fall through to the page's scroll view while mouse drags keep
/// drawing the block band.
class MouseVerticalDrag extends StatelessWidget {
  const MouseVerticalDrag({
    super.key,
    this.onStart,
    this.onUpdate,
    this.onEnd,
    this.onCancel,
    required this.child,
  });

  final GestureDragStartCallback? onStart;
  final GestureDragUpdateCallback? onUpdate;
  final GestureDragEndCallback? onEnd;
  final GestureDragCancelCallback? onCancel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        VerticalDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
          () => VerticalDragGestureRecognizer(
            supportedDevices: const {PointerDeviceKind.mouse},
          ),
          (recognizer) => recognizer
            ..onStart = onStart
            ..onUpdate = onUpdate
            ..onEnd = onEnd
            ..onCancel = onCancel,
        ),
      },
      child: child,
    );
  }
}
