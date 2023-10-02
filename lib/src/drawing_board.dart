import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zoom_widget/zoom_widget.dart' as zoom;

import 'color_picker_button.dart';
import 'drawing_controller.dart';
import 'helper/ex_value_builder.dart';
import 'helper/get_size.dart';
import 'paint_contents/circle.dart';
import 'paint_contents/eraser.dart';
import 'paint_contents/rectangle.dart';
import 'paint_contents/simple_line.dart';
import 'paint_contents/smooth_line.dart';
import 'paint_contents/straight_line.dart';
import 'painter.dart';

/// Default tools builder
typedef DefaultToolsBuilder = List<DefToolItem> Function(
  Type currType,
  DrawingController controller,
);

/// Drawing board
class DrawingBoard extends StatefulWidget {
  const DrawingBoard({
    super.key,
    required this.background,
    this.controller,
    this.showDefaultActions = false,
    this.showDefaultTools = false,
    this.onPointerDown,
    this.onPointerMove,
    this.onPointerUp,
    this.clipBehavior = Clip.antiAlias,
    this.defaultToolsBuilder,
    this.maxScale = 20,
    this.alignment = Alignment.topCenter,
    this.doubleTapZoom,
    this.initialTotalZoomOut,
    this.onPanUpPosition,
    this.onPanDownPosition,
    this.onPositionUpdate,
    this.onScaleUpdate,
    this.onTap,
  });

  /// Background of the drawing board
  final Widget background;

  /// Controller of the drawing board
  final DrawingController? controller;

  /// Displays the default style action bar
  final bool showDefaultActions;

  /// Show default style toolbar
  final bool showDefaultTools;

  /// Callback function for the start of the dragging
  final Function(PointerDownEvent pde)? onPointerDown;

  /// Callback function for the dragging
  final Function(PointerMoveEvent pme)? onPointerMove;

  /// Callback function for the end of the dragging
  final Function(PointerUpEvent pue)? onPointerUp;

  /// Edge cropping method
  final Clip clipBehavior;

  /// Default toolbar builder
  final DefaultToolsBuilder? defaultToolsBuilder;

  /// Properties for the zooming
  final double maxScale;
  final AlignmentGeometry alignment;
  final bool? doubleTapZoom;
  final bool? initialTotalZoomOut;
  final void Function(Offset)? onPanUpPosition;
  final void Function(Offset)? onPanDownPosition;
  final void Function(Offset)? onPositionUpdate;
  final void Function(double, double)? onScaleUpdate;
  final void Function()? onTap;

  /// Default tool list
  static List<DefToolItem> defaultTools(
      Type currType, DrawingController controller) {
    return <DefToolItem>[
      DefToolItem(
          isActive: currType == SimpleLine,
          icon: CupertinoIcons.pencil,
          onTap: () => controller.setPaintContent(SimpleLine())),
      DefToolItem(
          isActive: currType == SmoothLine,
          icon: Icons.brush,
          onTap: () => controller.setPaintContent(SmoothLine())),
      DefToolItem(
          isActive: currType == StraightLine,
          icon: Icons.show_chart,
          onTap: () => controller.setPaintContent(StraightLine())),
      DefToolItem(
          isActive: currType == Rectangle,
          icon: CupertinoIcons.stop,
          onTap: () => controller.setPaintContent(Rectangle())),
      DefToolItem(
          isActive: currType == Circle,
          icon: CupertinoIcons.circle,
          onTap: () => controller.setPaintContent(Circle())),
      DefToolItem(
          isActive: currType == Eraser,
          icon: CupertinoIcons.bandage,
          onTap: () => controller.setPaintContent(Eraser(color: Colors.white))),
    ];
  }

  @override
  State<DrawingBoard> createState() => _DrawingBoardState();
}

class _DrawingBoardState extends State<DrawingBoard> {
  late final DrawingController _controller =
      widget.controller ?? DrawingController();

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = zoom.Zoom(
      maxScale: widget.maxScale,
      doubleTapZoom: widget.doubleTapZoom ?? false,
      initTotalZoomOut: widget.initialTotalZoomOut ?? true,
      onTap: widget.onTap,
      onPanUpPosition: widget.onPanUpPosition,
      onPanDownPosition: widget.onPanDownPosition,
      onPositionUpdate: widget.onPositionUpdate,
      onScaleUpdate: widget.onScaleUpdate,
      child: Align(
        alignment: widget.alignment,
        child: _buildBoard,
      ),
    );

    if (widget.showDefaultActions || widget.showDefaultTools) {
      content = Column(
        children: <Widget>[
          Expanded(child: content),
          if (widget.showDefaultActions) _buildDefaultActions,
          if (widget.showDefaultTools) _buildDefaultTools,
        ],
      );
    }

