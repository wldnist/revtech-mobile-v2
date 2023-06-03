import 'package:flutter/material.dart';
import 'package:gpspro/theme/CustomColor.dart';

class CustomIcon extends CustomPainter {
  final String _label;
  final String _icon;

  CustomIcon(this._label, this._icon);

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

    IconData _icon;
    if (this._icon == 'man') {
      _icon = Icons.directions_walk;
    } else if (this._icon == 'woman') {
      _icon = Icons.face;
    } else if (this._icon == 'pregnant') {
      _icon = Icons.pregnant_woman;
    } else if (this._icon == 'child') {
      _icon = Icons.child_care;
    } else if (this._icon == 'disability') {
      _icon = Icons.accessible;
    } else if (this._icon == 'pet') {
      _icon = Icons.pets;
    } else if (this._icon == 'car') {
      _icon = Icons.directions_car;
    } else if (this._icon == 'bike') {
      _icon = Icons.motorcycle;
    } else if (this._icon == 'truck') {
      _icon = Icons.local_shipping;
    } else if (this._icon == 'boat') {
      _icon = Icons.directions_boat;
    } else if (this._icon == 'marker') {
      _icon = Icons.pin_drop;
    } else {
      _icon = Icons.directions_walk;
    }
    TextPainter textPainter2 = TextPainter(textDirection: TextDirection.rtl);
    textPainter2.text = TextSpan(
        text: String.fromCharCode(_icon.codePoint),
        style: TextStyle(
            fontSize: 50.0,
            fontFamily: _icon.fontFamily,
            color: MAPS_IMAGES_COLOR));
    textPainter2.layout();
    textPainter2.paint(canvas,
        Offset(size.width / 2 - textPainter2.size.width / 2, size.height));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
