import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';

class ResizableContainerDivider extends StatefulWidget {
  const ResizableContainerDivider({
    super.key,
    required this.direction,
    required this.onResizeUpdate,
    required this.config,
    required this.snappedChild,
    required this.snapPosition,
    required this.onTap,
  });

  final Axis direction;
  final void Function(double) onResizeUpdate;
  final ResizableDivider config;
  final Widget snappedChild;
  final SnapPosition? snapPosition;
  final VoidCallback? onTap;

  @override
  State<ResizableContainerDivider> createState() =>
      _ResizableContainerDividerState();
}

class _ResizableContainerDividerState extends State<ResizableContainerDivider> {
  bool isDragging = false;
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final snapped = widget.snapPosition != null;

    final width = _getWidth();
    final height = _getHeight();

    return MouseRegion(
      cursor: _getCursor(),
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        onVerticalDragStart: _onVerticalDragStart,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        onTap: widget.onTap,
        child: Container(
          height: height,
          width: snapped ? 34 : width,
          color: widget.config.backgroundColor,
          child: Center(
            child: AnimatedContainer(
              height: 68,
              duration: const Duration(milliseconds: 200),
              width: snapped ? 34 : 10,
              decoration: BoxDecoration(
                color: snapped
                    ? widget.config.snappedBackgroundColor
                    : widget.config.color,
                borderRadius: _getBorderRadius(),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: snapped ? widget.snappedChild : null,
            ),
          ),
        ),
      ),
    );
  }

  BorderRadiusGeometry _getBorderRadius() {
    if (widget.snapPosition == null) {
      return BorderRadius.circular(widget.config.thickness / 2);
    }

    if (widget.snapPosition == SnapPosition.end) {
      return const BorderRadius.only(
        topLeft: Radius.circular(8),
        bottomLeft: Radius.circular(8),
      );
    }

    return const BorderRadius.only(
      topRight: Radius.circular(8),
      bottomRight: Radius.circular(8),
    );
  }

  MouseCursor _getCursor() {
    return switch (widget.direction) {
      Axis.horizontal => SystemMouseCursors.resizeLeftRight,
      Axis.vertical => SystemMouseCursors.resizeUpDown,
    };
  }

  double _getHeight() {
    return widget.config.height;
  }

  double _getWidth() {
    return switch (widget.direction) {
      Axis.horizontal => widget.config.thickness,
      Axis.vertical => double.infinity,
    };
  }

  void _onEnter(PointerEnterEvent _) {
    setState(() => isHovered = true);
    widget.config.onHoverEnter?.call();
  }

  void _onExit(PointerExitEvent _) {
    setState(() => isHovered = false);

    if (!isDragging) {
      widget.config.onHoverExit?.call();
    }
  }

  void _onVerticalDragStart(DragStartDetails _) {
    if (widget.direction == Axis.vertical) {
      setState(() => isDragging = true);
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (widget.direction == Axis.vertical) {
      widget.onResizeUpdate(details.delta.dy);
    }
  }

  void _onVerticalDragEnd(DragEndDetails _) {
    if (widget.direction == Axis.vertical) {
      setState(() => isDragging = false);

      if (!isHovered) {
        widget.config.onHoverExit?.call();
      }
    }
  }

  void _onHorizontalDragStart(DragStartDetails _) {
    if (widget.direction == Axis.horizontal) {
      setState(() => isDragging = true);
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (widget.direction == Axis.horizontal) {
      widget.onResizeUpdate(details.delta.dx);
    }
  }

  void _onHorizontalDragEnd(DragEndDetails _) {
    if (widget.direction == Axis.horizontal) {
      setState(() => isDragging = false);

      if (!isHovered) {
        widget.config.onHoverExit?.call();
      }
    }
  }
}
