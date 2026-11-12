import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Figma frames are 414 x 896. This widget scales design pixels to the
/// device width and lays children out in a [Stack]. If the screen is shorter
/// than the design (or the keyboard is open) the content scrolls.
///
/// Children receive the scale factor `s`: multiply every Figma value by it.
/// Position top elements with `top:` and bottom elements with `bottom:` so
/// that taller phones put the extra space in the middle.
class DesignCanvas extends StatelessWidget {
  const DesignCanvas({super.key, required this.builder});

  static const designWidth = 414.0;
  static const designHeight = 896.0;

  final List<Widget> Function(BuildContext context, double s) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final s = constraints.maxWidth / designWidth;
        final height = math.max(constraints.maxHeight, designHeight * s);
        return SingleChildScrollView(
          child: SizedBox(
            width: constraints.maxWidth,
            height: height,
            child: Stack(clipBehavior: Clip.none, children: builder(context, s)),
          ),
        );
      },
    );
  }
}
