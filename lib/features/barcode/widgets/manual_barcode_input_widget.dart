import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';

/// A manual barcode input widget for platforms that don't support camera
class ManualBarcodeInputWidget extends StatefulWidget {
  /// Callback when a valid GS1 barcode is entered
  final Function(String gs1ElementString) onGS1BarcodeDetected;
  
  /// Optional color theme
  final Color themeColor;

  const ManualBarcodeInputWidget({
    Key? key,
    required this.onGS1BarcodeDetected,
    this.themeColor = Colors.blue,
  }) : super(key: key);

  @override
  State<ManualBarcodeInputWidget> createState() => _ManualBarcodeInputWidgetState();
}

class _ManualBarcodeInputWidgetState extends State<ManualBarcodeInputWidget> {
  final TextEditingController _barcodeController = TextEditingController();
  String? _errorMessage;
  Map<String, dynamic>? _previewData;
  bool _isLoading = false;

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  void _processBarcode() {
    final input = _barcodeController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a barcode';
        _previewData = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Use local parser
    try {
      final result = GS1BarcodeParser.parseGS1Barcode(input);
      
      setState(() {
        _isLoading = false;
        if (result['valid'] == true) {
          _previewData = result;
          _errorMessage = null;
        } else {
          _errorMessage = 'Invalid GS1 format. Try adding parentheses with AI numbers: (01)12345678901234';
          _previewData = null;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
        _previewData = null;
      });
    }
  }

  void _submitBarcode() {
    if (_previewData != null && _previewData!['valid'] == true) {
      widget.onGS1BarcodeDetected(_previewData!['gs1ElementString']);
    } else {
      _processBarcode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Manual GS1 Barcode Entry',
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            'Camera scanning is not available on this platform.\nPlease enter a GS1 barcode manually:',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Barcode input field
          TextField(
            controller: _barcodeController,
            decoration: InputDecoration(
              labelText: 'Enter GS1 Barcode',
              hintText: 'e.g. (01)12345678901234(10)ABC123',
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _barcodeController.clear();
                  setState(() {
                    _previewData = null;
                    _errorMessage = null;
                  });
                },
              ),
            ),
            onSubmitted: (_) => _processBarcode(),
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _processBarcode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black87,
                ),
                child: const Text('Preview'),
              ),
              ElevatedButton(
                onPressed: _submitBarcode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.themeColor,
                ),
                child: const Text('Submit'),
              ),
              ElevatedButton(
                onPressed: () {
                  _barcodeController.text = '(01)12345678901234(10)ABC123';
                  _processBarcode();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black87,
                ),
                child: const Text('Sample'),
              ),
            ],
          ),
          
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            
          // Error message
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
            
          // Preview data
          if (_previewData != null && _previewData!['valid'] == true)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Barcode Preview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Raw GS1: ${_previewData!['gs1ElementString']}'),
                        const Divider(),
                        if (_previewData!.containsKey('humanReadable') && 
                            _previewData!['humanReadable'] is Map<String, dynamic>)
                          ...((_previewData!['humanReadable'] as Map<String, dynamic>)
                            .entries.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text('${entry.key}: ${entry.value}'),
                              ),
                            ))
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
          // Help section
          const Padding(
            padding: EdgeInsets.only(top: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GS1 Barcode Format Help',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'GS1 barcodes use Application Identifiers (AIs) in parentheses:',
                ),
                SizedBox(height: 4),
                Text('• (01) - GTIN (product identifier)'),
                Text('• (10) - Batch/Lot number'),
                Text('• (17) - Expiration date (YYMMDD)'),
                Text('• (21) - Serial number'),
                Text('Example: (01)12345678901234(17)250524(10)ABC123'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
