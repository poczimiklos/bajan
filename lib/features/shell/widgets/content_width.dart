import 'package:flutter/material.dart';

/// Centers page content and caps its width so layouts stay readable on desktop.
class ContentWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const ContentWidth({super.key, required this.child, this.maxWidth = 900});

  @override
  Widget build(BuildContext context) => Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child));
}
