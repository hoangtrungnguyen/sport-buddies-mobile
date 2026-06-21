import 'package:flutter/material.dart';

/// 18×18 inline progress spinner sized for a button's loading state
/// (`strokeWidth: 2`) — the swap-in for a button's label/icon while an action
/// is in flight.
///
/// Pass [color] (usually white) on filled/primary buttons; omit it on light
/// buttons to use the theme's indicator colour.
class ButtonSpinner extends StatelessWidget {
  const ButtonSpinner({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2, color: color),
    );
  }
}
