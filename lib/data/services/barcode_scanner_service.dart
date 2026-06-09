import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image/image.dart' as imglib;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum ScanMode {
  single,
  continuous,
}

class BarcodeScannerService {
  CameraController? cameraController;
  final BarcodeScanner _barcodeScanner = BarcodeScanner(formats: BarcodeFormat.values);
  
  bool _isInitialized = false;
  bool _isScanning = false;
  final StreamController<List<Barcode>> _barcodesController = StreamController<List<Barcode>>.broadcast();
  
  Stream<List<Barcode>> get barcodesStream => _barcodesController.stream;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final cameras = await availableCameras();
      
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }
      
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      
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
  
  Future<void> startScanning({
    required ScanMode scanMode,
    int scanInterval = 500,
  }) async {
    if (!_isInitialized || _isScanning) return;
    
    _isScanning = true;
    
    try {
      await cameraController!.startImageStream((CameraImage image) async {
        if (!_isScanning) return;
        
        _isScanning = false;
        
        try {
          final barcodes = await _processImage(image);
          
          if (barcodes.isNotEmpty) {
            _barcodesController.add(barcodes);
            
            if (scanMode == ScanMode.single) {
              await stopScanning();
              return;
            }
          }
          
          await Future.delayed(Duration(milliseconds: scanInterval));
          
          if (_isInitialized) {
            _isScanning = true;
          }
        } catch (e) {
          debugPrint('Error processing image: $e');
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
  Future<List<Barcode>> _processImage(CameraImage image) async {
    final inputImage = await _convertImageToInputImage(image, cameraController!.description);
    
    try {
      return await _barcodeScanner.processImage(inputImage);
    } catch (e) {
      debugPrint('Error in barcode scanning: $e');
      return [];
    }
  }
  Future<InputImage> _convertImageToInputImage(
    CameraImage image,
    CameraDescription cameraDescription,
  ) async {
    if (Platform.isAndroid) {
      return _processAndroidYuvImage(image, cameraDescription);
    } 
    else if (Platform.isIOS) {
      return _processIosImage(image, cameraDescription);
    }
    throw UnsupportedError('Unsupported platform for image conversion');
  }

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

    final metadata = InputImageMetadata(
      size: imageSize,
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  InputImage _processIosImage(
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
    
    final InputImageFormat format = InputImageFormat.bgra8888;

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

  InputImageRotation _getRotation(int sensorOrientation) {
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
    
    return InputImageRotation.rotation0deg;
  }
  
  void dispose() {
    stopScanning();
    _barcodesController.close();
    _barcodeScanner.close();
    cameraController?.dispose();
    _isInitialized = false;
  }
  
  Future<List<Barcode>> scanFromImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    return await _barcodeScanner.processImage(inputImage);
  }
  
  imglib.Image? convertToImage(CameraImage image) {
    try {
      if (image.format.group == ImageFormatGroup.yuv420) {
        return _convertYUV420ToImage(image);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        return _convertBGRA8888ToImage(image);
      }
      return null;
    } catch (e) {
      debugPrint("Error converting image: $e");
      return null;
    }
  }

  imglib.Image _convertYUV420ToImage(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    
    final imglib.Image rgbImage = imglib.Image(width: width, height: height);

    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex = uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int yIndex = (y * image.planes[0].bytesPerRow + x).toInt();
        final int y1 = image.planes[0].bytes[yIndex];
        
        final int u = image.planes[1].bytes[uvIndex];
        final int v = image.planes[2].bytes[uvIndex];

        int r = (y1 + 1.402 * (v - 128)).round().clamp(0, 255);
        int g = (y1 - 0.344136 * (u - 128) - 0.714136 * (v - 128)).round().clamp(0, 255);
        int b = (y1 + 1.772 * (u - 128)).round().clamp(0, 255);
        rgbImage.setPixelRgb(x, y, r, g, b);
      }
    }

    return rgbImage;
  }

  imglib.Image _convertBGRA8888ToImage(CameraImage image) {
    final Uint8List bytes = image.planes[0].bytes;
    final int bytesPerRow = image.planes[0].bytesPerRow;
    
    final imglib.Image img = imglib.Image(
      width: image.width, 
      height: image.height,
    );
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final int bgraIndex = y * bytesPerRow + x * 4;
        
        final int b = bytes[bgraIndex];
        final int g = bytes[bgraIndex + 1];
        final int r = bytes[bgraIndex + 2];
        
        img.setPixelRgb(x, y, r, g, b);
      }
    }
    
    return img;
  }

  Future<List<Barcode>> processImage(
    CameraImage image,
    CameraDescription cameraDescription,
    BarcodeScanner barcodeScanner
  ) async {
    final inputImage = await _convertImageToInputImage(image, cameraDescription);
    
    try {
      return await barcodeScanner.processImage(inputImage);
    } catch (e) {
      debugPrint('Error in barcode scanning: $e');
      return [];
    }
  }
}