import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/epcis/models/operations/packing_models.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/shared/widgets/barcode_scanner.dart';
import 'package:traqtrace_app/shared/widgets/loading_overlay.dart';
import 'package:traqtrace_app/shared/widgets/gln_selector.dart';
import 'package:traqtrace_app/shared/models/scan_result.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';

import '../../../../data/services/packing_operation_service.dart';
import '../../../../data/services/reference_data_validation_service.dart';

/// Scanning mode options for different input methods
enum ScanningMode { camera, wired, manual }

/// Multi-step packing operations screen
/// Step 1: Reference details (work order, batch, packing location)
/// Step 2: Scan parent container (SSCC)
/// Step 3: Scan child items to pack
/// Step 4: Review and submit
class PackingOperationScreen extends StatefulWidget {
  const PackingOperationScreen({Key? key}) : super(key: key);

  @override
  State<PackingOperationScreen> createState() => _PackingOperationScreenState();
}

class _PackingOperationScreenState extends State<PackingOperationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form controllers and data
  final _referenceController = TextEditingController();
  final _workOrderController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _productionOrderController = TextEditingController();
  final _packingLineController = TextEditingController();
  final _operatorIdController = TextEditingController();
  final _notesController = TextEditingController();
  final _manualEntryController = TextEditingController();
  final _wiredScannerController = TextEditingController();
  final _containerManualEntryController = TextEditingController();
  final _containerWiredScannerController = TextEditingController();
  final FocusNode _wiredScannerFocusNode = FocusNode();
  final FocusNode _containerWiredScannerFocusNode = FocusNode();

  GLN? _packingLocationGLN;
  String? _packingLocationGLNError;

  String? _parentContainerId; // SSCC for the container
  final List<String> _scannedEPCs = [];
  bool _isLoading = false;

  // Scanning mode state
  ScanningMode _scanningMode = kIsWeb
      ? ScanningMode.wired
      : ScanningMode.camera;
  ScanningMode _containerScanningMode = kIsWeb
      ? ScanningMode.wired
      : ScanningMode.camera;
  bool _isWiredScannerActive = false;
  bool _isContainerWiredScannerActive = false;

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
    _containerWiredScannerFocusNode.addListener(() {
      setState(() {
        _isContainerWiredScannerActive =
            _containerWiredScannerFocusNode.hasFocus;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_validationService == null) {
      _validationService = getIt<ReferenceDataValidationService>();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _referenceController.dispose();
    _workOrderController.dispose();
    _batchNumberController.dispose();
    _productionOrderController.dispose();
    _packingLineController.dispose();
    _operatorIdController.dispose();
    _notesController.dispose();
    _manualEntryController.dispose();
    _wiredScannerController.dispose();
    _containerManualEntryController.dispose();
    _containerWiredScannerController.dispose();
    _wiredScannerFocusNode.dispose();
    _containerWiredScannerFocusNode.dispose();
    super.dispose();
  }

  Future<void> _nextStep() async {
    if (_currentStep < 3) {
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
      _packingLocationGLNError = null;
    });

    switch (_currentStep) {
      case 0:
        // Step 1: Validate reference details
        bool isValid = true;

        if (_referenceController.text.trim().isEmpty) {
          _showError('Packing Reference is required');
          isValid = false;
        }
        if (_packingLocationGLN == null) {
          setState(() {
            _packingLocationGLNError = 'Packing Location GLN is required';
          });
          isValid = false;
        }
        return isValid;
      case 1:
        // Step 2: Validate container
        if (_parentContainerId == null || _parentContainerId!.isEmpty) {
          _showError('Parent container (SSCC) is required');
          return false;
        }
        return true;
      case 2:
        // Step 3: Validate scanned items
        if (_scannedEPCs.isEmpty) {
          _showError('At least one item must be scanned to pack');
          return false;
        }
        return true;
      case 3:
        // Step 4: Review step, validation already done
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

  Future<void> _submitPackingOperation() async {
    if (!_validateCurrentStep()) return;

    setState(() => _isLoading = true);

    try {
      final packingService = getIt<PackingOperationService>();

      // Convert all scanned barcodes to EPC URIs before sending
      debugPrint(
        'Packing: Converting ${_scannedEPCs.length} scanned items to EPC URIs',
      );
      for (var barcode in _scannedEPCs) {
        debugPrint('  Item barcode: $barcode');
      }

      final conversionResult = EPCURIConverter.convertBatchToEPCUri(
        _scannedEPCs,
      );
      final epcUris = List<String>.from(conversionResult['successful'] ?? []);
      final failedConversions = List<String>.from(
        conversionResult['failed'] ?? [],
      );

      debugPrint(
        'Packing: Conversion result - ${epcUris.length} successful, ${failedConversions.length} failed',
      );
      for (var epc in epcUris) {
        debugPrint('  Converted EPC: $epc');
      }
      for (var failed in failedConversions) {
        debugPrint('  Failed barcode: $failed');
      }

      if (failedConversions.isNotEmpty) {
        _showError(
          'Failed to convert ${failedConversions.length} barcode(s) to EPC format:\n${failedConversions.join('\n')}',
        );
        setState(() => _isLoading = false);
        return;
      }

      if (epcUris.isEmpty) {
        _showError('No valid EPCs to pack');
        setState(() => _isLoading = false);
        return;
      }

      // Convert container ID to EPC URI if needed
      debugPrint('Packing: Converting container ID: $_parentContainerId');
      final containerEpc =
          EPCURIConverter.convertToEPCUri(_parentContainerId!) ??
          _parentContainerId!;
      debugPrint('Packing: Converted container EPC: $containerEpc');

      final packingRequest = PackingRequest(
        packingReference: _referenceController.text.trim(),
        parentContainerId: containerEpc,
        childEpcs: epcUris,
        packingLocationGLN: _packingLocationGLN!.glnCode,
        workOrderNumber: _workOrderController.text.trim().isNotEmpty
            ? _workOrderController.text.trim()
            : null,
        batchNumber: _batchNumberController.text.trim().isNotEmpty
            ? _batchNumberController.text.trim()
            : null,
        productionOrder: _productionOrderController.text.trim().isNotEmpty
            ? _productionOrderController.text.trim()
            : null,
        packingLine: _packingLineController.text.trim().isNotEmpty
            ? _packingLineController.text.trim()
            : null,
        operatorId: _operatorIdController.text.trim().isNotEmpty
            ? _operatorIdController.text.trim()
            : null,
        comments: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      final response = await packingService.createPackingOperation(
        packingRequest,
      );

      if (response.isSuccess) {
        _showSuccess('Packing operation created successfully');
        if (mounted) {
          context.go('/operations/packing');
        }
      } else {
        final errorMessage = response.messages?.isNotEmpty == true
            ? response.messages!.first
            : 'Failed to create packing operation';
        _showError(errorMessage);
      }
    } catch (e) {
      _showError('Error creating packing operation: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onContainerScanResult(ScanResult result) {
    if (result.isValid) {
      final barcode = result.data;
      // Parse the barcode to extract SSCC
      final parsed = GS1BarcodeParser.parseGS1Barcode(barcode);

      if (parsed['SSCC'] != null) {
        // SSCC found
        setState(() {
          _parentContainerId = parsed['SSCC'];
        });
        _showSuccess('Container scanned: ${parsed['SSCC']}');
      } else {
        // Use the raw barcode as container ID
        setState(() {
          _parentContainerId = barcode;
        });
        _showSuccess('Container scanned: $barcode');
      }
    }
  }

  void _onItemScanResult(ScanResult result) {
    if (result.isValid) {
      final barcode = result.data;

      // Check for duplicates
      if (_scannedEPCs.contains(barcode)) {
        _showError('Item already scanned: $barcode');
        return;
      }

      setState(() {
        _scannedEPCs.add(barcode);
      });
      _showSuccess('Item scanned: $barcode');
    }
  }

  void _addManualContainer() {
    final barcode = _containerManualEntryController.text.trim();
    if (barcode.isEmpty) {
      _showError('Please enter a container barcode/SSCC');
      return;
    }

    // Parse the barcode
    final parsed = GS1BarcodeParser.parseGS1Barcode(barcode);

    if (parsed['SSCC'] != null) {
      setState(() {
        _parentContainerId = parsed['SSCC'];
      });
    } else {
      setState(() {
        _parentContainerId = barcode;
      });
    }

    _containerManualEntryController.clear();
    //_showSuccess('Container added: $_parentContainerId');
  }

  void _addManualItem() {
    final barcode = _manualEntryController.text.trim();
    if (barcode.isEmpty) {
      _showError('Please enter a barcode');
      return;
    }

    if (_scannedEPCs.contains(barcode)) {
      _showError('Item already added: $barcode');
      return;
    }

    setState(() {
      _scannedEPCs.add(barcode);
    });
    _manualEntryController.clear();
    //_showSuccess('Item added: $barcode');
  }

  void _handleContainerWiredScan(String barcode) {
    if (barcode.isEmpty) return;

    final parsed = GS1BarcodeParser.parseGS1Barcode(barcode);

    if (parsed['SSCC'] != null) {
      setState(() {
        _parentContainerId = parsed['SSCC'];
      });
    } else {
      setState(() {
        _parentContainerId = barcode;
      });
    }

    _containerWiredScannerController.clear();
    _showSuccess('Container scanned: $_parentContainerId');
  }

  void _handleItemWiredScan(String barcode) {
    if (barcode.isEmpty) return;

    if (_scannedEPCs.contains(barcode)) {
      _showError('Item already scanned: $barcode');
      _wiredScannerController.clear();
      return;
    }

    setState(() {
      _scannedEPCs.add(barcode);
    });
    _wiredScannerController.clear();
    _showSuccess('Item scanned: $barcode');
  }

  void _removeScannedItem(int index) {
    setState(() {
      _scannedEPCs.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/operations/packing'),
          ),
          title: const Text('New Packing Operation'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        drawer: const AppDrawer(),
        body: Column(
          children: [
            // Progress indicator
            _buildStepIndicator(),

            // Main content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() => _currentStep = page);
                },
                children: [
                  _buildStep1ReferenceDetails(),
                  _buildStep2ContainerScan(),
                  _buildStep3ItemScan(),
                  _buildStep4Review(),
                ],
              ),
            ),

            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          _buildStepCircle(0, 'Details'),
          _buildStepLine(0),
          _buildStepCircle(1, 'Container'),
          _buildStepLine(1),
          _buildStepCircle(2, 'Items'),
          _buildStepLine(2),
          _buildStepCircle(3, 'Review'),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300],
              border: isCurrent
                  ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                  : null,
            ),
            child: Center(
              child: isActive && _currentStep > step
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int step) {
    final isActive = _currentStep > step;
    return Container(
      width: 20,
      height: 2,
      color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
    );
  }

  Widget _buildStep1ReferenceDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Packing Reference Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter the reference information for this packing operation.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Reference Number (Required)
          TextField(
            controller: _referenceController,
            decoration: const InputDecoration(
              labelText: 'Packing Reference *',
              hintText: 'e.g., PACK-2024-001',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag),
            ),
          ),
          const SizedBox(height: 16),

          // Packing Location GLN (Required)
          GLNSelector(
            label: 'Packing Location GLN',
            hintText: 'Search and select packing location',
            initialValue: _packingLocationGLN,
            isRequired: true,
            errorText: _packingLocationGLNError,
            onChanged: (gln) {
              setState(() {
                _packingLocationGLN = gln;
                _packingLocationGLNError = null;
              });
            },
          ),
          const SizedBox(height: 24),

          const Divider(),
          const SizedBox(height: 16),

          const Text(
            'Production Details (Optional)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // Work Order Number
          TextField(
            controller: _workOrderController,
            decoration: const InputDecoration(
              labelText: 'Work Order Number',
              hintText: 'e.g., WO-12345',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.work),
            ),
          ),
          const SizedBox(height: 16),

          // Batch Number
          TextField(
            controller: _batchNumberController,
            decoration: const InputDecoration(
              labelText: 'Batch Number',
              hintText: 'e.g., BATCH-001',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.batch_prediction),
            ),
          ),
          const SizedBox(height: 16),

          // Production Order
          TextField(
            controller: _productionOrderController,
            decoration: const InputDecoration(
              labelText: 'Production Order',
              hintText: 'e.g., PO-2024-001',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.precision_manufacturing),
            ),
          ),
          const SizedBox(height: 16),

          // Packing Line
          TextField(
            controller: _packingLineController,
            decoration: const InputDecoration(
              labelText: 'Packing Line',
              hintText: 'e.g., Line 1',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.conveyor_belt),
            ),
          ),
          const SizedBox(height: 16),

          // Operator ID
          TextField(
            controller: _operatorIdController,
            decoration: const InputDecoration(
              labelText: 'Operator ID',
              hintText: 'e.g., OP-001',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),

          // Notes
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Comments / Notes',
              hintText: 'Optional notes about this packing operation',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2ContainerScan() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scan Parent Container',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Scan or enter the SSCC of the container to pack items into.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Current container status
          if (_parentContainerId != null) ...[
            Card(
              color: Colors.green[50],
              child: ListTile(
                leading: const Icon(Icons.inventory_2, color: Colors.green),
                title: const Text('Container Selected'),
                subtitle: Text(
                  _parentContainerId!,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _parentContainerId = null;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Scanning mode selector
          _buildContainerScanningModeSelector(),
          const SizedBox(height: 16),

          // Scanning content based on mode
          _buildContainerScanningContent(),
        ],
      ),
    );
  }

  Widget _buildContainerScanningModeSelector() {
    return SegmentedButton<ScanningMode>(
      segments: [
        if (!kIsWeb)
          const ButtonSegment(
            value: ScanningMode.camera,
            icon: Icon(Icons.camera_alt),
            label: Text('Camera'),
          ),
        const ButtonSegment(
          value: ScanningMode.wired,
          icon: Icon(Icons.usb),
          label: Text('Wired Scanner'),
        ),
        const ButtonSegment(
          value: ScanningMode.manual,
          icon: Icon(Icons.keyboard),
          label: Text('Manual'),
        ),
      ],
      selected: {_containerScanningMode},
      onSelectionChanged: (modes) {
        setState(() {
          _containerScanningMode = modes.first;
        });
      },
    );
  }

  Widget _buildContainerScanningContent() {
    switch (_containerScanningMode) {
      case ScanningMode.camera:
        return _buildContainerCameraScanner();
      case ScanningMode.wired:
        return _buildContainerWiredScanner();
      case ScanningMode.manual:
        return _buildContainerManualEntry();
    }
  }

  Widget _buildContainerCameraScanner() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                // Open camera scanner
                final result = await showModalBottomSheet<ScanResult>(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: BarcodeScanner(
                      onScanResult: (result) {
                        Navigator.of(context).pop(result);
                      },
                    ),
                  ),
                );
                if (result != null) {
                  _onContainerScanResult(result);
                }
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Open Camera Scanner'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainerWiredScanner() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              _isContainerWiredScannerActive ? Icons.usb : Icons.usb_off,
              size: 48,
              color: _isContainerWiredScannerActive
                  ? Colors.green
                  : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _isContainerWiredScannerActive
                  ? 'Scanner Active - Ready to scan container'
                  : 'Click field below to activate scanner',
              style: TextStyle(
                color: _isContainerWiredScannerActive
                    ? Colors.green
                    : Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _containerWiredScannerController,
              focusNode: _containerWiredScannerFocusNode,
              autofocus: false,
              decoration: InputDecoration(
                labelText: 'Wired Scanner Input',
                hintText: 'Scan container barcode here',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.qr_code),
                suffixIcon: _isContainerWiredScannerActive
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
              ),
              onSubmitted: _handleContainerWiredScan,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainerManualEntry() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _containerManualEntryController,
              decoration: const InputDecoration(
                labelText: 'Container SSCC / Barcode',
                hintText: 'Enter the SSCC or container barcode',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory_2),
              ),
              onSubmitted: (_) => _addManualContainer(),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addManualContainer,
              icon: const Icon(Icons.add),
              label: const Text('Add Container'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3ItemScan() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scan Items to Pack',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan the items to be packed into container: ${_parentContainerId ?? 'Unknown'}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Scanning mode selector
          _buildItemScanningModeSelector(),
          const SizedBox(height: 16),

          // Scanning content based on mode
          _buildItemScanningContent(),
          const SizedBox(height: 24),

          // Scanned items list
          _buildScannedItemsList(),
        ],
      ),
    );
  }

  Widget _buildItemScanningModeSelector() {
    return SegmentedButton<ScanningMode>(
      segments: [
        if (!kIsWeb)
          const ButtonSegment(
            value: ScanningMode.camera,
            icon: Icon(Icons.camera_alt),
            label: Text('Camera'),
          ),
        const ButtonSegment(
          value: ScanningMode.wired,
          icon: Icon(Icons.usb),
          label: Text('Wired Scanner'),
        ),
        const ButtonSegment(
          value: ScanningMode.manual,
          icon: Icon(Icons.keyboard),
          label: Text('Manual'),
        ),
      ],
      selected: {_scanningMode},
      onSelectionChanged: (modes) {
        setState(() {
          _scanningMode = modes.first;
        });
      },
    );
  }

  Widget _buildItemScanningContent() {
    switch (_scanningMode) {
      case ScanningMode.camera:
        return _buildItemCameraScanner();
      case ScanningMode.wired:
        return _buildItemWiredScanner();
      case ScanningMode.manual:
        return _buildItemManualEntry();
    }
  }

  Widget _buildItemCameraScanner() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await showModalBottomSheet<ScanResult>(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: BarcodeScanner(
                      onScanResult: (result) {
                        Navigator.of(context).pop(result);
                      },
                    ),
                  ),
                );
                if (result != null) {
                  _onItemScanResult(result);
                }
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Open Camera Scanner'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemWiredScanner() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              _isWiredScannerActive ? Icons.usb : Icons.usb_off,
              size: 48,
              color: _isWiredScannerActive ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _isWiredScannerActive
                  ? 'Scanner Active - Ready to scan items'
                  : 'Click field below to activate scanner',
              style: TextStyle(
                color: _isWiredScannerActive ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _wiredScannerController,
              focusNode: _wiredScannerFocusNode,
              autofocus: false,
              decoration: InputDecoration(
                labelText: 'Wired Scanner Input',
                hintText: 'Scan item barcode here',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.qr_code),
                suffixIcon: _isWiredScannerActive
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
              ),
              onSubmitted: _handleItemWiredScan,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemManualEntry() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _manualEntryController,
              decoration: const InputDecoration(
                labelText: 'Item Barcode',
                hintText: 'Enter GTIN, SGTIN, or barcode',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
              onSubmitted: (_) => _addManualItem(),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addManualItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannedItemsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.list_alt),
                const SizedBox(width: 8),
                Text(
                  'Scanned Items (${_scannedEPCs.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_scannedEPCs.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _scannedEPCs.clear();
                      });
                    },
                    child: const Text('Clear All'),
                  ),
              ],
            ),
            const Divider(),
            if (_scannedEPCs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No items scanned yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _scannedEPCs.length,
                itemBuilder: (context, index) {
                  final epc = _scannedEPCs[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.teal[100],
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.teal[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      epc,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeScannedItem(index),
                    ),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4Review() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Packing Operation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please review all details before submitting.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Reference Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tag, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Reference Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildReviewRow(
                    'Packing Reference',
                    _referenceController.text,
                  ),
                  _buildReviewRow(
                    'Packing Location',
                    _packingLocationGLN?.locationName ??
                        _packingLocationGLN?.glnCode ??
                        'N/A',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Production Details
          if (_workOrderController.text.isNotEmpty ||
              _batchNumberController.text.isNotEmpty ||
              _productionOrderController.text.isNotEmpty ||
              _packingLineController.text.isNotEmpty ||
              _operatorIdController.text.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.precision_manufacturing,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Production Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    if (_workOrderController.text.isNotEmpty)
                      _buildReviewRow('Work Order', _workOrderController.text),
                    if (_batchNumberController.text.isNotEmpty)
                      _buildReviewRow(
                        'Batch Number',
                        _batchNumberController.text,
                      ),
                    if (_productionOrderController.text.isNotEmpty)
                      _buildReviewRow(
                        'Production Order',
                        _productionOrderController.text,
                      ),
                    if (_packingLineController.text.isNotEmpty)
                      _buildReviewRow(
                        'Packing Line',
                        _packingLineController.text,
                      ),
                    if (_operatorIdController.text.isNotEmpty)
                      _buildReviewRow(
                        'Operator ID',
                        _operatorIdController.text,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Container Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.inventory_2, color: Colors.brown),
                      const SizedBox(width: 8),
                      const Text(
                        'Container',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildReviewRow(
                    'Parent Container',
                    _parentContainerId ?? 'N/A',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Items to Pack
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.list_alt, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text(
                        'Items to Pack (${_scannedEPCs.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _scannedEPCs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text('${index + 1}. '),
                            Expanded(
                              child: Text(
                                _scannedEPCs[index],
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Comments
          if (_notesController.text.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notes, color: Colors.purple),
                        const SizedBox(width: 8),
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Text(_notesController.text),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _currentStep == 3
                  ? _submitPackingOperation
                  : _nextStep,
              child: Text(
                _currentStep == 3 ? 'Create Packing Operation' : 'Next',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