    return Listener(
      onPointerDown: (PointerDownEvent pde) =>
          _controller.addFingerCount(pde.localPosition),
      onPointerUp: (PointerUpEvent pue) =>
          _controller.reduceFingerCount(pue.localPosition),
      child: content,
    );
  }

  /// Constructing the drawing board
  Widget get _buildBoard {
    return RepaintBoundary(
      key: _controller.painterKey,
      child: ExValueBuilder<DrawConfig>(
        valueListenable: _controller.drawConfig,
        shouldRebuild: (DrawConfig p, DrawConfig n) =>
            p.angle != n.angle || p.size != n.size,
        builder: (_, DrawConfig dc, Widget? child) {
          Widget c = child!;

          if (dc.size != null) {
            final bool isHorizontal = dc.angle.toDouble() % 2 == 0;
            final double max = dc.size!.longestSide;

            if (!isHorizontal) {
              c = SizedBox(
                width: max,
                height: max,
                child: c,
              );
            }
          }

          return Transform.rotate(
            angle: dc.angle * pi / 2,
            child: c,
          );
        },
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[_buildImage, _buildPainter],
          ),
        ),
      ),
    );
  }

  /// Context of the image
  Widget get _buildImage => GetSize(
        onChange: (Size? size) => _controller.setBoardSize(size),
        child: widget.background,
      );

  /// Constructing the drawing layer
  Widget get _buildPainter {
    return ExValueBuilder<DrawConfig>(
      valueListenable: _controller.drawConfig,
      shouldRebuild: (DrawConfig p, DrawConfig n) => p.size != n.size,
      builder: (_, DrawConfig dc, Widget? child) {
        return SizedBox(
          width: dc.size?.width,
          height: dc.size?.height,
          child: child,
        );
      },
      child: Painter(
        drawingController: _controller,
        onPointerDown: widget.onPointerDown,
        onPointerMove: widget.onPointerMove,
        onPointerUp: widget.onPointerUp,
      ),
    );
  }

  /// Building the default action bar
  Widget get _buildDefaultActions {
    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: Row(
          children: <Widget>[
            SizedBox(
              height: 24,
              width: 160,
              child: ExValueBuilder<DrawConfig>(
                valueListenable: _controller.drawConfig,
                shouldRebuild: (DrawConfig p, DrawConfig n) =>
                    p.strokeWidth != n.strokeWidth,
                builder: (_, DrawConfig dc, ___) {
                  return Slider(
                    value: dc.strokeWidth,
                    max: 50,
                    min: 1,
                    onChanged: (double v) =>
                        _controller.setStyle(strokeWidth: v),
                  );
                },
              ),
            ),
            ColorPickerButton(controller: _controller),
            IconButton(
                icon: const Icon(CupertinoIcons.arrow_turn_up_left),
                onPressed: () => _controller.undo()),
            IconButton(
                icon: const Icon(CupertinoIcons.arrow_turn_up_right),
                onPressed: () => _controller.redo()),
            IconButton(
                icon: const Icon(CupertinoIcons.rotate_right),
                onPressed: () => _controller.turn()),
            IconButton(
                icon: const Icon(CupertinoIcons.trash),
                onPressed: () => _controller.clear()),
          ],
        ),
      ),
    );
  }

  /// Building the default toolbar
  Widget get _buildDefaultTools {
    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: ExValueBuilder<DrawConfig>(
          valueListenable: _controller.drawConfig,
          shouldRebuild: (DrawConfig p, DrawConfig n) =>
              p.contentType != n.contentType,
          builder: (_, DrawConfig dc, ___) {
            final Type currType = dc.contentType;

            return Row(
              children:
                  (widget.defaultToolsBuilder?.call(currType, _controller) ??
                          DrawingBoard.defaultTools(currType, _controller))
                      .map((DefToolItem item) => _DefToolItemWidget(item: item))
                      .toList(),
            );
          },
        ),
      ),
    );
  }
}

/// Default tool item
class DefToolItem {
  DefToolItem({
    required this.icon,
    required this.isActive,
    this.onTap,
    this.color,
    this.activeColor = Colors.blue,
    this.iconSize,
  });

  final Function()? onTap;
  final bool isActive;

  final IconData icon;
  final double? iconSize;
  final Color? color;
  final Color activeColor;
}

/// Widget for the default tool items
class _DefToolItemWidget extends StatelessWidget {
  const _DefToolItemWidget({
    required this.item,
  });

  final DefToolItem item;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: item.onTap,
      icon: Icon(
        item.icon,
        color: item.isActive ? item.activeColor : item.color,
        size: item.iconSize,
      ),
    );
  }
}
