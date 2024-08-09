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
    required this.snappedDivider,
    this.snapPosition,
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

  /// Child used for divider when the children size is snapped
  final Widget snappedDivider;

  /// Indicates which direction the children is snapped
  final SnapPosition? snapPosition;

  final VoidCallback? onTap;

  @override
  State<ResizableContainer> createState() => _ResizableContainerState();
}

class _ResizableContainerState extends State<ResizableContainer> {
  late final controller = widget.controller ?? ResizableController();
  late final isDefaultController = widget.controller == null;
  late final manager = ResizableControllerManager(controller);

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
                Flex(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  direction: widget.direction,
                  children: [
                    for (var i = 0; i < widget.children.length; i++) ...[
                      // build the child
                      Builder(
                        builder: (context) {
                          final isFirst = i == 0;
                          final isLast = i == widget.children.length - 1;

                          final height = _getChildSize(
                            index: i,
                            direction: Axis.vertical,
                            constraints: constraints,
                          );

                          final width = _getChildSize(
                            index: i,
                            direction: Axis.horizontal,
                            constraints: constraints,
                          );

                          return Container(
                            padding: EdgeInsets.only(
                              left: isFirst ? 0 : 2,
                              right: isLast ? 0 : 2,
                            ),
                            height: height < 0 ? 0 : height,
                            width: width < 0 ? 0 : width,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: widget.children[i].child,
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
                Positioned(
                  left: _getDividerPosition(),
                  child: ResizableContainerDivider(
                    config: widget.divider,
                    direction: widget.direction,
                    onResizeUpdate: (delta) => manager.adjustChildSize(
                      index: 0,
                      delta: delta,
                    ),
                    snappedChild: widget.snappedDivider,
                    snapPosition: widget.snapPosition,
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

  double? _getDividerPosition() {
    final anchorPosition =
        controller.sizes.first - (widget.divider.thickness / 2);
    if (widget.snapPosition == null) {
      return anchorPosition;
    }

    if (widget.snapPosition == SnapPosition.start) {
      return anchorPosition - 4;
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
    return direction != direction
        ? constraints.maxForDirection(direction)
        : controller.sizes[index];
  }
}
