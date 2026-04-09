import 'package:flutter/material.dart';
import '../screens/gs1_barcode_scanner_screen.dart';
import '../widgets/gs1_barcode_scanner_widget.dart';

class BarcodeExamplePage extends StatefulWidget {
  const BarcodeExamplePage({Key? key}) : super(key: key);

  @override
  State<BarcodeExamplePage> createState() => _BarcodeExamplePageState();
}

class _BarcodeExamplePageState extends State<BarcodeExamplePage> {
  String? _lastScannedBarcode;
  Map<String, dynamic>? _lastVerificationResult;

  void _openBarcodeScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GS1BarcodeScannerScreen(
          title: 'Scan Product',
          onBarcodeDetected: _handleBarcodeDetection,
          scanMode: ScanMode.single,
        ),
      ),
    );
  }
  void _handleBarcodeDetection(String gs1ElementString, Map<String, dynamic> parsedBarcode, Map<String, dynamic>? verificationResult) {
    setState(() {
      _lastScannedBarcode = gs1ElementString;
      // Use the parsed barcode result instead of the verification result
      // This gives us access to all the GS1 fields directly
      _lastVerificationResult = parsedBarcode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GS1 Barcode Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _openBarcodeScanner,
              child: const Text('Scan GS1 Barcode'),
            ),
            const SizedBox(height: 24),
            if (_lastScannedBarcode != null) ...[
              const Text(
                'Last Scanned Barcode:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _lastScannedBarcode!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
                if (_lastVerificationResult != null) ...[
                const Text(
                  'Parsed Barcode Data:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: _buildVerificationDetails(),
                    ),
                  ),
                ),
              ],
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'No barcode scanned yet.\nTap the button above to scan a GS1 barcode.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  Widget _buildVerificationDetails() {
    if (_lastVerificationResult == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show raw barcode
        if (_lastVerificationResult!.containsKey('rawBarcode'))
          _buildDetailRow('Raw Barcode', _lastVerificationResult!['rawBarcode'].toString()),
          
        // Show GS1 element string (normalized format)
        if (_lastVerificationResult!.containsKey('gs1ElementString'))
          _buildDetailRow('GS1 Element String', _lastVerificationResult!['gs1ElementString'].toString()),
          
        const Divider(),
        const Text(
          'Standard Fields',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        
        // Show standardized fields directly
        if (_lastVerificationResult!.containsKey('GTIN'))
          _buildDetailRow('GTIN', _lastVerificationResult!['GTIN']?.toString() ?? 'Not present'),
          
        if (_lastVerificationResult!.containsKey('BATCH'))
          _buildDetailRow('BATCH/LOT', _lastVerificationResult!['BATCH']?.toString() ?? 'Not present'),
          
        if (_lastVerificationResult!.containsKey('EXPIRY_FORMATTED'))
          _buildDetailRow('EXPIRY', _lastVerificationResult!['EXPIRY_FORMATTED']?.toString() ?? 'Not present')
        else if (_lastVerificationResult!.containsKey('EXPIRY'))
          _buildDetailRow('EXPIRY', _lastVerificationResult!['EXPIRY']?.toString() ?? 'Not present'),
          
        if (_lastVerificationResult!.containsKey('SERIAL'))
          _buildDetailRow('SERIAL', _lastVerificationResult!['SERIAL']?.toString() ?? 'Not present'),
        
        const Divider(),
        const Text(
          'All Parsed Fields',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        
        // Handle human-readable section if available
        if (_lastVerificationResult!.containsKey('humanReadable')) ...[
          _buildHumanReadableSection(),
        ] else ...[
          // Fallback to showing the raw result
          Text(
            _lastVerificationResult.toString(),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHumanReadableSection() {
    final humanReadable = _lastVerificationResult!['humanReadable'] as Map<String, dynamic>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: humanReadable.entries.map((entry) {
        return _buildDetailRow(entry.key, entry.value.toString());
      }).toList(),
    );
  }
}
