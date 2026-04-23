import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/features/epcis/models/operations/commissioning_models.dart';
import 'package:traqtrace_app/data/services/commissioning_operation_service.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_cubit.dart';
import 'package:traqtrace_app/features/gs1/models/gln_model.dart';
import 'package:traqtrace_app/shared/widgets/loading_overlay.dart';
import 'package:traqtrace_app/shared/widgets/gln_selector.dart';
import 'package:traqtrace_app/shared/widgets/barcode_scanner.dart';
import 'package:traqtrace_app/shared/models/scan_result.dart';

/// Scanning mode options for different input methods
enum ScanningMode { camera, wired, manual }

/// Multi-step commissioning operations screen for bulk serial number commissioning
/// Step 1: Reference details (GTIN, batch/lot, location, dates)
/// Step 2: Scan/enter serial numbers
/// Step 3: Review and submit
class CommissioningOperationScreen extends StatefulWidget {
  const CommissioningOperationScreen({Key? key}) : super(key: key);

  @override
  State<CommissioningOperationScreen> createState() =>
      _CommissioningOperationScreenState();
}

class _CommissioningOperationScreenState
    extends State<CommissioningOperationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form controllers and data
  final _referenceController = TextEditingController();
  final _gtinController = TextEditingController();
  final _batchLotController = TextEditingController();
  final _operatorIdController = TextEditingController();
  final _notesController = TextEditingController();
  final _manualSerialController = TextEditingController();
  final _wiredScannerController = TextEditingController();
  final FocusNode _wiredScannerFocusNode = FocusNode();

  // GTIN selection
  List<GTIN> _availableGTINs = [];
  GTIN? _selectedGTIN;
  bool _isLoadingGTINs = false;
  String? _gtinError;

  // Location selection
  GLN? _commissioningLocationGLN;
  String? _locationError;

  // Dates
  DateTime? _expiryDate;
  DateTime? _productionDate;
  DateTime? _bestBeforeDate;

  // Serial numbers
  final List<String> _serialNumbers = [];
  bool _isLoading = false;

  // Scanning mode state
  ScanningMode _scanningMode = kIsWeb
      ? ScanningMode.wired
      : ScanningMode.camera;
  bool _isWiredScannerActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadGTINs());
    // Add focus listener for wired scanner
    _wiredScannerFocusNode.addListener(() {
      setState(() {
        _isWiredScannerActive = _wiredScannerFocusNode.hasFocus;
      });
    });
  }

  Future<void> _loadGTINs() async {
    setState(() => _isLoadingGTINs = true);
    try {
      final gtins = await context.read<GTINCubit>().fetchGtinsForPicker();
      setState(() {
        _availableGTINs = gtins;
        _isLoadingGTINs = false;
      });
    } catch (e) {
      debugPrint('Error loading GTINs: $e');
      setState(() => _isLoadingGTINs = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _referenceController.dispose();
    _gtinController.dispose();
    _batchLotController.dispose();
    _operatorIdController.dispose();
    _notesController.dispose();
    _manualSerialController.dispose();
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
      _gtinError = null;
      _locationError = null;
    });

    switch (_currentStep) {
      case 0:
        // Step 1: Validate reference details
        bool isValid = true;

        if (_selectedGTIN == null && _gtinController.text.trim().isEmpty) {
          setState(() {
            _gtinError = 'GTIN is required';
          });
          isValid = false;
        }
        if (_batchLotController.text.trim().isEmpty) {
          _showError('Batch/Lot Number is required');
          isValid = false;
        }
        if (_commissioningLocationGLN == null) {
          setState(() {
            _locationError = 'Commissioning Location is required';
          });
          isValid = false;
        }
        return isValid;
      case 1:
        // Step 2: Validate serial numbers
        if (_serialNumbers.isEmpty) {
          _showError('At least one serial number is required');
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

  Future<void> _submitCommissioningOperation() async {
    if (!_validateCurrentStep()) return;

    setState(() => _isLoading = true);

    try {
      final commissioningService = getIt<CommissioningOperationService>();

      final gtinCode = _selectedGTIN?.gtinCode ?? _gtinController.text.trim();

      debugPrint(
        'Commissioning: Submitting ${_serialNumbers.length} serial numbers for GTIN $gtinCode',
      );

      final request = CommissioningRequest(
        gtinCode: gtinCode,
        serialNumbers: _serialNumbers,
        batchLotNumber: _batchLotController.text.trim(),
        commissioningLocationGLN: _commissioningLocationGLN!.glnCode,
        expiryDate: _expiryDate,
        productionDate: _productionDate,
        bestBeforeDate: _bestBeforeDate,
        commissioningReference: _referenceController.text.trim().isNotEmpty
            ? _referenceController.text.trim()
            : null,
        operatorId: _operatorIdController.text.trim().isNotEmpty
            ? _operatorIdController.text.trim()
            : null,
        comments: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      final response = await commissioningService.createCommissioningOperation(
        request,
      );

      if (response.status == CommissioningStatus.success) {
        _showSuccess(
          'Successfully commissioned ${response.commissionedCount} items',
        );
        if (mounted) {
          context.go('/operations/commissioning');
        }
      } else if (response.status == CommissioningStatus.partialSuccess) {
        _showPartialSuccessDialog(response);
      } else {
        final errorMessage = response.messages?.isNotEmpty == true
            ? response.messages!.first
            : 'Failed to create commissioning operation';
        _showError(errorMessage);
      }
    } catch (e) {
      _showError('Error creating commissioning operation: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showPartialSuccessDialog(CommissioningResponse response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Text('Partial Success'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Commissioned: ${response.commissionedCount}'),
              Text('Failed: ${response.failedCount}'),
              const SizedBox(height: 16),
              if (response.itemResults != null) ...[
                const Text(
                  'Failed Items:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView(
                    shrinkWrap: true,
                    children: response.itemResults!
                        .where((r) => !r.success)
                        .map(
                          (r) => ListTile(
                            dense: true,
                            leading: const Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 20,
                            ),
                            title: Text(r.serialNumber),
                            subtitle: Text(r.errorMessage ?? 'Unknown error'),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/operations/commissioning');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onSerialScanResult(ScanResult result) {
    if (result.isValid) {
      _addSerial(result.data);
    }
  }

  void _addSerial(String serial) {
    final trimmedSerial = serial.trim();
    if (trimmedSerial.isEmpty) {
      _showError('Please enter a serial number');
      return;
    }

    // Check for duplicates
    if (_serialNumbers.contains(trimmedSerial)) {
      _showError('Serial number already added: $trimmedSerial');
      return;
    }

    setState(() {
      _serialNumbers.add(trimmedSerial);
    });
    //_showSuccess('Serial added: $trimmedSerial');

    // Clear the input field
    _manualSerialController.clear();
    _wiredScannerController.clear();
  }

  void _removeSerial(int index) {
    setState(() {
      _serialNumbers.removeAt(index);
    });
  }

  void _clearAllSerials() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Serials?'),
        content: Text(
          'This will remove all ${_serialNumbers.length} serial numbers.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _serialNumbers.clear();
              });
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(String dateType) async {
    final now = DateTime.now();
    final initialDate = dateType == 'production'
        ? (_productionDate ?? now)
        : dateType == 'expiry'
        ? (_expiryDate ?? now.add(const Duration(days: 365)))
        : (_bestBeforeDate ?? now.add(const Duration(days: 180)));

    final firstDate = dateType == 'production' ? DateTime(now.year - 2) : now;
    final lastDate = DateTime(now.year + 10);

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText:
          'Select ${dateType == 'production'
              ? 'Production'
              : dateType == 'expiry'
              ? 'Expiry'
              : 'Best Before'} Date',
    );

    if (selected != null) {
      setState(() {
        switch (dateType) {
          case 'production':
            _productionDate = selected;
            break;
          case 'expiry':
            _expiryDate = selected;
            break;
          case 'bestBefore':
            _bestBeforeDate = selected;
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Commissioning'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _currentStep = 0;
                _serialNumbers.clear();
                _selectedGTIN = null;
                _gtinController.clear();
                _batchLotController.clear();
                _referenceController.clear();
                _commissioningLocationGLN = null;
                _expiryDate = null;
                _productionDate = null;
                _bestBeforeDate = null;
              });
              _pageController.jumpToPage(0);
            },
            tooltip: 'Reset Form',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            // Stepper header
            _buildStepperHeader(),
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() => _currentStep = page);
                },
                children: [
                  _buildStep1ReferenceDetails(),
                  _buildStep2SerialNumbers(),
                  _buildStep3Review(),
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

  Widget _buildStepperHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        children: [
          _buildStepCircle(0, 'Product', Icons.inventory_2),
          _buildStepConnector(0),
          _buildStepCircle(1, 'Serials', Icons.qr_code_scanner),
          _buildStepConnector(1),
          _buildStepCircle(2, 'Review', Icons.checklist),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label, IconData icon) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300],
              shape: BoxShape.circle,
              border: isCurrent
                  ? Border.all(color: Theme.of(context).primaryColor, width: 3)
                  : null,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey[600],
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int step) {
    final isActive = _currentStep > step;
    return Container(
      width: 40,
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // GTIN Selector/Input
                  const Text(
                    'GTIN *',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  if (_isLoadingGTINs)
                    const Center(child: CircularProgressIndicator())
                  else if (_availableGTINs.isNotEmpty) ...[
                    DropdownButtonFormField<GTIN>(
                      value: _selectedGTIN,
                      decoration: InputDecoration(
                        hintText: 'Select a GTIN',
                        border: const OutlineInputBorder(),
                        errorText: _gtinError,
                      ),
                      items: _availableGTINs.map((gtin) {
                        return DropdownMenuItem(
                          value: gtin,
                          child: Text(
                            '${gtin.gtinCode} - ${gtin.productName ?? 'Unknown'}',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGTIN = value;
                          _gtinError = null;
                        });
                      },
                    ),
                  ] else ...[
                    TextField(
                      controller: _gtinController,
                      decoration: InputDecoration(
                        hintText: 'Enter 14-digit GTIN',
                        border: const OutlineInputBorder(),
                        errorText: _gtinError,
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 14,
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Batch/Lot Number
                  TextField(
                    controller: _batchLotController,
                    decoration: const InputDecoration(
                      labelText: 'Batch/Lot Number *',
                      hintText: 'Enter batch or lot number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Commissioning Reference (optional)
                  TextField(
                    controller: _referenceController,
                    decoration: const InputDecoration(
                      labelText: 'Commissioning Reference',
                      hintText: 'Enter reference (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Location Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Commissioning Location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GLNSelector(
                    label: 'Location GLN *',
                    initialValue: _commissioningLocationGLN,
                    onChanged: (gln) {
                      setState(() {
                        _commissioningLocationGLN = gln;
                        _locationError = null;
                      });
                    },
                    hintText: 'Select commissioning location',
                    errorText: _locationError,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Dates Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dates (Optional)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Production Date
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Production Date'),
                    subtitle: Text(
                      _productionDate != null
                          ? '${_productionDate!.day}/${_productionDate!.month}/${_productionDate!.year}'
                          : 'Not set',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _selectDate('production'),
                        ),
                        if (_productionDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                setState(() => _productionDate = null),
                          ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // Expiry Date
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event),
                    title: const Text('Expiry Date'),
                    subtitle: Text(
                      _expiryDate != null
                          ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                          : 'Not set',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _selectDate('expiry'),
                        ),
                        if (_expiryDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _expiryDate = null),
                          ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // Best Before Date
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.schedule),
                    title: const Text('Best Before Date'),
                    subtitle: Text(
                      _bestBeforeDate != null
                          ? '${_bestBeforeDate!.day}/${_bestBeforeDate!.month}/${_bestBeforeDate!.year}'
                          : 'Not set',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _selectDate('bestBefore'),
                        ),
                        if (_bestBeforeDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                setState(() => _bestBeforeDate = null),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Additional Info Card (collapsed by default)
          ExpansionTile(
            title: const Text('Additional Information'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _operatorIdController,
                      decoration: const InputDecoration(
                        labelText: 'Operator ID',
                        hintText: 'Enter operator ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Enter any additional notes',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep2SerialNumbers() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product info summary
          Card(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GTIN: ${_selectedGTIN?.gtinCode ?? _gtinController.text}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Batch: ${_batchLotController.text}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Scanning mode selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Serial Numbers',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<ScanningMode>(
                    segments: [
                      if (!kIsWeb)
                        const ButtonSegment(
                          value: ScanningMode.camera,
                          icon: Icon(Icons.camera_alt),
                          label: Text('Camera'),
                        ),
                      const ButtonSegment(
                        value: ScanningMode.wired,
                        icon: Icon(Icons.keyboard),
                        label: Text('Scanner'),
                      ),
                      const ButtonSegment(
                        value: ScanningMode.manual,
                        icon: Icon(Icons.edit),
                        label: Text('Manual'),
                      ),
                    ],
                    selected: {_scanningMode},
                    onSelectionChanged: (Set<ScanningMode> selection) {
                      setState(() {
                        _scanningMode = selection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Input based on mode
                  if (_scanningMode == ScanningMode.camera && !kIsWeb)
                    SizedBox(
                      height: 200,
                      child: BarcodeScanner(
                        onScanResult: _onSerialScanResult,
                        height: 200,
                      ),
                    )
                  else if (_scanningMode == ScanningMode.wired)
                    Column(
                      children: [
                        TextField(
                          controller: _wiredScannerController,
                          focusNode: _wiredScannerFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Scan serial number with barcode scanner',
                            border: const OutlineInputBorder(),
                            prefixIcon: Icon(
                              Icons.keyboard,
                              color: _isWiredScannerActive
                                  ? Colors.green
                                  : null,
                            ),
                            suffixIcon: _isWiredScannerActive
                                ? const Icon(Icons.sensors, color: Colors.green)
                                : null,
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              _addSerial(value);
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isWiredScannerActive
                              ? '✓ Scanner active - scan barcode'
                              : 'Click the field to activate scanner input',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isWiredScannerActive
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _manualSerialController,
                            decoration: const InputDecoration(
                              hintText: 'Enter serial number',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                _addSerial(value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () =>
                              _addSerial(_manualSerialController.text),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Serial numbers list header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Serial Numbers (${_serialNumbers.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_serialNumbers.isNotEmpty)
                TextButton.icon(
                  onPressed: _clearAllSerials,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Serial numbers list
          Expanded(
            child: _serialNumbers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_2,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No serial numbers added yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scan or enter serial numbers to commission',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _serialNumbers.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(_serialNumbers[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => _removeSerial(index),
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

  Widget _buildStep3Review() {
    final gtinDisplay = _selectedGTIN != null
        ? '${_selectedGTIN!.gtinCode} - ${_selectedGTIN!.productName ?? 'Unknown'}'
        : _gtinController.text;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Commissioning Operation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Summary Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReviewRow('GTIN', gtinDisplay),
                  const Divider(),
                  _buildReviewRow('Batch/Lot', _batchLotController.text),
                  const Divider(),
                  _buildReviewRow(
                    'Location',
                    _commissioningLocationGLN?.locationName ??
                        _commissioningLocationGLN?.glnCode ??
                        '-',
                  ),
                  if (_referenceController.text.isNotEmpty) ...[
                    const Divider(),
                    _buildReviewRow('Reference', _referenceController.text),
                  ],
                  if (_productionDate != null) ...[
                    const Divider(),
                    _buildReviewRow(
                      'Production Date',
                      '${_productionDate!.day}/${_productionDate!.month}/${_productionDate!.year}',
                    ),
                  ],
                  if (_expiryDate != null) ...[
                    const Divider(),
                    _buildReviewRow(
                      'Expiry Date',
                      '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}',
                    ),
                  ],
                  if (_bestBeforeDate != null) ...[
                    const Divider(),
                    _buildReviewRow(
                      'Best Before',
                      '${_bestBeforeDate!.day}/${_bestBeforeDate!.month}/${_bestBeforeDate!.year}',
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Serial numbers summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.qr_code_2),
                      const SizedBox(width: 8),
                      Text(
                        'Serial Numbers (${_serialNumbers.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _serialNumbers.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                '${index + 1}. ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(child: Text(_serialNumbers[index])),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Info message
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Submitting will create ${_serialNumbers.length} SGTIN(s) with status "COMMISSIONED" and generate corresponding ObjectEvent(s) for EPCIS 2.0 compliance.',
                      style: TextStyle(color: Colors.blue[900]),
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

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
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
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousStep,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: _currentStep < 2
                ? ElevatedButton.icon(
                    onPressed: _nextStep,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                  )
                : ElevatedButton.icon(
                    onPressed: _submitCommissioningOperation,
                    icon: const Icon(Icons.check),
                    label: Text('Commission ${_serialNumbers.length} Items'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
