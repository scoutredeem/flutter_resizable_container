import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:flutter_resizable_container/src/extensions/box_constraints_ext.dart';
import 'package:flutter_resizable_container/src/resizable_container_divider.dart';
import 'package:flutter_resizable_container/src/resizable_controller.dart';

/// A container that holds multiple child [Widget]s that can be resized.
///
/// Dividing lines will be added between each child. Dragging the dividers
/// will resize the children along the [direction] axis.
class ResizableContainer extends StatefulWidget {
  /// Creates a new [ResizableContainer] with the given [direction] and list
  /// of [children] Widgets.
  ///
  /// The sum of the [children]'s starting ratios must be equal to 1.0.
  const ResizableContainer({
    super.key,
    required this.children,
    required this.direction,
    required this.divider,
    required this.snappedLeftDividerIcon,
    required this.snappedRightDividerIcon,
    this.controller,
    this.onTap,
  });

  /// A list of resizable [ResizableChild] containing the child [Widget]s and
  /// their sizing configuration.
  final List<ResizableChild> children;

  /// The controller that will be used to manage programmatic resizing of the children.
  final ResizableController? controller;

  /// The direction along which the child widgets will be laid and resized.
  final Axis direction;

  /// Configuration values for the dividing space/line between this container's [children].
  final ResizableDivider divider;

  /// The [Widget] that will be displayed when the divider is snapped to Left.
  final Widget snappedLeftDividerIcon;

  /// The [Widget] that will be displayed when the divider is snapped to Right.
  final Widget snappedRightDividerIcon;

  final VoidCallback? onTap;

  @override
  State<ResizableContainer> createState() => _ResizableContainerState();
}

class _ResizableContainerState extends State<ResizableContainer> {
  late final controller = widget.controller ?? ResizableController();
  late final isDefaultController = widget.controller == null;
  late final manager = ResizableControllerManager(controller);

  final childrenGap = 2.0;

  @override
  void initState() {
    super.initState();

    manager.setChildren(widget.children);
  }

  @override
  void didUpdateWidget(covariant ResizableContainer oldWidget) {
    final hasChanges = !listEquals(oldWidget.children, widget.children);

    if (hasChanges) {
      manager.updateChildren(widget.children);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (isDefaultController) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableSpace = _getAvailableSpace(constraints);
        manager.setAvailableSpace(availableSpace);

        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Builder(
                  builder: (context) {
                    return AnimatedPositioned(
                      duration: controller.animating
                          ? controller.animationDuration
                          : Duration.zero,
                      left: _getLeftPosition(controller.snapPosition),
                      child: AnimatedContainer(
                        duration: controller.animating
                            ? controller.animationDuration
                            : Duration.zero,
                        padding: EdgeInsets.only(right: childrenGap),
                        height: widget.divider.height,
                        width:
                            _getWidthLeft(controller.snapPosition, constraints),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: widget.children[0].child,
                        ),
                      ),
                    );
                  },
                ),
                Builder(
                  builder: (context) {
                    return AnimatedPositioned(
                      duration: controller.animating
                          ? controller.animationDuration
                          : Duration.zero,
                      right: _getRightPosition(
                        controller.snapPosition,
                        constraints,
                      ),
                      child: AnimatedContainer(
                        duration: controller.animating
                            ? controller.animationDuration
                            : Duration.zero,
                        padding: EdgeInsets.only(left: childrenGap),
                        height: widget.divider.height,
                        width: _getWidthRight(
                          controller.snapPosition,
                          constraints,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: widget.children[1].child,
                        ),
                      ),
                    );
                  },
                ),
                AnimatedPositioned(
                  duration: controller.animating
                      ? controller.animationDuration
                      : Duration.zero,
                  left: _getDividerPosition(
                    controller.snapPosition,
                    constraints,
                  ),
                  child: ResizableContainerDivider(
                    config: widget.divider,
                    direction: widget.direction,
                    onResizeUpdate: (delta) => manager.adjustChildSize(
                      index: 0,
                      delta: delta,
                    ),
                    snappedLeftDividerIcon: widget.snappedLeftDividerIcon,
                    snappedRightDividerIcon: widget.snappedRightDividerIcon,
                    snapPosition: controller.snapPosition,
                    onTap: widget.onTap,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  double? _getDividerPosition(
      SnapPosition? snapPosition, BoxConstraints constraints) {
    final anchorPosition =
        controller.sizes.first - (widget.divider.thickness / 2);
    if (snapPosition == null) {
      return anchorPosition;
    }

    if (snapPosition == SnapPosition.start) {
      return 0;
    }

    if (snapPosition == SnapPosition.end) {
      return constraints.maxWidth - 34;
    }

    return anchorPosition - 6;
  }

  double _getAvailableSpace(BoxConstraints constraints) {
    final totalSpace = constraints.maxForDirection(widget.direction);
    return totalSpace;
  }

  double _getChildSize({
    required int index,
    required Axis direction,
    required BoxConstraints constraints,
  }) {
    return controller.sizes[index];
  }

  double _getLeftPosition(SnapPosition? snapPosition) {
    if (snapPosition == SnapPosition.start) {
      return -ResizableController.snapSize +
          ResizableController.unSnapPoint +
          childrenGap;
    }

    return 0;
  }

  double _getWidthLeft(SnapPosition? snapPosition, BoxConstraints constraints) {
    final width = _getChildSize(
      index: 0,
      direction: Axis.horizontal,
      constraints: constraints,
    );

    if (width < 0) {
      return 0;
    }

    if (snapPosition == SnapPosition.start) {
      return ResizableController.snapSize;
    }

    if (snapPosition == SnapPosition.end) {
      return constraints.maxWidth -
          ResizableController.unSnapPoint -
          childrenGap;
    }

    return width;
  }

  double _getRightPosition(
      SnapPosition? snapPosition, BoxConstraints constraints) {
    if (snapPosition == SnapPosition.start) {
      return 0;
    }

    if (snapPosition == SnapPosition.end) {
      return -ResizableController.snapSize +
          ResizableController.unSnapPoint +
          childrenGap;
    }

    return 0;
  }

  double _getWidthRight(
    SnapPosition? snapPosition,
    BoxConstraints constraints,
  ) {
    final width = _getChildSize(
      index: 1,
      direction: Axis.horizontal,
      constraints: constraints,
    );

    if (width < 0) {
      return 0;
    }

    if (snapPosition == SnapPosition.start) {
      return constraints.maxWidth -
          ResizableController.unSnapPoint -
          childrenGap;
    }

    if (snapPosition == SnapPosition.end) {
      return ResizableController.snapSize;
    }

    return width;
  }
}
