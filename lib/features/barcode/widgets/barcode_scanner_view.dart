import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../../../data/services/barcode_scanner_service.dart';

class BarcodeScannerView extends StatefulWidget {
  final ScanMode scanMode;
  final Function(List<Barcode> barcodes) onBarcodeDetected;
  final bool showOverlay;
  final bool showGuidelines;

  const BarcodeScannerView({
    Key? key,
    this.scanMode = ScanMode.continuous,
    required this.onBarcodeDetected,
    this.showOverlay = true,
    this.showGuidelines = true,
  }) : super(key: key);

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView> with WidgetsBindingObserver {
  final BarcodeScannerService _scannerService = BarcodeScannerService();
  List<Barcode> _barcodes = [];
  bool _isCameraInitialized = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes to properly manage camera resources
    switch (state) {
      case AppLifecycleState.resumed:
        _resumeCamera();
        break;
      case AppLifecycleState.paused:
        _pauseCamera();
        break;
      default:
        break;
    }
  }

  Future<void> _initializeCamera() async {
    try {
      await _scannerService.initialize();
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }

      // Start listening for barcode detections
      _scannerService.barcodesStream.listen((barcodes) {
        if (mounted) {
          setState(() {
            _barcodes = barcodes;
          });
          widget.onBarcodeDetected(barcodes);
        }
      });

      // Start scanning
      await _startScanning();
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _startScanning() async {
    if (!_isScanning) {
      await _scannerService.startScanning(
        scanMode: widget.scanMode,
      );
      if (mounted) {
        setState(() {
          _isScanning = true;
        });
      }
    }
  }

  Future<void> _pauseCamera() async {
    await _scannerService.stopScanning();
    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _resumeCamera() async {
    await _startScanning();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // Camera view
        Center(
          child: CameraPreview(_scannerService.cameraController!),
        ),
        
        // Overlay for scanning area
        if (widget.showOverlay)
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: ScannerOverlay(
              scanWindow: Rect.fromCenter(
                center: MediaQuery.of(context).size.center(Offset.zero),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
        
        // Barcode marker rectangles
        if (_barcodes.isNotEmpty)
          CustomPaint(
            painter: BarcodeDetectionPainter(
              barcodes: _barcodes,
              absoluteImageSize: _scannerService.cameraController!.value.previewSize!,
              rotation: _scannerService.cameraController!.description.sensorOrientation,
              viewSize: MediaQuery.of(context).size,
            ),
          ),
        
        // Guidelines text
        if (widget.showGuidelines)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Text(
                'Center the barcode within the frame',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: const Offset(1, 1),
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ScannerOverlay extends CustomPainter {
  final Rect scanWindow;
  
  ScannerOverlay({required this.scanWindow});
  
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      
    final scanPath = Path()
      ..addRect(scanWindow);
      
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
      
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    // Corner decoration size
    final cornerSize = scanWindow.width * 0.1;
    
    // Draw background with scan window cut out
    canvas.drawPath(Path.combine(
      PathOperation.difference,
      backgroundPath,
      scanPath,
    ), backgroundPaint);
    
    // Draw border around scan window
    canvas.drawRect(scanWindow, borderPaint);
    
    // Draw corner decorations
    final cornersPath = Path();
    
    // Top left corner
    cornersPath.moveTo(scanWindow.left, scanWindow.top + cornerSize);
    cornersPath.lineTo(scanWindow.left, scanWindow.top);
    cornersPath.lineTo(scanWindow.left + cornerSize, scanWindow.top);
    
    // Top right corner
    cornersPath.moveTo(scanWindow.right - cornerSize, scanWindow.top);
    cornersPath.lineTo(scanWindow.right, scanWindow.top);
    cornersPath.lineTo(scanWindow.right, scanWindow.top + cornerSize);
    
    // Bottom right corner
    cornersPath.moveTo(scanWindow.right, scanWindow.bottom - cornerSize);
    cornersPath.lineTo(scanWindow.right, scanWindow.bottom);
    cornersPath.lineTo(scanWindow.right - cornerSize, scanWindow.bottom);
    
    // Bottom left corner
    cornersPath.moveTo(scanWindow.left + cornerSize, scanWindow.bottom);
    cornersPath.lineTo(scanWindow.left, scanWindow.bottom);
    cornersPath.lineTo(scanWindow.left, scanWindow.bottom - cornerSize);
    
    canvas.drawPath(cornersPath, Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0);
  }
  
  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) => 
      scanWindow != oldDelegate.scanWindow;
}

class BarcodeDetectionPainter extends CustomPainter {
  final List<Barcode> barcodes;
  final Size absoluteImageSize;
  final int rotation;
  final Size viewSize;

  BarcodeDetectionPainter({
    required this.barcodes,
    required this.absoluteImageSize,
    required this.rotation,
    required this.viewSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.greenAccent;

    for (final barcode in barcodes) {
      final Rect? boundingBox = barcode.boundingBox;
      if (boundingBox != null) {
        // Calculate scale ratios
        final double scaleX = viewSize.width / absoluteImageSize.height;
        final double scaleY = viewSize.height / absoluteImageSize.width;

        // Account for rotation (90 degrees for most phone cameras)
        final double translateX = viewSize.width - boundingBox.left * scaleX - boundingBox.height * scaleX;
        final double translateY = boundingBox.top * scaleY;

        final Rect scaledRect = Rect.fromLTWH(
          translateX,
          translateY,
          boundingBox.height * scaleX,
          boundingBox.width * scaleY,
        );

        canvas.drawRect(scaledRect, paint);

        // Add value as text
        final textPainter = TextPainter(
          text: TextSpan(
            text: barcode.displayValue, 
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout();
        textPainter.paint(
          canvas, 
          Offset(translateX, translateY - 20),
        );
      }
    }
  }

  @override
  bool shouldRepaint(BarcodeDetectionPainter oldDelegate) =>
      barcodes != oldDelegate.barcodes;
}
