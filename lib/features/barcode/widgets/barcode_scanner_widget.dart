import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import '../services/barcode_scanner_service.dart';

class BarcodeScannerWidget extends StatefulWidget {
  final Function(List<Barcode> barcodes) onBarcodeDetected;
  final ScanMode scanMode;
  final bool showOverlay;
  final Color overlayColor;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const BarcodeScannerWidget({
    Key? key,
    required this.onBarcodeDetected,
    this.scanMode = ScanMode.single,
    this.showOverlay = true,
    this.overlayColor = Colors.green,
    this.loadingWidget,
    this.errorWidget,
  }) : super(key: key);

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> with WidgetsBindingObserver {
  final BarcodeScannerService _scannerService = BarcodeScannerService();
  bool _isInitialized = false;
  String? _errorMessage;
  List<Rect> _barcodeLocations = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScanner();
  }

  Future<void> _initializeScanner() async {
    try {
      await _scannerService.initialize();
      
      // Listen for barcode detection events
      _scannerService.barcodesStream.listen(_handleBarcodeDetection);
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _errorMessage = null;
        });
        
        // Start scanning after initialization
        await _scannerService.startScanning(scanMode: widget.scanMode);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize camera: $e';
        });
      }
    }
  }

  void _handleBarcodeDetection(List<Barcode> barcodes) {
    // Update overlay bounding boxes
    if (widget.showOverlay && mounted) {
      setState(() {
        _barcodeLocations = barcodes.map((barcode) {
          return barcode.boundingBox ?? Rect.zero;
        }).toList();
      });
    }

    // Notify parent widget about barcode detection
    widget.onBarcodeDetected(barcodes);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes to properly manage camera resources
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _scannerService.stopScanning();
    } else if (state == AppLifecycleState.resumed) {
      if (_isInitialized) {
        _scannerService.startScanning(scanMode: widget.scanMode);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return widget.errorWidget ?? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Camera Error',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return widget.loadingWidget ?? const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        // Camera preview
        SizedBox.expand(
          child: CameraPreview(_scannerService.cameraController!),
        ),

        // Scanning overlay (barcode locations)
        if (widget.showOverlay)
          CustomPaint(
            size: Size.infinite,
            painter: BarcodePainter(
              barcodeLocations: _barcodeLocations,
              color: widget.overlayColor,
            ),
          ),

        // Scanning guide
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 3.0,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Scanning indicator
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Align barcode within the frame',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter for rendering barcode location overlays
class BarcodePainter extends CustomPainter {
  final List<Rect> barcodeLocations;
  final Color color;

  BarcodePainter({
    required this.barcodeLocations,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Draw rectangles around detected barcodes
    for (final rect in barcodeLocations) {
      if (rect != Rect.zero) {
        // Scale barcode coordinates to match screen size
        final scaleX = size.width / rect.width;
        final scaleY = size.height / rect.height;
        
        final scaledRect = Rect.fromLTRB(
          rect.left * scaleX,
          rect.top * scaleY,
          rect.right * scaleX,
          rect.bottom * scaleY,
        );
        
        canvas.drawRect(scaledRect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant BarcodePainter oldDelegate) {
    return oldDelegate.barcodeLocations != barcodeLocations || 
           oldDelegate.color != color;
  }
}