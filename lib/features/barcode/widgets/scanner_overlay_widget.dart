import 'package:flutter/material.dart';

/// A widget that displays an overlay on top of the camera preview for barcode scanning
/// with a cutout in the center for the scan area
class ScannerOverlayWidget extends StatelessWidget {
  final double scanAreaSize;
  final double borderLength;
  final double borderWidth;
  final Color borderColor;
  final String? overlayText;
  final TextStyle? overlayTextStyle;
  final bool showScannerFrame;

  /// Creates a scanner overlay widget
  ///
  /// [scanAreaSize] defines the size of the cutout scan area
  /// [borderLength] defines the length of corner borders
  /// [borderWidth] defines the width of corner borders
  /// [borderColor] defines the color of corner borders
  /// [overlayText] optional text to display below the scan area
  /// [overlayTextStyle] style for the overlay text
  /// [showScannerFrame] whether to show the scanner frame
  const ScannerOverlayWidget({
    Key? key,
    this.scanAreaSize = 250.0,
    this.borderLength = 30.0,
    this.borderWidth = 5.0,
    this.borderColor = Colors.green,
    this.overlayText,
    this.overlayTextStyle,
    this.showScannerFrame = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent overlay covering the entire screen
        Container(
          color: Colors.black54,
        ),
        // Custom paint for the cutout and corner borders
        CustomPaint(
          painter: _ScannerOverlayPainter(
            scanAreaSize: scanAreaSize,
            borderLength: borderLength,
            borderWidth: borderWidth,
            borderColor: borderColor,
            showScannerFrame: showScannerFrame,
          ),
          child: const SizedBox.expand(),
        ),
        // Overlay text if provided
        if (overlayText != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.25,
            child: Text(
              overlayText!,
              textAlign: TextAlign.center,
              style: overlayTextStyle ?? 
                const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
            ),
          ),
      ],
    );
  }
}

/// Custom painter for drawing the scanner overlay
class _ScannerOverlayPainter extends CustomPainter {
  final double scanAreaSize;
  final double borderLength;
  final double borderWidth;
  final Color borderColor;
  final bool showScannerFrame;

  _ScannerOverlayPainter({
    required this.scanAreaSize,
    required this.borderLength,
    required this.borderWidth,
    required this.borderColor,
    required this.showScannerFrame,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    // Calculate center of the screen
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    
    // Calculate scan area rect
    final Rect scanRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: scanAreaSize,
      height: scanAreaSize,
    );

    // Draw a path that covers the whole screen except the scan area
    final Path overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(scanRect)
      ..fillType = PathFillType.evenOdd;
    
    canvas.drawPath(overlayPath, paint);

    if (showScannerFrame) {
      // Draw corner borders
      final Paint borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;

      // Top left corner
      canvas.drawPath(
        _getCornerPath(
          scanRect.left,
          scanRect.top,
          borderLength,
          borderLength,
          true,
          true,
        ),
        borderPaint,
      );

      // Top right corner
      canvas.drawPath(
        _getCornerPath(
          scanRect.right,
          scanRect.top,
          -borderLength,
          borderLength,
          true,
          false,
        ),
        borderPaint,
      );

      // Bottom right corner
      canvas.drawPath(
        _getCornerPath(
          scanRect.right,
          scanRect.bottom,
          -borderLength,
          -borderLength,
          false,
          false,
        ),
        borderPaint,
      );

      // Bottom left corner
      canvas.drawPath(
        _getCornerPath(
          scanRect.left,
          scanRect.bottom,
          borderLength,
          -borderLength,
          false,
          true,
        ),
        borderPaint,
      );
    }
  }

  /// Creates a path for a corner of the scan area frame
  Path _getCornerPath(
    double x,
    double y,
    double width,
    double height,
    bool isTop,
    bool isLeft,
  ) {
    final Path path = Path();
    
    // Start point
    path.moveTo(x, y + (isTop ? 0 : height));
    
    // First line (vertical)
    path.lineTo(x, y);
    
    // Second line (horizontal)
    path.lineTo(x + width, y);
    
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}