import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/core/widgets/loading_indicator.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';

import 'package:traqtrace_app/features/barcode/services/barcode_epcis_mapper.dart';

import 'package:traqtrace_app/features/barcode/widgets/scanner_overlay.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_event.dart';

import '../../../data/services/barcode_scanner_service.dart';
import '../../../data/services/wired_scanner_service.dart';

class BarcodeScannerView extends StatefulWidget {
  final String bizStep;
  final String disposition;
  final String readPoint;
  final String bizLocation;
  final Function(EPCISEvent) onScanComplete;
  final AppConfig? appConfig;
  final TokenManager? tokenManager;

  const BarcodeScannerView({
    Key? key,
    required this.bizStep,
    required this.disposition,
    required this.readPoint,
    required this.bizLocation,
    required this.onScanComplete,
    this.appConfig,
    this.tokenManager,
  }) : super(key: key);

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView> with WidgetsBindingObserver {
  CameraController? _cameraController;
  final BarcodeScanner _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);
  final BarcodeScannerService _scannerService = BarcodeScannerService();
  final BarcodeToEPCISMapper _epcisMapper = BarcodeToEPCISMapper();
  final WiredScannerService _wiredScannerService = WiredScannerService();
  final TextEditingController _manualInputController = TextEditingController();
  final FocusNode _keyboardFocusNode = FocusNode();
    bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _isPermissionDenied = false;
  bool _showFlashIcon = false;
  bool _isFlashOn = false;
  bool _useWiredScanner = false;
  String _manualBarcodeBuffer = '';
  DateTime? _lastKeyPressTime;
  
  // Store GS1 component data
  Map<String, String> _gs1Components = {
    'GTIN (01)': '-',
    'Serial Number (21)': '-',
    'Batch/Lot (10)': '-',
    'Expiry Date (17)': '-',
    'Production Date (11)': '-',
  };
  
  static const int _wiredScannerDelayMs = 30; // Typical delay between keystrokes from scanner
    @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Setup focus node for keyboard/wired scanner input
    _keyboardFocusNode.addListener(() {
      if (_keyboardFocusNode.hasFocus) {
        // Clear manual buffer when focus is gained
        _manualBarcodeBuffer = '';
      }
    });
    
    // Initialize wired scanner service if configs are provided
    _initWiredScannerService();
    
