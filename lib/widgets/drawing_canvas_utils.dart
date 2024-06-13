import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:safify/widgets/custom_painter_utils.dart';

class DrawingCanvas extends StatefulWidget {
  final ImageStream imageStream;

  DrawingCanvas({required this.imageStream});

  @override
  _DrawingCanvasState createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  List<Offset?> points = [];
  ui.Image? _image;
  bool _isImageLoaded = false;
  DrawingPainter? drawingPainter;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    widget.imageStream.addListener(ImageStreamListener((imageInfo, _) {
      setState(() {
        _image = imageInfo.image;
        _isImageLoaded = true;
      });
    }));
  }

  Future<ui.Image> _exportImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
        recorder,
        Rect.fromPoints(const Offset(0, 0),
            Offset(_image!.width.toDouble(), _image!.height.toDouble())));
    // Size imgSize = Size(_image!.width.toDouble(), _image!.height.toDouble());
    // drawingPainter?.paint(canvas, imgSize);
    // Draw the image
    final paint = Paint();

    canvas.drawImage(_image!, Offset.zero, paint);

    // Draw the points
    final drawPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, drawPaint);
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(_image!.width, _image!.height);
    return img;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Image'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _isImageLoaded
                ? () async {
                    final editedImage = await _exportImage();
                    Navigator.pop(context, editedImage);
                  }
                : null,
          )
        ],
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final offset = renderBox.globalToLocal(details.localPosition);
            points.add(offset);
          });
        },
        onPanEnd: (details) {
          points.add(null); // Indicates end of drawing stroke
        },
        child: _isImageLoaded
            ? CustomPaint(
                size: Size(_image!.width.toDouble(), _image!.height.toDouble()),
                painter: DrawingPainter(points, widget.imageStream),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
