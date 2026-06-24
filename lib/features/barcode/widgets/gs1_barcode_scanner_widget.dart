import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:traqtrace_app/features/barcode/models/scan_mode.dart';
import 'package:traqtrace_app/features/barcode/widgets/scanner_overlay.dart';

/// Camera-based GS1 barcode scanner (DataMatrix + Code 128).
class GS1BarcodeScannerWidget extends StatefulWidget {
  const GS1BarcodeScannerWidget({
    super.key,
    required this.onGS1BarcodeDetected,
    this.scanMode = ScanMode.single,
    this.showOverlay = true,
    this.overlayColor = Colors.green,
    this.loadingWidget,
    this.errorWidget,
  });

  final Function(String gs1ElementString) onGS1BarcodeDetected;
  final ScanMode scanMode;
  final bool showOverlay;
  final Color overlayColor;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  @override
  State<GS1BarcodeScannerWidget> createState() =>
      _GS1BarcodeScannerWidgetState();
}

class _GS1BarcodeScannerWidgetState extends State<GS1BarcodeScannerWidget>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  final BarcodeScanner _barcodeScanner = BarcodeScanner(
    formats: [BarcodeFormat.dataMatrix, BarcodeFormat.code128],
  );
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
        _errorMessage =
            'Camera scanning is not supported on ${defaultTargetPlatform.toString()}';
        _isPlatformSupported = false;
      });
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available';
        });
        return;
      }

      final camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == _currentLensDirection,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();

      try {
        await _cameraController!.setFocusMode(FocusMode.auto);
      } catch (e) {
        debugPrint('Focus mode not supported on this device: $e');
      }

      try {
        await _cameraController!.setExposureOffset(1.5);
      } catch (e) {
        debugPrint('Setting exposure not supported on this device: $e');
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
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
      if (_isProcessing) return;
      _isProcessing = true;
      _processImage(image);
    });
  }

  Future<void> _processImage(CameraImage image) async {
    try {
      final inputImage = _inputImageFromCameraImage(image);
      final barcodes = await _barcodeScanner.processImage(inputImage);
      if (barcodes.isNotEmpty) {
        _handleDetectedBarcodes(barcodes);
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
    } finally {
      _isProcessing = false;
    }
  }

  InputImage _inputImageFromCameraImage(CameraImage image) {
    final writeBuffer = WriteBuffer();
    for (final plane in image.planes) {
      writeBuffer.putUint8List(plane.bytes);
    }
    final bytes = writeBuffer.done().buffer.asUint8List();

    final rotation = InputImageRotationValue.fromRawValue(
          _cameraController!.description.sensorOrientation,
        ) ??
        InputImageRotation.rotation0deg;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  void _handleDetectedBarcodes(List<Barcode> barcodes) {
    if (widget.showOverlay && mounted) {
      setState(() {
        _barcodeLocations =
            barcodes.map((barcode) => barcode.boundingBox).toList();
      });
    }

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final gs1ElementString = _processRawBarcode(barcode.rawValue!);
        if (gs1ElementString != null) {
          _handleValidGS1Barcode(gs1ElementString);
          break;
        }
      }
    }
  }

  String? _processRawBarcode(String rawValue) {
    return rawValue.isNotEmpty ? rawValue : null;
  }

  void _handleValidGS1Barcode(String gs1ElementString) {
    if (widget.scanMode == ScanMode.single) {
      _cameraController?.stopImageStream();
      if (mounted) {
        setState(() {
          _barcodeLocations = [];
        });
      }
    }
    widget.onGS1BarcodeDetected(gs1ElementString);
  }

  Future<void> toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      final newMode = _flashEnabled ? FlashMode.off : FlashMode.torch;
      await _cameraController!.setFlashMode(newMode);
      setState(() {
        _flashEnabled = !_flashEnabled;
      });
    } catch (e) {
      debugPrint('Flash control not supported: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Flash mode not supported on this device'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> toggleCamera() async {
    _currentLensDirection = _currentLensDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    await _cameraController?.stopImageStream();
    await _cameraController?.dispose();

    setState(() {
      _isInitialized = false;
      _flashEnabled = false;
    });

    await _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
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
      return widget.errorWidget ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                  if (!_isPlatformSupported) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Use manual barcode entry instead.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          );
    }

    if (!_isInitialized) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        SizedBox.expand(child: CameraPreview(_cameraController!)),
        if (widget.showOverlay)
          CustomPaint(
            size: Size.infinite,
            painter: BarcodePainter(
              barcodeLocations: _barcodeLocations,
              color: widget.overlayColor,
            ),
          ),
        Positioned.fill(
          child: ScannerOverlay(
            borderColor: widget.overlayColor,
            cutOutWidth: 260,
            cutOutHeight: 200,
          ),
        ),
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
        if (_currentLensDirection == CameraLensDirection.front)
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
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

class BarcodePainter extends CustomPainter {
  const BarcodePainter({
    required this.barcodeLocations,
    required this.color,
  });

  final List<Rect> barcodeLocations;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (final rect in barcodeLocations) {
      if (rect != Rect.zero) {
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant BarcodePainter oldDelegate) {
    return !listEquals(oldDelegate.barcodeLocations, barcodeLocations) ||
        oldDelegate.color != color;
  }
}
