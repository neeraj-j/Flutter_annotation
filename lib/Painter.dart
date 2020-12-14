// This file im[lements the painter for annotations
import 'package:flutter/material.dart';



class ShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
	    var paint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, 20, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
