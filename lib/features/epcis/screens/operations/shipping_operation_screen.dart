import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/epcis/cubit/shipping_operation_cubit.dart';
import 'package:traqtrace_app/features/epcis/models/operations/shipping_models.dart';
import 'package:traqtrace_app/features/epcis/services/reference_data_validation_service.dart';
import 'package:traqtrace_app/features/gs1/models/gln_model.dart';
import 'package:traqtrace_app/shared/widgets/barcode_scanner.dart';
import 'package:traqtrace_app/shared/widgets/loading_overlay.dart';
import 'package:traqtrace_app/shared/widgets/gln_selector.dart';
import 'package:traqtrace_app/shared/models/scan_result.dart';
import 'package:traqtrace_app/shared/utils/gs1_validator.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';

/// Scanning mode options for different input methods
enum ScanningMode {
  camera,
  wired,
  manual,
}

/// Multi-step shipping operations screen
/// Step 1: Reference details
/// Step 2: Scan items 
/// Step 3: Review and submit
class ShippingOperationScreen extends StatefulWidget {
  const ShippingOperationScreen({Key? key}) : super(key: key);

  @override
  State<ShippingOperationScreen> createState() => _ShippingOperationScreenState();
}

class _ShippingOperationScreenState extends State<ShippingOperationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Form controllers and data
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  final _manualEntryController = TextEditingController();
  final _wiredScannerController = TextEditingController();
  final FocusNode _wiredScannerFocusNode = FocusNode();
  GLN? _sourceGLN;
  GLN? _destinationGLN;
  String? _sourceGLNError;
  String? _destinationGLNError;
  
  final List<String> _scannedEPCs = [];
  bool _isLoading = false;
  
  // Scanning mode state
  ScanningMode _scanningMode = kIsWeb ? ScanningMode.wired : ScanningMode.camera;
  bool _isWiredScannerActive = false;

  // Validation service
  ReferenceDataValidationService? _validationService;

  @override
  void initState() {
    super.initState();
    // Add focus listener for wired scanner
    _wiredScannerFocusNode.addListener(() {
      setState(() {
        _isWiredScannerActive = _wiredScannerFocusNode.hasFocus;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize validation service
    if (_validationService == null) {
      _validationService = context.read<ReferenceDataValidationService>();
    }
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    _manualEntryController.dispose();
    _wiredScannerController.dispose();
    _wiredScannerFocusNode.dispose();
    super.dispose();
  }

  Future<void> _nextStep() async {
    if (_currentStep < 2) {
      if (_validateCurrentStep()) {
        await _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Future<void> _previousStep() async {
    if (_currentStep > 0) {
      await _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    setState(() {
      _sourceGLNError = null;
      _destinationGLNError = null;
    });
    
    switch (_currentStep) {
      case 0:
        // Step 1: Validate reference details
        bool isValid = true;
        
        if (_referenceController.text.trim().isEmpty) {
          _showError('Reference is required');
          isValid = false;
        }
        if (_sourceGLN == null) {
          setState(() {
            _sourceGLNError = 'Source GLN is required';
          });
          isValid = false;
        }
        if (_destinationGLN == null) {
          setState(() {
            _destinationGLNError = 'Destination GLN is required';
          });
          isValid = false;
        }
        if (_sourceGLN != null && _destinationGLN != null && 
            _sourceGLN!.glnCode == _destinationGLN!.glnCode) {
          _showError('Source and destination GLN cannot be the same');
          isValid = false;
        }
        return isValid;
      case 1:
        // Step 2: Validate scanned items
        if (_scannedEPCs.isEmpty) {
          _showError('At least one item must be scanned');
          return false;
        }
        return true;
      case 2:
        // Step 3: Review step, validation already done
        return true;
      default:
        return true;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitShippingOperation() async {
    if (!_validateCurrentStep()) return;

    try {
      final shippingCubit = context.read<ShippingOperationCubit>();
      
      // Convert all scanned barcodes to EPC URIs before sending
      final conversionResult = EPCURIConverter.convertBatchToEPCUri(_scannedEPCs);
      final epcUris = conversionResult['successful'] ?? [];
      final failedConversions = conversionResult['failed'] ?? [];
      
      if (failedConversions.isNotEmpty) {
        _showError('Failed to convert ${failedConversions.length} barcode(s) to EPC format:\n${failedConversions.join('\n')}');
        return;
      }
      
      if (epcUris.isEmpty) {
        _showError('No valid EPCs to ship');
        return;
      }
      
      final shippingRequest = ShippingRequest(
        shippingReference: _referenceController.text.trim(),
        epcs: epcUris,
        sourceGLN: _sourceGLN!.glnCode,
        destinationGLN: _destinationGLN!.glnCode,
        comments: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
      );

      final response = await shippingCubit.createShippingOperation(shippingRequest);

      if (response.isSuccess) {
        _showSuccess('Shipping operation created successfully');
        if (mounted) {
          // Use go_router for proper web navigation
          context.go('/operations/shipping');
        }
      } else {
        final errorMessage = response.messages?.isNotEmpty == true 
            ? response.messages!.first 
            : 'Failed to create shipping operation';
        _showError(errorMessage);
      }
    } catch (e) {
      _showError('Error creating shipping operation: $e');
    }
  }

  void _onScanResult(ScanResult result) {
    if (result.isValid) {
      _validateAndAddEPC(result.data);
    } else {
      _showError(result.error ?? 'Invalid scan result');
    }
  }

  void _removeScannedEPC(String epc) {
    setState(() {
      _scannedEPCs.remove(epc);
    });
  }

  /// Validates an EPC against GS1 standards and database existence
  Future<void> _validateAndAddEPC(String epc, {bool isManual = false, bool isWiredScanner = false}) async {
    // Check if already scanned
    if (_scannedEPCs.contains(epc)) {
      _showError('Item already scanned: $epc');
      return;
    }

    // Show loading for validation
    setState(() => _isLoading = true);

    try {
      // Use centralized GS1BarcodeParser to parse the barcode
      final parsedBarcode = GS1BarcodeParser.parseGS1Barcode(epc);
      
      String epcType = '';
      String? identifierToValidate;
      
      // Check if parsing was successful
      if (parsedBarcode['valid'] == true) {
        // Determine the EPC type based on parsed data
        if (parsedBarcode['SSCC'] != null) {
          epcType = 'SSCC';
          identifierToValidate = parsedBarcode['SSCC'];
        } else if (parsedBarcode['GTIN'] != null && parsedBarcode['SERIAL'] != null) {
          epcType = 'SGTIN';
          // For SGTIN validation, we need the Serial Number (stored in SGTIN table)
          identifierToValidate = parsedBarcode['SERIAL'];
        } else if (parsedBarcode['GTIN'] != null) {
          // GTIN without serial - cannot validate as SGTIN, need serial number
          _showError('Barcode missing serial number: $epc\n\nFor shipping, a complete SGTIN with serial number (AI 21) is required.');
          return;
        }
      }
      
      // Also check for pure SSCC format (18 digits)
      if (epcType.isEmpty && GS1Validator.isValidSSCC(epc)) {
        epcType = 'SSCC';
        identifierToValidate = epc;
      }
      
      if (epcType.isEmpty || identifierToValidate == null) {
        _showError('Invalid barcode format: $epc\n\nSupported formats:\n- GS1 with AI syntax: (01)GTIN(21)SERIAL(17)EXPIRY(10)BATCH\n- SSCC: 18 digits\n- SGTIN URI: urn:epc:id:sgtin:...');
        return;
      }

      // Validate against database
      EPCValidationResult validationResult;
      if (epcType == 'SSCC') {
        validationResult = await _validationService!.validateSSCC(identifierToValidate);
      } else {
        // For SGTIN, validate using the Serial Number (unique identifier in SGTIN table)
        validationResult = await _validationService!.validateSGTIN(identifierToValidate);
      }

      if (validationResult.exists) {
        // Add to scanned list
        setState(() {
          _scannedEPCs.add(epc);
          
          // Clear input fields if needed
          if (isManual) {
            _manualEntryController.clear();
          } else if (isWiredScanner) {
            _wiredScannerController.clear();
          }
        });
        
        // Build success message with parsed details
        // String successMessage = '$epcType validated and added';
        // if (parsedBarcode['valid'] == true) {
        //   final details = <String>[];
        //   if (parsedBarcode['GTIN'] != null) details.add('GTIN: ${parsedBarcode['GTIN']}');
        //   if (parsedBarcode['SERIAL'] != null) details.add('Serial: ${parsedBarcode['SERIAL']}');
        //   if (parsedBarcode['BATCH'] != null) details.add('Batch: ${parsedBarcode['BATCH']}');
        //   if (details.isNotEmpty) {
        //     successMessage += '\n${details.join(', ')}';
        //   }
        // }
        //_showSuccess(successMessage);
      } else {
        String errorMessage = '$epcType not found in system';
        if (epcType == 'SGTIN') {
          errorMessage += '\nSerial Number: $identifierToValidate';
          if (parsedBarcode['GTIN'] != null) {
            errorMessage += '\nGTIN: ${parsedBarcode['GTIN']}';
          }
        } else {
          errorMessage += ': $identifierToValidate';
        }
        if (validationResult.errors.isNotEmpty) {
          errorMessage += '\n\nDetails: ${validationResult.errors.join(', ')}';
        }
        errorMessage += '\n\nPlease ensure the $epcType is properly registered in the system before shipping.';
        _showError(errorMessage);
      }
    } catch (e) {
      _showError('Error validating EPC: $e\nPlease check your connection and try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Helper method to determine EPC type using centralized parser
  String _getEPCType(String epc) {
    final parsedBarcode = GS1BarcodeParser.parseGS1Barcode(epc);
    
    if (parsedBarcode['SSCC'] != null || GS1Validator.isValidSSCC(epc)) {
      return 'SSCC';
    } else if (parsedBarcode['GTIN'] != null) {
      return parsedBarcode['SERIAL'] != null ? 'SGTIN' : 'GTIN';
    }
    return 'UNKNOWN';
  }

  void _addManualEPC() {
    final epc = _manualEntryController.text.trim();
    if (epc.isNotEmpty) {
      _validateAndAddEPC(epc, isManual: true);
    }
  }

  void _handleWiredScannerInput(String value) {
    final epc = value.trim();
    if (epc.isNotEmpty) {
      _validateAndAddEPC(epc, isWiredScanner: true);
    }
  }

  String _getScanningModeTitle() {
    switch (_scanningMode) {
      case ScanningMode.camera:
        return 'Camera Scanning';
      case ScanningMode.wired:
        return 'Wired Scanner';
      case ScanningMode.manual:
        return 'Manual Entry';
    }
  }

  IconData _getScanningModeIcon() {
    switch (_scanningMode) {
      case ScanningMode.camera:
        return Icons.camera_alt;
      case ScanningMode.wired:
        return Icons.keyboard;
      case ScanningMode.manual:
        return Icons.edit;
    }
  }

  Widget _buildScannerComponent() {
    switch (_scanningMode) {
      case ScanningMode.camera:
        return _buildCameraScanner();
      case ScanningMode.wired:
        return _buildWiredScanner();
      case ScanningMode.manual:
        return _buildManualEntry();
    }
  }

  Widget _buildCameraScanner() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.camera_alt, color: Colors.blue),
                const SizedBox(width: 8),
                const Text('Camera Scanner'),
                const Spacer(),
                Text(
                  'Allowed: SGTIN, SSCC',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BarcodeScanner(
              onScanResult: _onScanResult,
              allowedFormats: const ['SGTIN', 'SSCC'],
              height: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWiredScanner() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.keyboard, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Wired Scanner Input'),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isWiredScannerActive ? Colors.green[100] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isWiredScannerActive ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isWiredScannerActive ? 'Ready' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          color: _isWiredScannerActive ? Colors.green[800] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Click in the field below and scan with your wired barcode scanner',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _wiredScannerController,
              focusNode: _wiredScannerFocusNode,
              decoration: const InputDecoration(
                hintText: 'Focus here and scan with wired scanner...',
                prefixIcon: Icon(Icons.qr_code_scanner),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Handle real-time input from wired scanner
                if (value.isNotEmpty && (value.endsWith('\n') || value.endsWith('\r'))) {
                  _handleWiredScannerInput(value.replaceAll(RegExp(r'[\n\r]'), ''));
                }
              },
              onSubmitted: _handleWiredScannerInput,
              onTap: () {
                setState(() => _isWiredScannerActive = true);
              },
              onEditingComplete: () {
                setState(() => _isWiredScannerActive = false);
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Tip: Most wired scanners send an Enter key after scanning',
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualEntry() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit, color: Colors.orange),
                const SizedBox(width: 8),
                const Text('Manual Entry'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _manualEntryController,
                    decoration: const InputDecoration(
                      hintText: 'Enter SGTIN or SSCC manually...',
                      prefixIcon: Icon(Icons.edit),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addManualEPC(),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _addManualEPC,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the barcode data manually and click Add',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShippingOperationCubit, ShippingOperationState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: const Text('Shipping Operation'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          drawer: const AppDrawer(),
          body: LoadingOverlay(
            isLoading: _isLoading || state.loading,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildStepIndicator(0, 'Reference', Icons.info_outline),
                      Expanded(child: _buildStepConnector(0)),
                      _buildStepIndicator(1, 'Scan Items', Icons.qr_code_scanner),
                      Expanded(child: _buildStepConnector(1)),
                      _buildStepIndicator(
                        2,
                        'Review',
                        Icons.check_circle_outline,
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentStep = index);
                    },
                    children: [
                      _buildReferenceStep(),
                      _buildScanningStep(),
                      _buildReviewStep(),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousStep,
                            child: const Text('Previous'),
                          ),
                        ),
                      if (_currentStep > 0) const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _currentStep == 2
                              ? _submitShippingOperation
                              : _nextStep,
                          child: Text(_currentStep == 2 ? 'Submit' : 'Next'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final isActive = _currentStep >= step;
    final isCompleted = _currentStep > step;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted 
                ? Colors.green 
                : isActive 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey[300],
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isActive ? Colors.white : Colors.grey[600],
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Theme.of(context).primaryColor : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(int step) {
    final isCompleted = _currentStep > step;
    return Container(
      height: 2,
      color: isCompleted ? Colors.green : Colors.grey[300],
    );
  }

  Widget _buildReferenceStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping Reference Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter the reference information for this shipping operation.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          TextFormField(
            controller: _referenceController,
            decoration: const InputDecoration(
              labelText: 'Reference *',
              hintText: 'Enter shipping reference',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.label),
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 24),
          
          GLNSelector(
            label: 'Source GLN',
            hintText: 'Search and select source location',
            initialValue: _sourceGLN,
            isRequired: true,
            errorText: _sourceGLNError,
            onChanged: (gln) {
              setState(() {
                _sourceGLN = gln;
                _sourceGLNError = null;
              });
            },
          ),
          const SizedBox(height: 24),
          
          GLNSelector(
            label: 'Destination GLN',
            hintText: 'Search and select destination location',
            initialValue: _destinationGLN,
            isRequired: true,
            errorText: _destinationGLNError,
            onChanged: (gln) {
              setState(() {
                _destinationGLN = gln;
                _destinationGLNError = null;
              });
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (Optional)',
              hintText: 'Enter additional notes',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildScanningStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scan Items',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Scan SGTIN or SSCC codes for items to be shipped.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          
          // Validation info box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border.all(color: Colors.blue[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Only SSCC and SGTIN codes that exist in the system database can be added. Each code will be validated before being accepted.',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Scanning mode selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_getScanningModeIcon()),
                      const SizedBox(width: 8),
                      Text(
                        'Input Method: ${_getScanningModeTitle()}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Mode selection buttons
                  Wrap(
                    spacing: 8,
                    children: [
                      // Camera scanning (not available on web)
                      if (!kIsWeb)
                        ChoiceChip(
                          avatar: const Icon(Icons.camera_alt, size: 16),
                          label: const Text('Camera'),
                          selected: _scanningMode == ScanningMode.camera,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _scanningMode = ScanningMode.camera);
                            }
                          },
                        ),
                      
                      // Wired scanner
                      ChoiceChip(
                        avatar: const Icon(Icons.keyboard, size: 16),
                        label: const Text('Wired Scanner'),
                        selected: _scanningMode == ScanningMode.wired,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _scanningMode = ScanningMode.wired);
                            // Focus the wired scanner field when selected
                            Future.delayed(const Duration(milliseconds: 100), () {
                              _wiredScannerFocusNode.requestFocus();
                            });
                          }
                        },
                      ),
                      
                      // Manual entry
                      ChoiceChip(
                        avatar: const Icon(Icons.edit, size: 16),
                        label: const Text('Manual Entry'),
                        selected: _scanningMode == ScanningMode.manual,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _scanningMode = ScanningMode.manual);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Scanner/Input component based on selected mode
          _buildScannerComponent(),
          
          const SizedBox(height: 24),
          
          // Scanned items list
          Row(
            children: [
              Text(
                'Added Items (${_scannedEPCs.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (_scannedEPCs.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    setState(() => _scannedEPCs.clear());
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          
          if (_scannedEPCs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    _getScanningModeIcon(),
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No items added yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    'Use the ${_getScanningModeTitle().toLowerCase()} above to add items',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                itemCount: _scannedEPCs.length,
                itemBuilder: (context, index) {
                  final epc = _scannedEPCs[index];
                  final epcType = _getEPCType(epc);
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        epcType == 'SSCC' ? Icons.inventory : Icons.qr_code,
                        color: Colors.green,
                      ),
                      title: Text(
                        epc,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                      subtitle: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: epcType == 'SSCC' ? Colors.blue[100] : Colors.orange[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              epcType,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: epcType == 'SSCC' ? Colors.blue[800] : Colors.orange[800],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          const Text('Validated', style: TextStyle(color: Colors.green, fontSize: 12)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeScannedEPC(epc),
                        tooltip: 'Remove this item',
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Shipping Operation',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Please review the details before submitting.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          // Reference details card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 8),
                      Text(
                        'Reference Details',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildReviewField('Reference', _referenceController.text),
                  _buildGLNReviewField('Source GLN', _sourceGLN),
                  _buildGLNReviewField('Destination GLN', _destinationGLN),
                  if (_notesController.text.trim().isNotEmpty)
                    _buildReviewField('Notes', _notesController.text),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Items card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.inventory_2),
                      const SizedBox(width: 8),
                      Text(
                        'Items (${_scannedEPCs.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const Divider(),
                  ...List.generate(
                    _scannedEPCs.length,
                    (index) {
                      final barcode = _scannedEPCs[index];
                      final epcUri = EPCURIConverter.convertToEPCUri(barcode);
                      final parsed = GS1BarcodeParser.parseGS1Barcode(barcode);
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (parsed['GTIN'] != null)
                                    Text(
                                      'GTIN: ${parsed['GTIN']}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                ],
                              ),
                              if (parsed['SERIAL'] != null) ...[
                                const SizedBox(height: 4),
                                Text('Serial: ${parsed['SERIAL']}', style: const TextStyle(fontSize: 13)),
                              ],
                              if (parsed['BATCH'] != null) ...[
                                const SizedBox(height: 2),
                                Text('Batch: ${parsed['BATCH']}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              ],
                              if (parsed['EXPIRY_FORMATTED'] != null) ...[
                                const SizedBox(height: 2),
                                Text('Expiry: ${parsed['EXPIRY_FORMATTED']}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              ],
                              if (epcUri != null) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle, size: 14, color: Colors.green[700]),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          epcUri,
                                          style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.green[800]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error, size: 14, color: Colors.red[700]),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Unable to convert to EPC URI',
                                          style: TextStyle(fontSize: 11, color: Colors.red[800]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Warning card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              border: Border.all(color: Colors.orange[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange[800]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Once submitted, this shipping operation cannot be modified. Please ensure all details are correct.',
                    style: TextStyle(color: Colors.orange[800]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGLNReviewField(String label, GLN? gln) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: gln != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gln.glnCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        gln.locationName,
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (gln.city.isNotEmpty)
                        Text(
                          '${gln.city}, ${gln.stateProvince}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  )
                : const Text('Not selected'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? 'Not specified' : value),
          ),
        ],
      ),
    );
  }
}
