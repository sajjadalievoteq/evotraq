import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/barcode/widgets/gs1_barcode_scanner_widget.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';
import 'package:traqtrace_app/core/di/injection.dart';

import '../../../data/services/gs1_barcode_api_service.dart';

/// Callback type for when a GS1 barcode is successfully scanned
///
/// Provides:
/// - gs1ElementString: The normalized GS1 element string format
/// - parsedBarcode: Map containing both raw barcode and parsed fields
/// - verificationResult: Optional backend verification result (if verifyWithBackend=true)
typedef GS1BarcodeCallback =
    void Function(
      String gs1ElementString,
      Map<String, dynamic> parsedBarcode,
      Map<String, dynamic>? verificationResult,
    );

/// Central GS1 barcode scanner screen
/// This is the main entry point for all scanning functionality in the app
class GS1BarcodeScannerScreen extends StatefulWidget {
  /// Optional title to display on the screen
  final String? title;

  /// Callback when a valid GS1 barcode is detected
  final GS1BarcodeCallback onBarcodeDetected;

  /// Whether to verify the barcode with the backend API
  final bool verifyWithBackend;

  /// Whether to scan continuously or stop after first detection
  final ScanMode scanMode;

  const GS1BarcodeScannerScreen({
    Key? key,
    this.title,
    required this.onBarcodeDetected,
    this.verifyWithBackend = true,
    this.scanMode = ScanMode.single,
  }) : super(key: key);

  @override
  State<GS1BarcodeScannerScreen> createState() =>
      _GS1BarcodeScannerScreenState();
}

class _GS1BarcodeScannerScreenState extends State<GS1BarcodeScannerScreen> {
  late GS1BarcodeApiService _barcodeApiService;
  String? _lastScannedCode;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    // Initialize API service
    _barcodeApiService = getIt<GS1BarcodeApiService>();
  }

  Future<void> _handleBarcodeDetection(String gs1ElementString) async {
    if (_isProcessing) {
      return;
    }

    // Prevent duplicate scans in short succession
    if (_lastScannedCode == gs1ElementString) {
      return;
    }

    _lastScannedCode = gs1ElementString;
    _isProcessing = true;
    // Provide haptic feedback
    try {
      HapticFeedback.mediumImpact();
    } catch (e) {
      // Ignore haptic feedback errors
    }

    try {
      setState(() {
        _errorMessage = null;
      });

      // Parse the barcode locally first
      final parsedBarcode = GS1BarcodeParser.parseGS1Barcode(gs1ElementString);

      // Display debug info
      debugPrint('Parsed GS1 barcode: $parsedBarcode');

      if (widget.verifyWithBackend && parsedBarcode['valid'] == true) {
        // Verify the barcode with the backend
        final result = await _barcodeApiService.verifyGS1Barcode(
          gs1ElementString,
        );

        // Call the callback with the raw code, parsed data, and verification result
        widget.onBarcodeDetected(gs1ElementString, parsedBarcode, result);
      } else {
        // Skip verification and just return the raw code and parsed data
        widget.onBarcodeDetected(gs1ElementString, parsedBarcode, null);
      }

      // If in single scan mode, go back automatically
      if (widget.scanMode == ScanMode.single) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to verify barcode: $e';
      });
    } finally {
      _isProcessing = false;

      // Reset last scanned code after a delay to allow for new scans
      Future.delayed(const Duration(seconds: 2), () {
        _lastScannedCode = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Scan GS1 Barcode'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          // Barcode scanner widget
          GS1BarcodeScannerWidget(
            onGS1BarcodeDetected: _handleBarcodeDetection,
            scanMode: widget.scanMode,
          ),

          // Loading indicator
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),

          // Error message
          if (_errorMessage != null)
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
