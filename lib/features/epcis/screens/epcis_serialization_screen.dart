import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/data/services/epcis_serialization_service.dart';
import 'package:traqtrace_app/features/epcis/models/epcis_query_parameters_dto.dart';

class EPCISSerializationScreen extends StatefulWidget {
  final AppConfig appConfig;
  
  const EPCISSerializationScreen({
    super.key,
    required this.appConfig,
  });

  @override
  State<EPCISSerializationScreen> createState() => _EPCISSerializationScreenState();
}

class _EPCISSerializationScreenState extends State<EPCISSerializationScreen>
    with SingleTickerProviderStateMixin {
  
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  final TextEditingController _validationInputController = TextEditingController();
  final TextEditingController _importInputController = TextEditingController();
  
  late TabController _tabController;
  late EPCISSerializationService _serializationService;
  bool _isLoading = false;
  String? _errorMessage;
  String? _validationErrorMessage;
  String? _exportErrorMessage;
  String? _importErrorMessage;
  String _selectedInputFormat = 'XML';
  String _selectedOutputFormat = 'JSON-LD';
  
  final List<String> _formats = ['XML', 'JSON-LD', 'CSV', 'PDF', 'HTML'];
  
  // Export filter state variables
  String _startDateFilter = '';
  String _endDateFilter = '';
  String _epcFilter = '';
  String _businessStepFilter = '';
  String _locationFilter = '';
  String _limitFilter = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    _serializationService = getIt<EPCISSerializationService>();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    _validationInputController.dispose();
    _importInputController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('EPCIS Serialization & Format Conversion'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Format Conversion'),
              Tab(text: 'Validation'),
              Tab(text: 'Export'),
              Tab(text: 'Import'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFormatConversionTab(),
                _buildValidationTab(),
                _buildExportTab(),
                _buildImportTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatConversionTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Format Conversion',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedInputFormat,
                          decoration: const InputDecoration(
                            labelText: 'Input Format',
                            border: OutlineInputBorder(),
                          ),
                          items: _formats.map((format) {
                            return DropdownMenuItem(
                              value: format,
                              child: Text(format),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedInputFormat = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.arrow_forward),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedOutputFormat,
                          decoration: const InputDecoration(
                            labelText: 'Output Format',
                            border: OutlineInputBorder(),
                          ),
                          items: _formats.map((format) {
                            return DropdownMenuItem(
                              value: format,
                              child: Text(format),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedOutputFormat = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Input ($_selectedInputFormat)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => _loadSampleData(),
                            icon: const Icon(Icons.data_object),
                            label: const Text('Load Sample'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          maxLines: null,
                          expands: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Paste your EPCIS data here...',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _convertFormat,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.transform),
                      label: const Text('Convert'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _clearAll(),
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Output ($_selectedOutputFormat)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _outputController.text.isNotEmpty
                                ? () => _copyToClipboard(_outputController.text)
                                : null,
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TextField(
                          controller: _outputController,
                          maxLines: null,
                          expands: true,
                          readOnly: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Converted data will appear here...',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_errorMessage != null)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade600),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _errorMessage = null),
                    icon: const Icon(Icons.close),
                    color: Colors.red.shade600,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildValidationTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Schema Validation',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('Validate EPCIS documents against standard schemas'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _validateSchema('XML'),
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle),
                        label: const Text('Validate XML (EPCIS 1.3)'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _validateSchema('JSON'),
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle),
                        label: const Text('Validate JSON (EPCIS 2.0)'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _validationInputController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'EPCIS Document to Validate',
                hintText: 'Paste your EPCIS document here...',
              ),
            ),
          ),
          if (_validationErrorMessage != null)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _validationErrorMessage!,
                      style: TextStyle(color: Colors.red.shade600),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _validationErrorMessage = null),
                    icon: const Icon(Icons.close),
                    color: Colors.red.shade600,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExportTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Export Events - Query Filters',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text('Configure filters to select which EPCIS events to export'),
                    const SizedBox(height: 16),
                    
                    // Date Range Filter
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Start Date (Optional)',
                              hintText: '2025-01-01T00:00:00Z',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              _startDateFilter = value;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'End Date (Optional)',
                              hintText: '2025-12-31T23:59:59Z',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              _endDateFilter = value;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // EPC Filter
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'EPCs (Optional)',
                        hintText: 'Enter EPCs separated by commas (e.g., urn:epc:id:sgtin:0614141.812345.400)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _epcFilter = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Business Step Filter
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Business Steps (Optional)',
                        hintText: 'Enter business steps separated by commas (e.g., receiving, shipping)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _businessStepFilter = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Location Filter
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Business Locations (Optional)',
                        hintText: 'Enter GLN codes separated by commas (e.g., 1234567890123)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _locationFilter = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Limit Filter
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Max Results (Optional)',
                        hintText: 'Enter maximum number of events to export (e.g., 1000)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _limitFilter = value;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Export to Format',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text('Select format and click to export the filtered events'),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : () => _exportEvents('CSV'),
                          icon: const Icon(Icons.table_chart),
                          label: const Text('Export to CSV'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : () => _exportEvents('PDF'),
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Export to PDF'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : () => _exportEvents('HTML'),
                          icon: const Icon(Icons.web),
                          label: const Text('Export to HTML'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : () => _exportEvents('EXCEL'),
                          icon: const Icon(Icons.grid_on),
                          label: const Text('Export to Excel'),
                        ),
                      ],
                    ),
                    if (_isLoading) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                      const SizedBox(height: 8),
                      const Text('Exporting events...'),
                    ],
                  ],
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Export Error',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImportTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Import EPCIS Events',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Import EPCIS events into the database. Paste XML or JSON-LD EPCIS documents containing events to be stored in the system.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _importEvents('XML'),
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.cloud_upload),
                        label: const Text('Import XML Events'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _importEvents('JSON-LD'),
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.cloud_upload),
                        label: const Text('Import JSON-LD Events'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _loadImportSampleData(),
                        icon: const Icon(Icons.data_object),
                        label: const Text('Load Sample'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'EPCIS Document to Import',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TextField(
                          controller: _importInputController,
                          maxLines: null,
                          expands: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Paste your EPCIS document here...\n\nThis will import all events contained in the document into the database.',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Import Results',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TextField(
                          controller: _outputController,
                          maxLines: null,
                          expands: true,
                          readOnly: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Import results and statistics will appear here...',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_importErrorMessage != null)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _importErrorMessage!,
                      style: TextStyle(color: Colors.red.shade600),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _importErrorMessage = null),
                    icon: const Icon(Icons.close),
                    color: Colors.red.shade600,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _convertFormat() async {
    if (_inputController.text.isEmpty) {
      _showError('Please enter input data to convert');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String result;
      
      if (_selectedInputFormat == 'XML' && _selectedOutputFormat == 'JSON-LD') {
        final jsonLdResult = await _serializationService.convertXmlToJsonLd(_inputController.text);
        result = const JsonEncoder.withIndent('  ').convert(jsonLdResult);
      } else if (_selectedInputFormat == 'JSON-LD' && _selectedOutputFormat == 'XML') {
        try {
          final jsonInput = jsonDecode(_inputController.text) as Map<String, dynamic>;
          result = await _serializationService.convertJsonLdToXml(jsonInput);
        } catch (e) {
          throw Exception('Invalid JSON format in input');
        }
      } else {
        throw Exception('Conversion from $_selectedInputFormat to $_selectedOutputFormat is not supported yet');
      }

      _outputController.text = result;

    } catch (e) {
      _showError('Conversion failed: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _validateSchema(String format) async {
    if (_validationInputController.text.isEmpty) {
      _showValidationError('Please enter data to validate');
      return;
    }

    setState(() {
      _isLoading = true;
      _validationErrorMessage = null;
    });

    try {
      Map<String, dynamic> response;

      if (format == 'XML') {
        response = await _serializationService.validateXmlSchema(_validationInputController.text);
      } else {
        try {
          final jsonInput = jsonDecode(_validationInputController.text) as Map<String, dynamic>;
          response = await _serializationService.validateJsonSchema(jsonInput);
        } catch (e) {
          throw Exception('Invalid JSON format in input');
        }
      }
      
      _outputController.text = const JsonEncoder.withIndent('  ').convert(response);
      
      if (response['valid'] == true) {
        _showSuccess('Document is valid according to EPCIS $format schema');
      } else {
        _showValidationError('Document validation failed: ${response['errors'].join(', ')}');
      }

    } catch (e) {
      _showValidationError('Validation failed: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportEvents(String format) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Build query parameters from filter inputs
      DateTime? startTime;
      DateTime? endTime;
      List<String> epcs = [];
      List<String> businessSteps = [];
      List<String> businessLocations = [];
      int? limit;

      // Parse start date
      if (_startDateFilter.isNotEmpty) {
        try {
          startTime = DateTime.parse(_startDateFilter);
        } catch (e) {
          throw Exception('Invalid start date format. Use ISO 8601 format (e.g., 2025-01-01T00:00:00Z)');
        }
      }

      // Parse end date
      if (_endDateFilter.isNotEmpty) {
        try {
          endTime = DateTime.parse(_endDateFilter);
        } catch (e) {
          throw Exception('Invalid end date format. Use ISO 8601 format (e.g., 2025-12-31T23:59:59Z)');
        }
      }

      // Parse EPCs
      if (_epcFilter.isNotEmpty) {
        epcs = _epcFilter.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }

      // Parse business steps
      if (_businessStepFilter.isNotEmpty) {
        businessSteps = _businessStepFilter.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }

      // Parse business locations
      if (_locationFilter.isNotEmpty) {
        businessLocations = _locationFilter.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }

      // Parse limit
      if (_limitFilter.isNotEmpty) {
        try {
          limit = int.parse(_limitFilter);
          if (limit <= 0) {
            throw Exception('Limit must be a positive number');
          }
        } catch (e) {
          throw Exception('Invalid limit format. Enter a positive number');
        }
      }

      final queryParams = EPCISQueryParametersDTO(
        startTime: startTime,
        endTime: endTime,
        epcs: epcs.isNotEmpty ? epcs : null,
        businessSteps: businessSteps.isNotEmpty ? businessSteps : null,
        businessLocations: businessLocations.isNotEmpty ? businessLocations : null,
        dispositions: [],
        readPoints: [],
        limit: limit,
      );

      String result;
      List<int>? binaryResult;
      
      switch (format.toLowerCase()) {
        case 'csv':
          result = await _serializationService.exportToCsv(queryParams);
          _outputController.text = result;
          _showSuccess('Events exported to CSV format successfully. ${result.split('\n').length - 1} events exported.');
          break;
        case 'html':
          result = await _serializationService.exportToHtml(queryParams);
          _outputController.text = result;
          _showSuccess('Events exported to HTML format successfully');
          break;
        case 'pdf':
          binaryResult = await _serializationService.exportToPdf(queryParams);
          _outputController.text = 'PDF exported successfully (${binaryResult.length} bytes). Binary data cannot be displayed in text format.';
          _showSuccess('Events exported to PDF format successfully. ${binaryResult.length} bytes generated.');
          break;
        case 'excel':
          binaryResult = await _serializationService.exportToExcel(queryParams);
          _outputController.text = 'Excel exported successfully (${binaryResult.length} bytes). Binary data cannot be displayed in text format.';
          _showSuccess('Events exported to Excel format successfully. ${binaryResult.length} bytes generated.');
          break;
        default:
          throw Exception('Export format $format is not supported');
      }

    } catch (e) {
      _showError('Export failed: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _importEvents(String format) async {
    if (_importInputController.text.isEmpty) {
      _showImportError('Please enter EPCIS document to import');
      return;
    }

    setState(() {
      _isLoading = true;
      _importErrorMessage = null;
    });

    try {
      Map<String, dynamic> result;

      if (format == 'XML') {
        result = await _serializationService.importEventsFromXml(_importInputController.text);
      } else {
        try {
          final jsonInput = jsonDecode(_importInputController.text) as Map<String, dynamic>;
          result = await _serializationService.importEventsFromJsonLd(jsonInput);
        } catch (e) {
          throw Exception('Invalid JSON format in input');
        }
      }
      
      _outputController.text = const JsonEncoder.withIndent('  ').convert(result);
      
      final eventsImported = result['eventsImported'] ?? result['totalEvents'] ?? 0;
      final eventsSkipped = result['eventsSkipped'] ?? result['duplicates'] ?? 0;
      final errors = result['errors'] ?? [];
      
      if (errors.isNotEmpty) {
        _showImportError('Import completed with errors: ${errors.join(', ')}');
      } else {
        _showSuccess('Successfully imported $eventsImported events into the database${eventsSkipped > 0 ? ' ($eventsSkipped duplicates skipped)' : ''}');
      }

    } catch (e) {
      _showImportError('Import failed: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadImportSampleData() {
    _importInputController.text = '''{
  "@context": "https://gs1.github.io/EPCIS/epcis-context.jsonld",
  "type": "EPCISDocument",
  "schemaVersion": "2.0",
  "creationDate": "2025-07-19T12:00:00Z",
  "epcisBody": {
    "eventList": [
      {
        "type": "ObjectEvent",
        "eventTime": "2025-07-19T10:30:00Z",
        "epcList": ["urn:epc:id:sgtin:0614141.107346.2025"],
        "action": "OBSERVE",
        "bizStep": "urn:epcglobal:cbv:bizstep:receiving",
        "disposition": "urn:epcglobal:cbv:disp:in_progress",
        "readPoint": {
          "id": "urn:epc:id:sgln:0614141.07346.1234"
        },
        "bizLocation": {
          "id": "urn:epc:id:sgln:0614141.07346.0"
        }
      },
      {
        "type": "ObjectEvent",
        "eventTime": "2025-07-19T11:15:00Z",
        "epcList": ["urn:epc:id:sgtin:0614141.107346.2026"],
        "action": "OBSERVE",
        "bizStep": "urn:epcglobal:cbv:bizstep:shipping",
        "disposition": "urn:epcglobal:cbv:disp:in_transit",
        "readPoint": {
          "id": "urn:epc:id:sgln:0614141.07346.5678"
        },
        "bizLocation": {
          "id": "urn:epc:id:sgln:0614141.07346.0"
        }
      }
    ]
  }
}''';
  }

  void _loadSampleData() {
    if (_selectedInputFormat == 'XML') {
      _inputController.text = '''<?xml version="1.0" encoding="UTF-8"?>
<epcis:EPCISDocument xmlns:epcis="urn:epcglobal:epcis:xsd:1" schemaVersion="1.3">
  <EPCISBody>
    <EventList>
      <ObjectEvent>
        <eventTime>2023-01-01T12:00:00Z</eventTime>
        <epcList>
          <epc>urn:epc:id:sgtin:0614141.107346.2017</epc>
        </epcList>
        <action>OBSERVE</action>
        <bizStep>urn:epcglobal:cbv:bizstep:receiving</bizStep>
        <disposition>urn:epcglobal:cbv:disp:in_progress</disposition>
        <readPoint>
          <id>urn:epc:id:sgln:0614141.07346.1234</id>
        </readPoint>
      </ObjectEvent>
    </EventList>
  </EPCISBody>
</epcis:EPCISDocument>''';
    } else {
      _inputController.text = '''{
  "@context": "https://gs1.github.io/EPCIS/epcis-context.jsonld",
  "type": "EPCISDocument",
  "schemaVersion": "2.0",
  "creationDate": "2023-01-01T12:00:00Z",
  "epcisBody": {
    "eventList": [
      {
        "type": "ObjectEvent",
        "eventTime": "2023-01-01T12:00:00Z",
        "epcList": ["urn:epc:id:sgtin:0614141.107346.2017"],
        "action": "OBSERVE",
        "bizStep": "urn:epcglobal:cbv:bizstep:receiving",
        "disposition": "urn:epcglobal:cbv:disp:in_progress",
        "readPoint": {
          "id": "urn:epc:id:sgln:0614141.07346.1234"
        }
      }
    ]
  }
}''';
    }
  }

  void _clearAll() {
    setState(() {
      _inputController.clear();
      _outputController.clear();
      _validationInputController.clear();
      _importInputController.clear();
      _errorMessage = null;
      _validationErrorMessage = null;
      _exportErrorMessage = null;
      _importErrorMessage = null;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _showValidationError(String message) {
    setState(() {
      _validationErrorMessage = message;
    });
  }

  void _showImportError(String message) {
    setState(() {
      _importErrorMessage = message;
    });
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}
