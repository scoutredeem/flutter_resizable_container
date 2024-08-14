import 'package:flutter/material.dart';

class ResizableDivider {
  const ResizableDivider({
    this.thickness = 1.0,
    this.height = 2.0,
    this.color,
    this.indent,
    this.endIndent,
    this.onHoverEnter,
    this.onHoverExit,
    this.backgroundColor = Colors.transparent,
    this.peekSize = 16.0,
    this.leftSnappedBackgroundColor = Colors.transparent,
    this.rightSnappedBackgroundColor = Colors.transparent,
    this.snapDuration = const Duration(milliseconds: 200),
  })  : assert(height >= thickness, '[size] must be >= [thickness].'),
        assert(thickness > 0, '[thickness] must be > 0.');

  /// The thickness of the line drawn within the divider.
  ///
  /// Defaults to 1.0.
  final double thickness;

  /// The divider's size (height/width) extent.
  /// The divider line will be drawn in the center of this space.
  ///
  /// Defaults to 2.0.
  final double height;

  /// The color of the dividers between children.
  ///
  /// Defaults to [ThemeData.dividerColor].
  final Color? color;

  /// The amount of empty space to the leading edge of the divider.
  ///
  /// For dividers running from top-to-bottom, this adds empty space at the top.
  /// For dividers running from left-to-right, this adds empty space to the left.
  final double? indent;

  /// The amount of empty space to the trailing edge of the divider.
  ///
  /// For dividers running from top-to-bottom, this adds empty space at the bottom.
  /// For dividers running from left-to-right, this adds empty space to the right.
  final double? endIndent;

  /// Triggers when the user's cursor begins hovering over this divider.
  final VoidCallback? onHoverEnter;

  /// Triggers when the user's cursor ends hovering over this divider.
  final VoidCallback? onHoverExit;

  /// Background color for the divider.
  final Color backgroundColor;

  /// The peek size of the child,
  final double peekSize;

  /// Snapped background color for left snap
  final Color leftSnappedBackgroundColor;

  /// Snapped background color for right snap
  final Color rightSnappedBackgroundColor;

  /// Snap animation duration
  final Duration snapDuration;
}
