import 'package:flutter/material.dart';

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({
    super.key,
    this.borderColor = Colors.green,
    this.borderWidth = 3.0,
    this.borderRadius = 12.0,
    this.cutOutWidth = 300.0,
    this.cutOutHeight = 200.0,
    this.overlayColor = const Color(0x99000000),
  });

  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double cutOutWidth;
  final double cutOutHeight;
  final Color overlayColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScannerOverlayPainter(
        cutOutWidth: cutOutWidth,
        cutOutHeight: cutOutHeight,
        borderColor: borderColor,
        borderWidth: borderWidth,
        borderRadius: borderRadius,
        overlayColor: overlayColor,
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  const _ScannerOverlayPainter({
    required this.cutOutWidth,
    required this.cutOutHeight,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.overlayColor,
  });

  final double cutOutWidth;
  final double cutOutHeight;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final Color overlayColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = overlayColor,
    );

    final cx = size.width / 2;
    final cy = size.height / 2;
    final cutRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: cutOutWidth,
        height: cutOutHeight,
      ),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(cutRect, Paint()..blendMode = BlendMode.clear);

    canvas.restore();

    canvas.drawRRect(
      cutRect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );

    const cornerLength = 24.0;
    final p = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth + 1
      ..strokeCap = StrokeCap.round;

    final l = cutRect.left;
    final t = cutRect.top;
    final r = cutRect.right;
    final b = cutRect.bottom;

    canvas.drawLine(Offset(l, t + cornerLength), Offset(l, t), p);
    canvas.drawLine(Offset(l, t), Offset(l + cornerLength, t), p);

    canvas.drawLine(Offset(r - cornerLength, t), Offset(r, t), p);
    canvas.drawLine(Offset(r, t), Offset(r, t + cornerLength), p);

    canvas.drawLine(Offset(r, b - cornerLength), Offset(r, b), p);
    canvas.drawLine(Offset(r, b), Offset(r - cornerLength, b), p);

    canvas.drawLine(Offset(l + cornerLength, b), Offset(l, b), p);
    canvas.drawLine(Offset(l, b), Offset(l, b - cornerLength), p);
  }

  @override
  bool shouldRepaint(_ScannerOverlayPainter old) => false;
}
