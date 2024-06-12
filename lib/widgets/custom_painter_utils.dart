import 'package:flutter/material.dart';

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  final ImageStream imageStream;
  ImageInfo? _imageInfo;

  DrawingPainter(this.points, this.imageStream) {
    imageStream.addListener(ImageStreamListener((ImageInfo info, bool _) {
      _imageInfo = info;
    }));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_imageInfo != null) {
      final Rect imageRect = Offset.zero & size;
      paintImage(
        canvas: canvas,
        rect: imageRect,
        image: _imageInfo!.image,
        fit: BoxFit.cover,
      );
    }

    Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