    // Attempt to initialize camera but fallback to wired scanner on error
    _initializeCamera().catchError((error) {
      debugPrint('Camera initialization error: $error');
      // Fallback to wired scanner mode on camera error
      setState(() {
        _useWiredScanner = true;
        _isCameraInitialized = false;
      });
    });
  }
  
  // Initialize wired scanner service with config and token manager
  void _initWiredScannerService() {
    if (widget.appConfig != null && widget.tokenManager != null) {
      _wiredScannerService.initApiService(
        widget.appConfig!,
        widget.tokenManager!,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _barcodeScanner.close();
    _manualInputController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;
    
    // App state changed before camera controller is initialized
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }  Future<void> _initializeCamera() async {
    // First check if the device has a camera
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras found on this device');
      }
    } catch (e) {
      debugPrint('Error checking cameras: $e');
      throw Exception('Failed to access device cameras: $e');
    }
    
    // Request camera permissions
    final status = await Permission.camera.request();
    
    if (status.isDenied) {
      setState(() {
        _isPermissionDenied = true;
      });
      return;
    }
    
    setState(() {
      _isPermissionDenied = false;
    });
    
    try {
      final cameras = await availableCameras();
      
      if (cameras.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No camera found on the device')),
        );
        return;
      }
      
      // Prefer back camera for barcode scanning
      CameraDescription? selectedCamera;
      
      try {
        // First try to find a back camera
        selectedCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
        );
        debugPrint('Using back camera: ${selectedCamera.name}');
      } catch (e) {
        // If no back camera, try front camera or use the first available camera
        debugPrint('No back camera found, trying front camera: $e');
        try {
          selectedCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
          );
          debugPrint('Using front camera: ${selectedCamera.name}');
        } catch (e2) {
          // If no specific camera found, use the first available
          selectedCamera = cameras.first;
          debugPrint('Using first available camera: ${selectedCamera.name}');
        }
      }        // Create and initialize the camera controller with safer settings
      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.low, // Use low resolution for more stable operation
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      
      debugPrint('Initializing camera controller...');
      try {
        await _cameraController!.initialize();
        debugPrint('Camera controller initialized successfully.');
      } catch (e) {
        debugPrint('Camera initialization failed: $e');
        throw Exception('Failed to initialize camera: $e');
      }
      
      // Check if flash is available (use torch mode for checking)
      try {
        await _cameraController!.setFlashMode(FlashMode.torch);
        await _cameraController!.setFlashMode(FlashMode.off);
        _showFlashIcon = true;
      } catch (e) {
        _showFlashIcon = false;
        debugPrint('Flash not available: $e');
      }
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
      
      // Start image stream for barcode detection
      _startBarcodeDetection();    } catch (e) {
      debugPrint('Camera initialization error: $e');
      // We'll show an error message if in camera mode, but not if we've already
      // switched to wired scanner mode in the initState error handler
      if (mounted && !_useWiredScanner) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera initialization failed: $e'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Switch to Wired Scanner',
              onPressed: () {
                setState(() {
                  _useWiredScanner = true;
                });
              },
            ),
          ),
        );
      }
      // Re-throw the exception for the catchError in initState to handle
      throw Exception('Camera initialization failed: $e');
    }
  }

  void _startBarcodeDetection() {
    _cameraController?.startImageStream((CameraImage image) {
      if (_isProcessing) return;
      
      _isProcessing = true;
      
      _scannerService.processImage(
        image, 
        _cameraController!.description, 
        _barcodeScanner
      ).then((barcodes) {
        if (barcodes.isNotEmpty && mounted) {
          // Stop processing
          _cameraController?.stopImageStream();
          
          // Process the detected barcode
          _processDetectedBarcode(barcodes.first);
        }
      }).catchError((error) {
        debugPrint('Barcode processing error: $error');
      }).whenComplete(() {
        _isProcessing = false;
      });
    });
  }
  Future<void> _processDetectedBarcode(Barcode barcode) async {
    final barcodeValue = barcode.rawValue;
    if (barcodeValue == null || barcodeValue.isEmpty) {
      return;
    }

    debugPrint('Barcode detected: $barcodeValue');

    // Map barcode to EPCIS event
    final epcisEvent = await _epcisMapper.mapBarcodeToEPCISEvent(
      barcode,
      widget.bizStep,
      widget.disposition,
      widget.readPoint,
      widget.bizLocation,
    );
    
    if (epcisEvent != null) {
      // Parse GS1 data if it's available in the event
      if (epcisEvent.bizData != null && epcisEvent.bizData!.containsKey('gs1Data')) {
        try {
          // The gs1Data is stored as a string in the bizData, parse it back to a map
          final gs1DataStr = epcisEvent.bizData!['gs1Data'].toString();
          
          // Update GS1 components in state
          setState(() {
            if (gs1DataStr.contains('GTIN')) {
              _gs1Components['GTIN (01)'] = _extractValue(gs1DataStr, 'GTIN');
            }
            
            if (gs1DataStr.contains('serialNumber')) {
              _gs1Components['Serial Number (21)'] = _extractValue(gs1DataStr, 'serialNumber');
            }
            
            if (gs1DataStr.contains('batchNumber') || gs1DataStr.contains('lotNumber')) {
              _gs1Components['Batch/Lot (10)'] = 
                  _extractValue(gs1DataStr, 'batchNumber').isNotEmpty 
                      ? _extractValue(gs1DataStr, 'batchNumber') 
                      : _extractValue(gs1DataStr, 'lotNumber');
            }
            
            if (gs1DataStr.contains('expiryDate')) {
              _gs1Components['Expiry Date (17)'] = _extractValue(gs1DataStr, 'expiryDate');
            }
            
            if (gs1DataStr.contains('productionDate')) {
              _gs1Components['Production Date (11)'] = _extractValue(gs1DataStr, 'productionDate');
            }
          });
        } catch (e) {
          debugPrint('Error parsing GS1 data: $e');
        }
      }
      
      widget.onScanComplete(epcisEvent);
    } else {
      // Show error and resume scanning
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to process barcode data'),
            duration: Duration(seconds: 2),
          ),
        );
        _startBarcodeDetection();
      }
    }
  }  // Process barcode input from wired scanner
  void _processWiredScannerInput(String barcode) async {
    if (barcode.isEmpty) return;
    
    debugPrint('Wired scanner barcode: $barcode');
    
    try {
      // Use the dedicated wired scanner service
      final epcisEvent = await _wiredScannerService.processWiredScannerInput(
        barcode,
        widget.bizStep,
        widget.disposition,
        widget.readPoint,
        widget.bizLocation,
        appConfig: widget.appConfig,
        tokenManager: widget.tokenManager,
      );
      
      // Parse GS1 data if it's available in the event
      if (epcisEvent.bizData != null && epcisEvent.bizData!.containsKey('gs1Data')) {
        try {
          // The gs1Data is stored as a string in the bizData, parse it back to a map
          final gs1DataStr = epcisEvent.bizData!['gs1Data'].toString();
          debugPrint('GS1 Data from wired scanner: $gs1DataStr');
          
          // Update all GS1 components in a single setState call
          setState(() {
            // Check if this is a response from parse-gs1 endpoint
            if (gs1DataStr.contains('"parsed"')) {
              try {
                final jsonData = json.decode(gs1DataStr);
                if (jsonData.containsKey('parsed')) {
                  final parsedData = jsonData['parsed'] as Map<String, dynamic>;
                  // Extract AI values
                  if (parsedData.containsKey('01')) {
                    _gs1Components['GTIN (01)'] = parsedData['01'].toString();
                  }
                  if (parsedData.containsKey('21')) {
                    _gs1Components['Serial Number (21)'] = parsedData['21'].toString();
                  }
                  if (parsedData.containsKey('10')) {
                    _gs1Components['Batch/Lot (10)'] = parsedData['10'].toString();
                  }
                  if (parsedData.containsKey('17')) {
                    _gs1Components['Expiry Date (17)'] = parsedData['17'].toString();
                  }
                  if (parsedData.containsKey('11')) {
                    _gs1Components['Production Date (11)'] = parsedData['11'].toString();
                  }
                }
              } catch (jsonError) {
                debugPrint('Error parsing JSON from parse-gs1: $jsonError');
                // Fall back to the old extraction method
                _extractGS1DataFromString(gs1DataStr);
              }
            } else {
              // Use the traditional extraction method
              _extractGS1DataFromString(gs1DataStr);
            }
          });
        } catch (e) {
          debugPrint('Error parsing GS1 data: $e');
        }
      } else {
        debugPrint('No GS1 data found in event bizData: ${epcisEvent.bizData}');
      }
      
      widget.onScanComplete(epcisEvent);
    } catch (e) {
      debugPrint('Error processing wired scanner input: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing barcode: $e')),
        );
      }
    }
    
    // Clear buffer after processing
    _manualBarcodeBuffer = '';
  }
  
  // Helper method to extract GS1 data from a string
  void _extractGS1DataFromString(String gs1DataStr) {
    // Extract GTIN, Serial Number, Batch/Lot, etc.
    if (gs1DataStr.contains('GTIN')) {
      _gs1Components['GTIN (01)'] = _extractValue(gs1DataStr, 'GTIN');
    }
    
    if (gs1DataStr.contains('serialNumber')) {
      _gs1Components['Serial Number (21)'] = _extractValue(gs1DataStr, 'serialNumber');
    }
    
    if (gs1DataStr.contains('batchNumber') || gs1DataStr.contains('lotNumber')) {
      _gs1Components['Batch/Lot (10)'] = 
          _extractValue(gs1DataStr, 'batchNumber').isNotEmpty 
              ? _extractValue(gs1DataStr, 'batchNumber') 
              : _extractValue(gs1DataStr, 'lotNumber');
    }
    
    if (gs1DataStr.contains('expiryDate')) {
      _gs1Components['Expiry Date (17)'] = _extractValue(gs1DataStr, 'expiryDate');
    }
    
    if (gs1DataStr.contains('productionDate')) {
      _gs1Components['Production Date (11)'] = _extractValue(gs1DataStr, 'productionDate');
    }
  }
  
  // Helper method to build a GS1 component row
  Widget _buildGS1Component(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _gs1Components[label] ?? value,
              style: const TextStyle(
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }

      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      debugPrint('Failed to toggle flash: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to toggle flash')),
      );
    }
  }
    // Toggle between camera and wired scanner modes
  void _toggleScannerMode() {
    setState(() {
      _useWiredScanner = !_useWiredScanner;
      
      // Reset GS1 components when switching modes
      _gs1Components = {
        'GTIN (01)': '-',
        'Serial Number (21)': '-',
        'Batch/Lot (10)': '-',
        'Expiry Date (17)': '-',
        'Production Date (11)': '-',
      };
      
      if (_useWiredScanner) {
        // Stop camera processing when switching to wired scanner
        _cameraController?.stopImageStream();
        // Request focus for keyboard/scanner input
        _keyboardFocusNode.requestFocus();
      } else {
        // Resume camera processing
        _startBarcodeDetection();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    if (_isPermissionDenied) {
      return _buildPermissionDenied();
    }

    // If using wired scanner, don't wait for camera initialization
    if (_useWiredScanner) {
      return _buildWiredScannerScaffold();
    }

    // Show loading indicator while camera initializes
    if (!_isCameraInitialized) {
      return const Scaffold(
        body: Center(
          child: LoadingIndicator(),
        ),
      );
    }

    // Camera is ready, show camera UI
    return _buildCameraScaffold();
  }
  
  // Build scaffold with wired scanner UI
  Widget _buildWiredScannerScaffold() {
    return Scaffold(
      drawer: const AppDrawer(),
      body: RawKeyboardListener(
        focusNode: _keyboardFocusNode,
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            _handleKeyEvent(event);
          }
        },
        child: Stack(
          children: [
            _buildWiredScannerUI(),
            _buildTopBar(),
          ],
        ),
      ),
    );
  }
  
  // Build scaffold with camera UI
  Widget _buildCameraScaffold() {
    return Scaffold(
      drawer: const AppDrawer(),
      body: RawKeyboardListener(
        focusNode: _keyboardFocusNode,
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            _handleKeyEvent(event);
          }
        },
        child: Stack(
          children: [
            _buildCameraUI(),
            _buildTopBar(),
          ],
        ),
      ),
    );
  }
  
  // Build the top bar with controls
  Widget _buildTopBar() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          color: Colors.black54,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Text(
                'Scan Barcode',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Toggle between camera and wired scanner
                  IconButton(
                    icon: Icon(
                      _useWiredScanner ? Icons.camera_alt : Icons.keyboard,
                      color: Colors.white,
                    ),
                    onPressed: _toggleScannerMode,
                    tooltip: _useWiredScanner ? 'Switch to Camera' : 'Switch to Wired Scanner',
                  ),
                  // Flash toggle (only show when camera is active and flash is available)
                  if (!_useWiredScanner && _showFlashIcon)
                    IconButton(
                      icon: Icon(
                        _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                      ),
                      onPressed: _toggleFlash,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Handle key events from the wired scanner
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;
    
    // Check if we received a newline or carriage return (end of barcode)
    if (event.logicalKey == LogicalKeyboardKey.enter || 
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      // Process the complete barcode
      if (_manualBarcodeBuffer.isNotEmpty) {
        _processWiredScannerInput(_manualBarcodeBuffer);
      }
      return;
    }
    
    // Get the character from the key event
    String? character = event.character;
    
    // Skip modifier keys and special keys
    if (character == null || 
        event.isControlPressed || 
        event.isAltPressed || 
        event.isMetaPressed) {
      return;
    }
    
    // Honeywell scanners send keystrokes very quickly
    // We can use this to distinguish scanner input from manual typing
    final currentTime = DateTime.now();
    final isLikelyScanner = _lastKeyPressTime != null && 
                           currentTime.difference(_lastKeyPressTime!).inMilliseconds < _wiredScannerDelayMs;
    
    // Update last key press time
    _lastKeyPressTime = currentTime;
    
    // If previous inputs were from a scanner or buffer is empty, treat this as scanner input
    if (isLikelyScanner || _manualBarcodeBuffer.isEmpty) {
      setState(() {
        _manualBarcodeBuffer += character;
      });
    } else {
      // Clear buffer if this appears to be manual typing (long delay since last keystroke)
      setState(() {
        _manualBarcodeBuffer = character;
      });
    }
  }
    // Build the UI for the camera scanner
  Widget _buildCameraUI() {
    return Stack(
      children: [
        // Camera preview
        CameraPreview(_cameraController!),
        
        // Scanning overlay
        const ScannerOverlay(),
        
        // Instructions
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black54,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // GS1 Components Section
                  if (_gs1Components.values.any((v) => v != '-'))
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GS1 Components:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          for (var entry in _gs1Components.entries)
                            if (entry.value != '-')
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    Text(
                                      '${entry.key}:',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        ],
                      ),
                    ),
                  
                  const Text(
                    'Point the camera at a GS1 barcode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
    // Build the UI for the wired scanner
  Widget _buildWiredScannerUI() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.qr_code_scanner,
            size: 80,  // Smaller icon to make more room for GS1 data
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          const Text(
            'Wired Scanner Mode',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use your wired barcode scanner to scan a GS1 barcode',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Raw Data:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _manualBarcodeBuffer.isEmpty ? 'Waiting for scan...' : _manualBarcodeBuffer,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Courier',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // GS1 components section - will be populated after a successful scan
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GS1 Components:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,                        children: [
                          _buildGS1Component('GTIN (01)', _gs1Components['GTIN (01)'] ?? '-'),
                          _buildGS1Component('Serial Number (21)', _gs1Components['Serial Number (21)'] ?? '-'),
                          _buildGS1Component('Batch/Lot (10)', _gs1Components['Batch/Lot (10)'] ?? '-'),
                          _buildGS1Component('Expiry Date (17)', _gs1Components['Expiry Date (17)'] ?? '-'),
                          _buildGS1Component('Production Date (11)', _gs1Components['Production Date (11)'] ?? '-'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Note: Ensure the scanner is properly connected to your device',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPermissionDenied() {
    return Scaffold(
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt, size: 100, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Camera permission denied',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please grant camera permission to scan barcodes',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _initializeCamera(),
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }

  // Extract value from GS1 data string by key
  String _extractValue(String dataStr, String key) {
    try {
      // Try to handle it as a JSON first
      if (dataStr.startsWith('{') && dataStr.endsWith('}')) {
        try {
          final Map<String, dynamic> data = json.decode(dataStr);
          // For parse-gs1 endpoint response format
          if (data.containsKey('parsed')) {
            // Find matching AI based on the key name
            final Map<String, dynamic> parsed = data['parsed'];
            
            // Map common field names to AI numbers
            final Map<String, String> keyToAI = {
              'GTIN': '01',
              'serialNumber': '21',
              'batchNumber': '10',
              'lotNumber': '10',
              'expiryDate': '17',
              'productionDate': '11',
            };
            
            final String? ai = keyToAI[key];
            if (ai != null && parsed.containsKey(ai)) {
              return parsed[ai].toString();
            }
          }
          
          // Standard field-based format
          if (data.containsKey(key)) {
            return data[key].toString();
          }
          
          // No value found for the key
          return '';
        } catch(e) {
          // Failed to parse as JSON, fall through to string parsing
          debugPrint('Failed to parse GS1 data as JSON: $e');
        }
      }
      
      // String extraction using regex pattern
      final RegExp pattern = RegExp('$key["\']?\\s*[:=]\\s*["\']?([^,"\'\\}\\]]+)', caseSensitive: false);
      final match = pattern.firstMatch(dataStr);
      
      if (match != null && match.groupCount >= 1) {
        return match.group(1)?.trim() ?? '';
      }
      
      return '';
    } catch (e) {
      debugPrint('Error extracting $key from GS1 data: $e');
      return '';
    }
  }
}
