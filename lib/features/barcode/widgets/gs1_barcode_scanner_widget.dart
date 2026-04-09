import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

enum ScanMode { single, continuous }

/// Central barcode scanner component that handles both 2D GS1 DataMatrix and GS1 Linear barcodes
class GS1BarcodeScannerWidget extends StatefulWidget {
  /// Callback when a valid GS1 barcode is detected
  final Function(String gs1ElementString) onGS1BarcodeDetected;
  
  /// Scanning mode (single or continuous)
  final ScanMode scanMode;
  
  /// Whether to show the scanning overlay
  final bool showOverlay;
  
  /// Color of the scanning overlay
  final Color overlayColor;
  
  /// Custom widget to display when the camera is initializing
  final Widget? loadingWidget;
  
  /// Custom widget to display when there's an error
  final Widget? errorWidget;

  const GS1BarcodeScannerWidget({
    Key? key,
    required this.onGS1BarcodeDetected,
    this.scanMode = ScanMode.single,
    this.showOverlay = true,
    this.overlayColor = Colors.green,
    this.loadingWidget,
    this.errorWidget,
  }) : super(key: key);

  @override
  State<GS1BarcodeScannerWidget> createState() => _GS1BarcodeScannerWidgetState();
}

class _GS1BarcodeScannerWidgetState extends State<GS1BarcodeScannerWidget> with WidgetsBindingObserver {
  CameraController? _cameraController;
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _isInitialized = false;
  bool _isProcessing = false;
  String? _errorMessage;
  List<Rect> _barcodeLocations = [];
  bool _flashEnabled = false;
  List<CameraDescription>? _cameras;
  CameraLensDirection _currentLensDirection = CameraLensDirection.back;
  bool _isPlatformSupported = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPlatformAndInitialize();
  }
  
  void _checkPlatformAndInitialize() {
    // Check if running on a supported platform (Android or iOS)
    if (kIsWeb) {
      setState(() {
        _errorMessage = 'Camera scanning is not supported on web platform';
        _isPlatformSupported = false;
      });
    } else if (defaultTargetPlatform == TargetPlatform.android || 
               defaultTargetPlatform == TargetPlatform.iOS) {
      _isPlatformSupported = true;
      _initializeCamera();
    } else {
      setState(() {
        _errorMessage = 'Camera scanning is not supported on ${defaultTargetPlatform.toString()}';
        _isPlatformSupported = false;
      });
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available';
        });
        return;
      }

      // Use the back camera
      final camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == _currentLensDirection,
        orElse: () => _cameras!.first,
      );

      // Initialize camera controller with medium resolution for better performance
      // on laptops and other devices
      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium, // Using medium instead of high for better performance
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      // Initialize the camera
      await _cameraController!.initialize();

      // Improve visibility in low light conditions
      try {
        // Set auto focus mode for better barcode detection
        await _cameraController!.setFocusMode(FocusMode.auto);
      } catch (e) {
        debugPrint('Focus mode not supported on this device: $e');
        // Continue without setting focus mode
      }

      try {
        // Increase exposure for better visibility in low light
        await _cameraController!.setExposureOffset(1.5);
      } catch (e) {
        debugPrint('Setting exposure not supported on this device: $e');
        // Continue without setting exposure
      }

      // Enable flash automatically in low light on laptops (which often have poor cameras)
      try {
        if (_currentLensDirection == CameraLensDirection.front) {
          await _cameraController!.setFlashMode(FlashMode.torch);
          _flashEnabled = true;
        }
      } catch (e) {
        debugPrint('Flash control not supported: $e');
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        
        // Start image stream for barcode scanning
        _startBarcodeScanning();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  void _startBarcodeScanning() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    _cameraController!.startImageStream((CameraImage image) {
      if (_isProcessing) {
        return;
      }

      _isProcessing = true;
      _processImage(image);
    });
  }
  Future<void> _processImage(CameraImage image) async {
    try {
      // Use simpler image processing approach
      final InputImage inputImage = _inputImageFromCameraImage(image);
        // InputImage is never null with the new implementation

      // Process the image and detect barcodes
      final barcodes = await _barcodeScanner.processImage(inputImage);

      // Process detected barcodes
      if (barcodes.isNotEmpty) {
        _handleDetectedBarcodes(barcodes);
      }
    } catch (e) {
      // Error processing the image
      debugPrint('Error processing image: $e');
    } finally {
      _isProcessing = false;
    }
  }
  
  InputImage _inputImageFromCameraImage(CameraImage image) {
    // Get camera rotation
    final rotation = InputImageRotationValue.fromRawValue(
      _cameraController!.description.sensorOrientation,
    ) ?? InputImageRotation.rotation0deg;

    // Return InputImage
    return InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }
  
  void _handleDetectedBarcodes(List<Barcode> barcodes) {
    // Update overlay bounding boxes
    if (widget.showOverlay && mounted) {
      setState(() {        _barcodeLocations = barcodes
          .map((barcode) => barcode.boundingBox)
          .toList();
      });
    }

    // Process the first valid barcode
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final rawValue = barcode.rawValue!;
        
        // Get the GS1 element string and pass it back
        final gs1ElementString = _processRawBarcode(rawValue);
        if (gs1ElementString != null) {
          _handleValidGS1Barcode(gs1ElementString);
          break;
        }
      }
    }
  }
  
  String? _processRawBarcode(String rawValue) {
    // If it's already in GS1 element string format, return it
    if (rawValue.contains(RegExp(r'\(\d{2,4}\)'))) {
      return rawValue;
    }
    
    // Try to convert the raw value to GS1 element string format
    // This is a simple implementation - in a real app, you might need more complex parsing logic
    
    // Example: Convert a GTIN-14 to GS1 format
    if (rawValue.length == 14 && RegExp(r'^\d{14}$').hasMatch(rawValue)) {
      return "(01)$rawValue";
    }
    
    // For demo purposes, we'll just wrap unknown values
    return "(99)$rawValue";
  }
  
  void _handleValidGS1Barcode(String gs1ElementString) {
    // Pause scanning if in single scan mode
    if (widget.scanMode == ScanMode.single) {
      _cameraController?.stopImageStream();
    }
    
    // Notify the parent widget
    widget.onGS1BarcodeDetected(gs1ElementString);
  }

  void toggleFlash() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final newMode = _flashEnabled ? FlashMode.off : FlashMode.torch;
        await _cameraController!.setFlashMode(newMode);
        setState(() {
          _flashEnabled = !_flashEnabled;
        });
      } catch (e) {
        // Flash might not be supported on this device
        debugPrint('Flash control not supported: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Flash mode not supported on this device'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void toggleCamera() async {
    // Switch camera direction
    _currentLensDirection = _currentLensDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    
    // Stop the current camera stream
    await _cameraController?.stopImageStream();
    await _cameraController?.dispose();
    
    // Reinitialize with the new camera
    setState(() {
      _isInitialized = false;
      _flashEnabled = false;
    });
    
    // Initialize the new camera
    await _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes to properly manage camera resources
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _cameraController?.stopImageStream();
    } else if (state == AppLifecycleState.resumed) {
      _startBarcodeScanning();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _barcodeScanner.close();
    _cameraController?.dispose();
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
              const SizedBox(height: 24),
              
              // Only show for platform compatibility issues
              if (!_isPlatformSupported)
                Column(
                  children: [
                    const Text(
                      'You can use the manual barcode input option instead:',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Notify with a sample barcode for testing
                        widget.onGS1BarcodeDetected('(01)12345678901234(10)ABC123');
                      },
                      child: const Text('Use Sample GS1 Barcode'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'OR',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Use the keyboard icon in the upper right to enter a barcode manually',
                      textAlign: TextAlign.center,
                    ),
                  ],
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
          child: CameraPreview(_cameraController!),
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

        // Flash toggle button
        Positioned(
          top: 20,
          right: 20,
          child: IconButton(
            icon: Icon(
              _flashEnabled ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
              size: 32,
            ),
            onPressed: toggleFlash,
          ),
        ),

        // Camera switch button
        Positioned(
          top: 20,
          left: 20,
          child: IconButton(
            icon: Icon(
              _currentLensDirection == CameraLensDirection.back 
                ? Icons.camera_front 
                : Icons.camera_rear,
              color: Colors.white,
              size: 32,
            ),
            onPressed: toggleCamera,
          ),
        ),

        // Low-light indicator and helper message when using front camera
        if (_currentLensDirection == CameraLensDirection.front)
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Front camera active - Ensure good lighting',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
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
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant BarcodePainter oldDelegate) {
    return oldDelegate.barcodeLocations != barcodeLocations || 
           oldDelegate.color != color;
  }
}
