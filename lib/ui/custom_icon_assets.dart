import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gpspro/theme/CustomColor.dart';

class CustomIconAssets extends CustomPainter {
  final String _label;
  final ui.Image _image;

  CustomIconAssets(this._label, this._image);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(10));

    paint.color = MAPS_IMAGES_COLOR;
    paint.strokeWidth = 2;

    canvas.drawRRect(rRect, paint);

    final textPainter = TextPainter(
        text: TextSpan(
          text: this._label,
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        textDirection: TextDirection.ltr);

    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(
        canvas, Offset(15, size.height / 2 - textPainter.size.height / 2));

    Paint paint2 = Paint();
    paint2.blendMode = BlendMode.src;
    canvas.drawImage(
        _image, Offset(size.width / 2 - _image.width / 2, size.height), paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
