import 'package:flutter/material.dart';

import '../../paint_contents.dart';
import '../../paint_extension.dart';

class RectangleWithText extends PaintContent {
  RectangleWithText(this.name);

  RectangleWithText.data({
    required this.startPoint,
    required this.endPoint,
    required this.name,
    required Paint paint,
  }) : super.paint(paint);

  /// Starting point
  Offset startPoint = Offset.zero;

  /// End point
  Offset endPoint = Offset.zero;

  /// Name of the object
  String name;

  @override
  PaintContent copy() => RectangleWithText(name);

  @override
  void draw(Canvas canvas, Size size, bool deeper) {
    canvas.drawRect(Rect.fromPoints(startPoint, endPoint), paint);

    final TextStyle textStyle = TextStyle(
      color: paint.color,
      fontSize: 24,
    );

    final TextSpan textSpan = TextSpan(
      text: name,
      style: textStyle,
    );

    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout(
      maxWidth: size.width,
    );

    final Offset offset = Offset(
      ((startPoint.dx + endPoint.dx) - textPainter.width) / 2,
      ((startPoint.dy + endPoint.dy) - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);
  }

  @override
  void drawing(Offset nowPoint) => endPoint = nowPoint;

  @override
  void startDraw(Offset startPoint) => this.startPoint = startPoint;

  @override
  Map<String, dynamic> toContentJson() => <String, dynamic>{
        'startPoint': startPoint.toJson(),
        'endPoint': endPoint.toJson(),
        'paint': paint.toJson(),
        'name': name,
      };
}
