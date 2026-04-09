import 'package:flutter/material.dart';

/// Widget that displays a scanner overlay with a targeting rectangle
/// to help users position barcodes correctly for scanning
class ScannerOverlay extends StatelessWidget {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double cutOutWidth;
  final double cutOutHeight;
  final Color overlayColor;

  const ScannerOverlay({
    Key? key,
    this.borderColor = Colors.green,
    this.borderWidth = 3.0,
    this.borderRadius = 12.0,
    this.cutOutWidth = 300.0,
    this.cutOutHeight = 200.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background overlay - semi-transparent
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            overlayColor,
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
                child: CustomPaint(
                  painter: _OverlayPainter(
                    cutOutWidth: cutOutWidth,
                    cutOutHeight: cutOutHeight,
                    borderColor: borderColor,
                    borderWidth: borderWidth,
                    borderRadius: borderRadius,
                  ),
                  child: Container(),
                ),
              ),
            ],
          ),
        ),
        
        // Corner markers
        Center(
          child: Container(
            width: cutOutWidth,
            height: cutOutHeight,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.transparent),
            ),
            child: Stack(
              children: [
                // Top left corner
                Positioned(
                  left: 0,
                  top: 0,
                  child: _buildCorner(true, true),
                ),
                // Top right corner
                Positioned(
                  right: 0,
                  top: 0,
                  child: _buildCorner(false, true),
                ),
                // Bottom left corner
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: _buildCorner(true, false),
                ),
                // Bottom right corner
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _buildCorner(false, false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCorner(bool isLeft, bool isTop) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          left: isLeft
              ? BorderSide(color: borderColor, width: borderWidth)
              : BorderSide.none,
          top: isTop
              ? BorderSide(color: borderColor, width: borderWidth)
              : BorderSide.none,
          right: !isLeft
              ? BorderSide(color: borderColor, width: borderWidth)
              : BorderSide.none,
          bottom: !isTop
              ? BorderSide(color: borderColor, width: borderWidth)
              : BorderSide.none,
        ),
      ),
    );
  }
}

/// Custom painter for the scanner overlay
class _OverlayPainter extends CustomPainter {
  final double cutOutWidth;
  final double cutOutHeight;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;

  _OverlayPainter({
    required this.cutOutWidth,
    required this.cutOutHeight,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double rectLeft = centerX - (cutOutWidth / 2);
    final double rectTop = centerY - (cutOutHeight / 2);
    
    // Draw the transparent cutout rectangle
    final cutOutRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        rectLeft,
        rectTop,
        cutOutWidth,
        cutOutHeight,
      ),
      Radius.circular(borderRadius),
    );
    
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
      
    final cutOutPaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.clear;
      
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    
    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );
    
    // Draw cutout
    canvas.drawRRect(cutOutRect, cutOutPaint);
    
    // Draw border
    canvas.drawRRect(cutOutRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}