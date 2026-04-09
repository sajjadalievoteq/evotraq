import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/barcode/widgets/gs1_barcode_scanner_widget.dart';
import 'package:traqtrace_app/features/barcode/widgets/manual_barcode_input_widget.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';

/// Widget that integrates the new GS1 barcode scanning with API verification
class ApiEnabledBarcodeScannerScreen extends StatefulWidget {
  final String title;
  final String businessStep;
  final String disposition;
  final String locationGLN;
  final bool isVerificationMode;
  
  const ApiEnabledBarcodeScannerScreen({
    Key? key,
    required this.title,
    this.businessStep = 'urn:epcglobal:cbv:bizstep:observing',
    this.disposition = 'urn:epcglobal:cbv:disp:active',
    required this.locationGLN,
    this.isVerificationMode = false,
  }) : super(key: key);

  @override
  State<ApiEnabledBarcodeScannerScreen> createState() => _ApiEnabledBarcodeScannerScreenState();
}

class _ApiEnabledBarcodeScannerScreenState extends State<ApiEnabledBarcodeScannerScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _scanResult;
  String? _rawGS1ElementString;
  final TextEditingController _manualInputController = TextEditingController();
  bool _isCameraSupported = false;
  
  @override
  void initState() {
    super.initState();
    _checkPlatformSupport();
  }
  
  void _checkPlatformSupport() {
    // Only Android and iOS are fully supported for camera scanning
    _isCameraSupported = !kIsWeb && 
        (defaultTargetPlatform == TargetPlatform.android || 
         defaultTargetPlatform == TargetPlatform.iOS);
  }
  
  @override
  void dispose() {
    _manualInputController.dispose();
    super.dispose();
  }
  
  // Process input from wired scanners that submit via keyboard events
  void _processManualInput(String input) {
    if (input.isNotEmpty) {
      _onGS1BarcodeDetected(input);
      _manualInputController.clear();
    }
  }
    Future<void> _onGS1BarcodeDetected(String gs1ElementString) async {
    // Set raw gs1 element string immediately to display
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _rawGS1ElementString = gs1ElementString;
    });
    
    try {
      // Process the GS1 barcode locally using our parser
      // No API call needed - parse the barcode directly
      final result = GS1BarcodeParser.parseGS1Barcode(gs1ElementString);
      
      // Ensure raw barcode is included in the result
      if (!result.containsKey('rawBarcode')) {
        result['rawBarcode'] = gs1ElementString;
      }
      
      debugPrint('Parsed barcode: $result');
      
      setState(() {
        _isLoading = false;
        _scanResult = result;
        
        if (!(result['valid'] ?? false)) {
          _errorMessage = 'Invalid GS1 barcode format';
        }
      });
      
      // Show success message based on mode
      if (result['valid'] ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isVerificationMode 
                  ? 'GS1 barcode successfully verified' 
                  : 'GS1 barcode successfully detected (${result['GTIN'] ?? 'No GTIN'})'
            ),
            backgroundColor: widget.isVerificationMode ? Colors.blue : Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error processing barcode: $e';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // Button to toggle manual input for wired scanners
          IconButton(
            icon: const Icon(Icons.keyboard),
            tooltip: 'Manual/Wired Scanner Input',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Enter GS1 Barcode'),
                  content: TextField(
                    controller: _manualInputController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Scan or type GS1 barcode',
                    ),
                    onSubmitted: _processManualInput,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        _processManualInput(_manualInputController.text);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              );
            },
          ),
          // Help button to show information about GS1 barcodes
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'GS1 Barcode Help',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('GS1 Barcode Scanner'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'This scanner supports GS1 standard barcodes:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('• GS1 DataMatrix (2D)'),
                        Text('• GS1-128 (Linear)'),
                        Text('• EAN/UPC (with GS1 content)'),
                        SizedBox(height: 16),
                        Text('Position the barcode within the scanning frame for best results.'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // Use camera scanner only on supported platforms, otherwise use manual input
          _isCameraSupported 
            ? GS1BarcodeScannerWidget(
                onGS1BarcodeDetected: _onGS1BarcodeDetected,
                scanMode: ScanMode.continuous,
                overlayColor: widget.isVerificationMode ? Colors.blue : Colors.green,
                errorWidget: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Camera Error',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Unable to initialize the camera. Please make sure camera permissions are granted.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // Return to previous screen
                          Navigator.of(context).pop();
                        },
                        child: const Text('Go Back'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          // Show manual input dialog as fallback
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Enter GS1 Barcode Manually'),
                              content: TextField(
                                controller: _manualInputController,
                                autofocus: true,
                                decoration: const InputDecoration(
                                  hintText: 'Type GS1 barcode',
                                ),
                                onSubmitted: _processManualInput,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _processManualInput(_manualInputController.text);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Submit'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('Enter Barcode Manually'),
                      ),
                    ],
                  ),
                ),
              )
            : ManualBarcodeInputWidget(
                onGS1BarcodeDetected: _onGS1BarcodeDetected,
                themeColor: widget.isVerificationMode ? Colors.blue : Colors.green,
              ),
          
          // Loading overlay
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          
          // Error message
          if (_errorMessage != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          
          // Result display
          if (_scanResult != null && (_scanResult!['valid'] ?? false))
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.isVerificationMode ? Colors.blue[700] : Colors.green[700],
                  borderRadius: BorderRadius.circular(8),
                ),                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.isVerificationMode ? 'GS1 Barcode Verified' : 'GS1 Barcode Detected',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Display raw GS1 Element String
                    Text(
                      'Raw: ${_scanResult!['rawBarcode'] ?? _rawGS1ElementString ?? ""}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    
                    // Display directly accessible standard fields first
                    const SizedBox(height: 12),
                    const Text(
                      'Standard Fields:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_scanResult!['GTIN'] != null)
                      Text(
                        'GTIN: ${_scanResult!['GTIN']}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    if (_scanResult!['BATCH'] != null)
                      Text(
                        'BATCH/LOT: ${_scanResult!['BATCH']}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    if (_scanResult!['EXPIRY_FORMATTED'] != null)
                      Text(
                        'EXPIRY: ${_scanResult!['EXPIRY_FORMATTED']}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      )
                    else if (_scanResult!['EXPIRY'] != null)
                      Text(
                        'EXPIRY: ${_scanResult!['EXPIRY']}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    if (_scanResult!['SERIAL'] != null)
                      Text(
                        'SERIAL: ${_scanResult!['SERIAL']}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    
                    const SizedBox(height: 12),
                    // Expandable section for all fields
                    if (_scanResult!.containsKey('humanReadable') && 
                        _scanResult!['humanReadable'] is Map<String, dynamic>)
                    ExpansionTile(
                      title: const Text(
                        'All Fields',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      collapsedIconColor: Colors.white,
                      iconColor: Colors.white,
                      children: [
                        ...(_scanResult!['humanReadable'] as Map<String, dynamic>).entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(top: 4, left: 8, right: 8, bottom: 4),
                            child: Text(
                              '${entry.key}: ${entry.value}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ).toList(),
                      ],
                    ),
                    
                    // Show additional verification information in verification mode
                    if (widget.isVerificationMode)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified, 
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Valid GS1 Format',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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
