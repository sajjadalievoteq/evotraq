import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/barcode/widgets/gs1_barcode_scanner_widget.dart';
import 'package:traqtrace_app/shared/models/scan_result.dart';

/// Wrapper widget for barcode scanning that provides a simplified interface
/// for operational screens like shipping, receiving, etc.
class BarcodeScanner extends StatefulWidget {
  /// Callback when a barcode is successfully scanned
  final Function(ScanResult) onScanResult;
  
  /// List of allowed barcode formats (e.g., ['SGTIN', 'SSCC'])
  final List<String> allowedFormats;
  
  /// Whether to show the camera preview
  final bool showPreview;
  
  /// Height of the scanner component
  final double? height;
  
  /// Whether to automatically validate GS1 formats
  final bool validateGS1;

  const BarcodeScanner({
    Key? key,
    required this.onScanResult,
    this.allowedFormats = const [],
    this.showPreview = true,
    this.height,
    this.validateGS1 = true,
  }) : super(key: key);

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  bool _isScanning = true;

  void _onBarcodeDetected(String gs1ElementString) {
    if (!_isScanning) return;

    // Basic validation of the scanned data
    if (gs1ElementString.isEmpty) {
      widget.onScanResult(ScanResult.error(
        data: gs1ElementString,
        error: 'Empty barcode data',
      ));
      return;
    }

    // Determine barcode type based on GS1 element string
    String? barcodeType;
    if (widget.validateGS1) {
      barcodeType = _determineGS1BarcodeType(gs1ElementString);
      
      // Check if the barcode type is in allowed formats
      if (widget.allowedFormats.isNotEmpty && 
          (barcodeType == null || !widget.allowedFormats.contains(barcodeType))) {
        widget.onScanResult(ScanResult.error(
          data: gs1ElementString,
          error: 'Barcode type not allowed: ${barcodeType ?? 'Unknown'}',
        ));
        return;
      }
    }

    // Create successful scan result
    widget.onScanResult(ScanResult.success(
      data: gs1ElementString,
      barcodeType: barcodeType,
      metadata: {
        'timestamp': DateTime.now().toIso8601String(),
        'validated': widget.validateGS1,
      },
    ));
  }

  String? _determineGS1BarcodeType(String gs1Data) {
    try {
      // Basic GS1 detection logic
      if (gs1Data.startsWith('01')) {
        // GTIN detected
        if (gs1Data.contains('21')) {
          return 'SGTIN'; // Serial GTIN
        }
        return 'GTIN';
      } else if (gs1Data.startsWith('00')) {
        return 'SSCC'; // Serial Shipping Container Code
      } else if (gs1Data.startsWith('414') || gs1Data.startsWith('415')) {
        return 'GLN'; // Global Location Number
      } else if (gs1Data.startsWith('8003') || gs1Data.startsWith('8004')) {
        return 'GIAI'; // Global Individual Asset Identifier
      }
      
      return 'UNKNOWN';
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scanner controls
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _isScanning ? 'Scanning...' : 'Scanner paused',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Switch(
                value: _isScanning,
                onChanged: (value) {
                  setState(() => _isScanning = value);
                },
              ),
            ],
          ),
        ),
        
        // Scanner component
        if (widget.showPreview)
          Container(
            height: widget.height ?? 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _isScanning
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: GS1BarcodeScannerWidget(
                      onGS1BarcodeDetected: _onBarcodeDetected,
                      scanMode: ScanMode.continuous,
                      showOverlay: true,
                      overlayColor: Colors.green,
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Scanner paused',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          
        // Format info
        if (widget.allowedFormats.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Allowed formats: ${widget.allowedFormats.join(', ')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}