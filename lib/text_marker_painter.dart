// Copyright 2026 Stefan Schmidt
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TextMarkerPainter extends CustomPainter {
  final String text;
  final Color color;

  TextMarkerPainter(this.text, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw the background bubble
    final Paint paint = Paint()..color = color;
    final RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(10),
    );
    canvas.drawRRect(rRect, paint);

    // 2. Configure the text
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);

    // 3. Center the text in the box
    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Future<BitmapDescriptor> createCustomMarkerBitmap(String title, Color bgcolor) async {
  const ui.Size size = ui.Size(100, 100); // Define the canvas size
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);

  final painter = TextMarkerPainter(title, bgcolor);
  painter.paint(canvas, size);

  final ui.Image image = await pictureRecorder.endRecording().toImage(
    size.width.toInt(),
    size.height.toInt(),
  );

  final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List bytes = byteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(bytes);
}