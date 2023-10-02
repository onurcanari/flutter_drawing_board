import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

/// Abstract class for drawing objects
abstract class PaintContent {
  PaintContent();

  PaintContent.paint(this.paint);

  /// Paintbrush
  late Paint paint;

  /// Duplicate instances to avoid object passing
  PaintContent copy();

  /// Mapping of core methods
  /// * [deeper] Whether or not it is currently the bottom drawing
  /// * For performance reasons
  /// * The drawing process is a surface drawing, and the bottom drawing is done when the finger is lifted after the drawing is completed.
  void draw(Canvas canvas, Size size, bool deeper);

  /// Drawing in progress
  void drawing(Offset nowPoint);

  /// Start drawing
  void startDraw(Offset startPoint);

  /// toJson
  Map<String, dynamic> toContentJson();

  /// toJson
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': runtimeType.toString(),
      ...toContentJson(),
    };
  }
}
