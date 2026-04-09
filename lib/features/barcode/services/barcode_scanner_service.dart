import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image/image.dart' as imglib;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Import for Size class

// Enum for different scanning modes
enum ScanMode {
  single,     // Scan a single barcode and stop
  continuous, // Continuously scan barcodes
}

/// Service that handles the processing of camera frames for barcode detection
class BarcodeScannerService {
  CameraController? cameraController;
  final BarcodeScanner _barcodeScanner = BarcodeScanner(formats: BarcodeFormat.values);
  
  bool _isInitialized = false;
  bool _isScanning = false;
  final StreamController<List<Barcode>> _barcodesController = StreamController<List<Barcode>>.broadcast();
  
  // Public stream that emits detected barcodes
  Stream<List<Barcode>> get barcodesStream => _barcodesController.stream;
  
  // Initialize the camera and barcode scanner
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final cameras = await availableCameras();
      
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }
      
      // Use the first back camera by default
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      
      // Initialize the camera with appropriate resolution
      cameraController = CameraController(
        camera,
        ResolutionPreset.high, 
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      
      await cameraController!.initialize();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      rethrow;
    }
  }
  
  // Start scanning for barcodes
  Future<void> startScanning({
    required ScanMode scanMode,
    int scanInterval = 500, // Milliseconds between scans
  }) async {
    if (!_isInitialized || _isScanning) return;
    
    _isScanning = true;
    
    try {
      // Set up image stream for barcode detection
      await cameraController!.startImageStream((CameraImage image) async {
        if (!_isScanning) return;
        
        // Throttle processing to avoid excessive CPU usage
        _isScanning = false;
        
        try {
          final barcodes = await _processImage(image);
          
          // If we found barcodes, emit them
          if (barcodes.isNotEmpty) {
            _barcodesController.add(barcodes);
            
            // If single scan mode, stop scanning after finding a barcode
            if (scanMode == ScanMode.single) {
              await stopScanning();
              return;
            }
          }
          
          // Delay before processing next frame
          await Future.delayed(Duration(milliseconds: scanInterval));
          
          if (_isInitialized) {
            _isScanning = true;
          }
        } catch (e) {
          debugPrint('Error processing image: $e');
          // Continue scanning despite errors
          await Future.delayed(Duration(milliseconds: scanInterval));
          if (_isInitialized) {
            _isScanning = true;
          }
        }
      });
    } catch (e) {
      debugPrint('Error starting image stream: $e');
      _isScanning = false;
      rethrow;
    }
  }
  
  // Stop scanning for barcodes
  Future<void> stopScanning() async {
    _isScanning = false;
    
    try {
      if (_isInitialized && cameraController!.value.isStreamingImages) {
        await cameraController!.stopImageStream();
      }
    } catch (e) {
      debugPrint('Error stopping image stream: $e');
    }
  }
    // Process the camera image to find barcodes
  Future<List<Barcode>> _processImage(CameraImage image) async {
    // Convert CameraImage to InputImage for ML Kit
    final inputImage = await _convertImageToInputImage(image, cameraController!.description);
    
    // Process the image with ML Kit barcode scanner
    try {
      return await _barcodeScanner.processImage(inputImage);
    } catch (e) {
      debugPrint('Error in barcode scanning: $e');
      return [];
    }
  }
    /// Converts a CameraImage to the InputImage format required by ML Kit
  Future<InputImage> _convertImageToInputImage(
    CameraImage image,
    CameraDescription cameraDescription,
  ) async {
    // For Android YUV_420_888 format
    if (Platform.isAndroid) {
      return _processAndroidYuvImage(image, cameraDescription);
    } 
    // For iOS we need to process a different format
    else if (Platform.isIOS) {
      return _processIosImage(image, cameraDescription);
    }
    throw UnsupportedError('Unsupported platform for image conversion');
  }

  /// Processes an Android YUV_420_888 image format for ML Kit
  InputImage _processAndroidYuvImage(
    CameraImage image,
    CameraDescription cameraDescription,
  ) {
    final WriteBuffer allBytes = WriteBuffer();
    
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final InputImageRotation rotation = _getRotation(cameraDescription.sensorOrientation);
    final InputImageFormat format = InputImageFormatValue.fromRawValue(image.format.raw) ?? 
                                   InputImageFormat.nv21;

    // Create platform-specific options for Android
    final metadata = InputImageMetadata(
      size: imageSize,
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  /// Processes an iOS image format for ML Kit
  InputImage _processIosImage(
    CameraImage image,
    CameraDescription cameraDescription,
  ) {
    // Convert BGRA (iOS camera format) to InputImage
    final WriteBuffer allBytes = WriteBuffer();
    
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    
    final bytes = allBytes.done().buffer.asUint8List();
    
    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final InputImageRotation rotation = _getRotation(cameraDescription.sensorOrientation);
    
    // For iOS, typically BGRA8888
    final InputImageFormat format = InputImageFormat.bgra8888;

    // Create platform-specific options for iOS
    final metadata = InputImageMetadata(
      size: imageSize,
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: metadata,
    );
  }

  /// Gets the appropriate InputImageRotation based on device orientation and camera sensor orientation
  InputImageRotation _getRotation(int sensorOrientation) {
    // Default to portrait up
    final rotationCompensation = sensorOrientation; 
    
    if (rotationCompensation == 0) {
      return InputImageRotation.rotation0deg;
    } else if (rotationCompensation == 90) {
      return InputImageRotation.rotation90deg;
    } else if (rotationCompensation == 180) {
      return InputImageRotation.rotation180deg;
    } else if (rotationCompensation == 270) {
      return InputImageRotation.rotation270deg;
    }
    
    // Default to no rotation
    return InputImageRotation.rotation0deg;
  }
  
  // Clean up resources
  void dispose() {
    stopScanning();
    _barcodesController.close();
    _barcodeScanner.close();
    cameraController?.dispose();
    _isInitialized = false;
  }
  
  // Method to scan a barcode from gallery image
  Future<List<Barcode>> scanFromImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    return await _barcodeScanner.processImage(inputImage);
  }
  
  /// Converts an image to a format that can be displayed on screen (for debugging)
  imglib.Image? convertToImage(CameraImage image) {
    try {
      if (image.format.group == ImageFormatGroup.yuv420) {
        // Handle YUV420 format
        return _convertYUV420ToImage(image);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        // Handle BGRA8888 format
        return _convertBGRA8888ToImage(image);
      }
      return null;
    } catch (e) {
      debugPrint("Error converting image: $e");
      return null;
    }
  }

  /// Converts YUV420 format to RGB Image
  imglib.Image _convertYUV420ToImage(CameraImage image) {
    // Get image dimensions
    final int width = image.width;
    final int height = image.height;
    
    // Allocate memory for RGB output
    final imglib.Image rgbImage = imglib.Image(width: width, height: height);

    // Process each pixel
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex = uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
          // Y plane (luminance)
        final int yIndex = (y * image.planes[0].bytesPerRow + x).toInt();
        final int y1 = image.planes[0].bytes[yIndex];
        
        // U and V planes (chrominance)
        final int u = image.planes[1].bytes[uvIndex];
        final int v = image.planes[2].bytes[uvIndex];

        // Convert YUV to RGB
        int r = (y1 + 1.402 * (v - 128)).round().clamp(0, 255);
        int g = (y1 - 0.344136 * (u - 128) - 0.714136 * (v - 128)).round().clamp(0, 255);
        int b = (y1 + 1.772 * (u - 128)).round().clamp(0, 255);        // Set the RGB pixel in our output image
        rgbImage.setPixelRgb(x, y, r, g, b);
      }
    }

    return rgbImage;
  }

  /// Converts BGRA8888 format to RGB Image
  imglib.Image _convertBGRA8888ToImage(CameraImage image) {
    // Get plane data
    final Uint8List bytes = image.planes[0].bytes;
    final int bytesPerRow = image.planes[0].bytesPerRow;
    
    // Create output image with same dimensions
    final imglib.Image img = imglib.Image(
      width: image.width, 
      height: image.height,
    );
      // Convert BGRA to RGB
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        // BGRA is 4 bytes per pixel
        final int bgraIndex = y * bytesPerRow + x * 4;
        
        // Convert BGRA order to RGB
        final int b = bytes[bgraIndex];
        final int g = bytes[bgraIndex + 1];
        final int r = bytes[bgraIndex + 2];
        
        // Set the RGB pixel in our output image
        img.setPixelRgb(x, y, r, g, b);
      }
    }
    
    return img;
  }

  /// Process a camera image to detect barcodes with an external barcode scanner
  Future<List<Barcode>> processImage(
    CameraImage image,
    CameraDescription cameraDescription,
    BarcodeScanner barcodeScanner
  ) async {
    // Convert CameraImage to InputImage
    final inputImage = await _convertImageToInputImage(image, cameraDescription);
    
    // Process with provided barcode scanner
    try {
      return await barcodeScanner.processImage(inputImage);
    } catch (e) {
      debugPrint('Error in barcode scanning: $e');
      return [];
    }
  }
}