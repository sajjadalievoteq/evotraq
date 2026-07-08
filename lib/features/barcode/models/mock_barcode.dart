import 'dart:typed_data';
import 'dart:math';
import 'dart:ui' show Rect;
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class MockBarcode implements Barcode {
  @override
  final String? rawValue;
  
  @override
  final BarcodeFormat format = BarcodeFormat.unknown;
  
  @override
  final String? displayValue = null;
  
  @override
  final List<Point<int>> cornerPoints = [];
  
  @override
  final Rect boundingBox = Rect.zero;
  
  @override
  final Uint8List? rawBytes = null;
  
  @override
  final BarcodeType type = BarcodeType.text;
  
  @override
  final BarcodeValue? value = null;
  
  MockBarcode(this.rawValue);
}
