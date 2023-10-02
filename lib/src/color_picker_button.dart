import 'package:flutter/material.dart';

import '../flutter_drawing_board.dart';
import '../helpers.dart';
import 'helper/color_picker_helper.dart';

class ColorPickerButton extends StatelessWidget {
  const ColorPickerButton({
    super.key,
    this.builder,
    required this.controller,
  });

  final Widget Function(Color color)? builder;
  final DrawingController controller;

  Future<void> _pickColor(BuildContext context) async {
    final Color? newColor = await showModalBottomSheet<Color?>(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (_) => ColorPickerHelper(nowColor: controller.getColor),
    );

    if (newColor == null) {
      return;
    }

    if (newColor != controller.getColor) {
      controller.setStyle(color: newColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickColor(context),
      child: ExValueBuilder<DrawConfig>(
        valueListenable: controller.drawConfig,
        shouldRebuild: (DrawConfig p, DrawConfig n) => p.color != n.color,
        builder: (_, DrawConfig dc, __) =>
            builder?.call(dc.color) ??
            Container(
              width: 24,
              height: 24,
              color: dc.color,
              margin: const EdgeInsets.all(10.0),
            ),
      ),
    );
  }
}
