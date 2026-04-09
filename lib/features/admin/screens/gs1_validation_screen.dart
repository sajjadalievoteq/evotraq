import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/shared/utils/gs1_validator.dart';
import 'package:traqtrace_app/shared/widgets/app_loading_indicator.dart';

class GS1ValidationScreen extends StatefulWidget {
  const GS1ValidationScreen({Key? key}) : super(key: key);

  @override
  State<GS1ValidationScreen> createState() => _GS1ValidationScreenState();
}

class _GS1ValidationScreenState extends State<GS1ValidationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _gtinController = TextEditingController();
  final _glnController = TextEditingController();
  final _ssccController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _epcUriController = TextEditingController();
  final _barcodeDataController = TextEditingController();
  
  Map<String, ValidationResult> _validationResults = {};
  bool _isRunningBatchTests = false;

  @override
  void dispose() {
    _gtinController.dispose();
    _glnController.dispose();
    _ssccController.dispose();
    _serialNumberController.dispose();
    _epcUriController.dispose();
    _barcodeDataController.dispose();
    super.dispose();
  }
  
  Future<void> _runBatchValidationTests() async {
    setState(() {
      _isRunningBatchTests = true;
    });
    
    try {
      // Artificially delay to show loading
      await Future.delayed(const Duration(milliseconds: 800));
      
      final results = <String, ValidationResult>{};
      
      // Run all the unit tests programmatically
      
      // GTIN Tests - aligned with backend GS1ValidationUtilTest
      results['GTIN Valid 1'] = ValidationResult(
        isValid: GS1Validator.isValidGTIN('12345678901231'),
        testType: 'GTIN',
        value: '12345678901231',
        message: 'Valid GTIN-14',
      );
      
      results['GTIN Valid 2'] = ValidationResult(
        isValid: GS1Validator.isValidGTIN('50614141123458'),
        testType: 'GTIN',
        value: '50614141123458',
        message: 'Valid GTIN-14 with company prefix',
      );
      
      results['GTIN Invalid Length'] = ValidationResult(
        isValid: !GS1Validator.isValidGTIN('1234567890123'),
        testType: 'GTIN',
        value: '1234567890123',
        message: 'Invalid length (too short)',
      );
      
      results['GTIN Non-numeric'] = ValidationResult(
        isValid: !GS1Validator.isValidGTIN('1234567890123A'),
        testType: 'GTIN',
        value: '1234567890123A',
        message: 'Contains non-numeric characters',
      );
      
      results['GTIN Invalid Checksum'] = ValidationResult(
        isValid: !GS1Validator.isValidGTIN('12345678901232'),
        testType: 'GTIN',
        value: '12345678901232',
        message: 'Invalid check digit',
      );
      
      // GLN Tests - aligned with backend GS1ValidationUtilTest
      results['GLN Valid 1'] = ValidationResult(
        isValid: GS1Validator.isValidGLN('1234567890128'),
        testType: 'GLN',
        value: '1234567890128',
        message: 'Valid GLN-13',
      );
      
      results['GLN Valid 2'] = ValidationResult(
        isValid: GS1Validator.isValidGLN('6141411000005'),
        testType: 'GLN',
        value: '6141411000005',
        message: 'Valid GLN-13 with company prefix',
      );
      
      results['GLN Invalid Length'] = ValidationResult(
        isValid: !GS1Validator.isValidGLN('123456789012'),
        testType: 'GLN',
        value: '123456789012',
        message: 'Invalid length (too short)',
      );
      
      results['GLN Invalid Checksum'] = ValidationResult(
        isValid: !GS1Validator.isValidGLN('1234567890127'),
        testType: 'GLN',
        value: '1234567890127',
        message: 'Invalid check digit',
      );
      
      // SSCC Tests - aligned with backend GS1ValidationUtilTest
      // Testing the same value as in the backend GS1ValidationUtilTest
      results['SSCC Valid'] = ValidationResult(
        isValid: GS1Validator.isValidSSCC('106141411234567895'),
        testType: 'SSCC',
        value: '106141411234567895',
        message: 'Valid SSCC-18',
      );
      
      results['SSCC Invalid Length'] = ValidationResult(
        isValid: !GS1Validator.isValidSSCC('10614141123456789'),
        testType: 'SSCC',
        value: '10614141123456789',
        message: 'Invalid length (too short)',
      );
      
      results['SSCC Invalid Checksum'] = ValidationResult(
        isValid: !GS1Validator.isValidSSCC('106141411234567896'),
        testType: 'SSCC',
        value: '106141411234567896',
        message: 'Invalid check digit',
      );
      
      // SGTIN Tests - aligned with backend GS1ValidationUtilTest
      // Using the exact same values as in the backend GS1ValidationUtilTest
      results['SGTIN Valid 1'] = ValidationResult(
        isValid: GS1Validator.isValidSGTIN('50614141123458', 'ABC123'),
        testType: 'SGTIN',
        value: '50614141123458 + ABC123',
        message: 'Valid GTIN with serial number',
      );
      
      results['SGTIN Valid 2'] = ValidationResult(
        isValid: GS1Validator.isValidSGTIN('12345678901231', '123456789'),
        testType: 'SGTIN',
        value: '12345678901231 + 123456789',
        message: 'Valid GTIN with numeric serial',
      );
      
      results['SGTIN Invalid GTIN'] = ValidationResult(
        isValid: !GS1Validator.isValidSGTIN('12345678901232', 'ABC123'),
        testType: 'SGTIN',
        value: '12345678901232 + ABC123',
        message: 'Invalid GTIN checksum',
      );
      
      results['SGTIN Empty Serial'] = ValidationResult(
        isValid: !GS1Validator.isValidSGTIN('12345678901231', ''),
        testType: 'SGTIN',
        value: '12345678901231 + ""',
        message: 'Empty serial number',
      );
      
      // EPC URI Tests
      results['EPC URI Valid SGTIN'] = ValidationResult(
        isValid: GS1Validator.isValidEPCURI('urn:epc:id:sgtin:0614141.112345.ABC123'),
        testType: 'EPC URI',
        value: 'urn:epc:id:sgtin:0614141.112345.ABC123',
        message: 'Valid SGTIN EPC URI',
      );
      
      results['EPC URI Valid SSCC'] = ValidationResult(
        isValid: GS1Validator.isValidEPCURI('urn:epc:id:sscc:0614141.1234567890'),
        testType: 'EPC URI',
        value: 'urn:epc:id:sscc:0614141.1234567890',
        message: 'Valid SSCC EPC URI',
      );
      
      results['EPC URI Valid Pattern'] = ValidationResult(
        isValid: GS1Validator.isValidEPCURI('urn:epc:idpat:sgtin:0614141.112345.*'),
        testType: 'EPC URI',
        value: 'urn:epc:idpat:sgtin:0614141.112345.*',
        message: 'Valid EPC pattern URI',
      );
      
      results['EPC URI Invalid Namespace'] = ValidationResult(
        isValid: !GS1Validator.isValidEPCURI('urn:gs1:id:sgtin:0614141.112345.ABC123'),
        testType: 'EPC URI',
        value: 'urn:gs1:id:sgtin:0614141.112345.ABC123',
        message: 'Wrong namespace',
      );
      
      results['EPC URI Missing urn'] = ValidationResult(
        isValid: !GS1Validator.isValidEPCURI('sgtin:0614141.112345.ABC123'),
        testType: 'EPC URI',
        value: 'sgtin:0614141.112345.ABC123',
        message: 'Missing urn prefix',
      );
      
      // Barcode Data Tests - simplified because the frontend implementation is simpler
      results['Barcode Valid Single AI'] = ValidationResult(
        isValid: GS1Validator.validateBarcodeData('(01)12345678901231') == null,
        testType: 'Barcode',
        value: '(01)12345678901231',
        message: 'Valid GS1 barcode data with single AI',
      );
      
      results['Barcode Valid Multiple AI'] = ValidationResult(
        isValid: GS1Validator.validateBarcodeData('(01)12345678901231(21)ABC123(10)LOT1234') == null,
        testType: 'Barcode',
        value: '(01)12345678901231(21)ABC123(10)LOT1234',
        message: 'Valid GS1 barcode data with multiple AIs',
      );
      
      results['Barcode Invalid Format'] = ValidationResult(
        isValid: GS1Validator.validateBarcodeData('0112345678901231') != null,
        testType: 'Barcode',
        value: '0112345678901231',
        message: 'Missing Application Identifiers',
      );
      
      setState(() {
        _validationResults = results;
        _isRunningBatchTests = false;
      });
    } catch (e) {
      setState(() {
        _isRunningBatchTests = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error running tests: ${e.toString()}')),
      );
    }
  }

  void _validateSingle(String type) {
    setState(() {
      switch (type) {
        case 'GTIN':
          final value = _gtinController.text;
          _validationResults['Manual GTIN Test'] = ValidationResult(
            isValid: GS1Validator.isValidGTIN(value),
            testType: 'GTIN',
            value: value,
            message: value.isEmpty ? 'Empty value' : 'Manual test',
          );
          break;
          
        case 'GLN':
          final value = _glnController.text;
          _validationResults['Manual GLN Test'] = ValidationResult(
            isValid: GS1Validator.isValidGLN(value),
            testType: 'GLN',
            value: value,
            message: value.isEmpty ? 'Empty value' : 'Manual test',
          );
          break;
          
        case 'SSCC':
          final value = _ssccController.text;
          _validationResults['Manual SSCC Test'] = ValidationResult(
            isValid: GS1Validator.isValidSSCC(value),
            testType: 'SSCC',
            value: value,
            message: value.isEmpty ? 'Empty value' : 'Manual test',
          );
          break;
          
        case 'SGTIN':
          final gtin = _gtinController.text;
          final serial = _serialNumberController.text;
          _validationResults['Manual SGTIN Test'] = ValidationResult(
            isValid: GS1Validator.isValidSGTIN(gtin, serial),
            testType: 'SGTIN',
            value: '$gtin + $serial',
            message: gtin.isEmpty || serial.isEmpty ? 'Missing values' : 'Manual test',
          );
          break;
          
        case 'EPC_URI':
          final value = _epcUriController.text;
          _validationResults['Manual EPC URI Test'] = ValidationResult(
            isValid: GS1Validator.isValidEPCURI(value),
            testType: 'EPC URI',
            value: value,
            message: value.isEmpty ? 'Empty value' : 'Manual test',
          );
          break;
          
        case 'BARCODE':
          final value = _barcodeDataController.text;
          final error = GS1Validator.validateBarcodeData(value);
          _validationResults['Manual Barcode Test'] = ValidationResult(
            isValid: error == null,
            testType: 'Barcode',
            value: value,
            message: error ?? (value.isEmpty ? 'Empty value' : 'Valid barcode data'),
          );
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GS1 Validation Testing'),
      ),
      drawer: const AppDrawer(),
      body: _isRunningBatchTests
          ? const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppLoadingIndicator(),
                SizedBox(height: 16),
                Text('Running GS1 validation tests...', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GS1 Standards Validation Tests',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'This tool verifies that all GS1 validation logic implemented in the frontend matches the backend standards. Run the batch tests to validate all standards at once or test individual identifiers below.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  
                  // Batch test button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _runBatchValidationTests,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow),
                          SizedBox(width: 8),
                          Text('Run Batch Validation Tests'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  
                  // Manual test form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Manual Testing',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // GTIN
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _gtinController,
                                decoration: const InputDecoration(
                                  labelText: 'GTIN (14 digits)',
                                  helperText: 'Example: 12345678901231',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 56, // Match text field height
                                child: ElevatedButton(
                                  onPressed: () => _validateSingle('GTIN'),
                                  child: const Text('Validate'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // GLN
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _glnController,
                                decoration: const InputDecoration(
                                  labelText: 'GLN (13 digits)',
                                  helperText: 'Example: 1234567890128',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 56, // Match text field height
                                child: ElevatedButton(
                                  onPressed: () => _validateSingle('GLN'),
                                  child: const Text('Validate'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // SSCC
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _ssccController,
                                decoration: const InputDecoration(
                                  labelText: 'SSCC (18 digits)',
                                  helperText: 'Example: 106141411234567895',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 56, // Match text field height
                                child: ElevatedButton(
                                  onPressed: () => _validateSingle('SSCC'),
                                  child: const Text('Validate'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // SGTIN (GTIN + Serial)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('SGTIN (GTIN + Serial Number)'),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: _serialNumberController,
                                    decoration: const InputDecoration(
                                      labelText: 'Serial Number',
                                      helperText: 'Example: ABC123',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 1,
                                  child: SizedBox(
                                    height: 56, // Match text field height
                                    child: ElevatedButton(
                                      onPressed: () => _validateSingle('SGTIN'),
                                      child: const Text('Validate'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // EPC URI
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _epcUriController,
                                decoration: const InputDecoration(
                                  labelText: 'EPC URI',
                                  helperText: 'Example: urn:epc:id:sgtin:0614141.112345.ABC123',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 56, // Match text field height
                                child: ElevatedButton(
                                  onPressed: () => _validateSingle('EPC_URI'),
                                  child: const Text('Validate'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Barcode Data
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _barcodeDataController,
                                decoration: const InputDecoration(
                                  labelText: 'GS1 Barcode Data',
                                  helperText: 'Example: (01)12345678901231(21)ABC123',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 56, // Match text field height
                                child: ElevatedButton(
                                  onPressed: () => _validateSingle('BARCODE'),
                                  child: const Text('Validate'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Results section
                  if (_validationResults.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 10),
                    const Text(
                      'Validation Results',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Results table
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DataTable(
                        columnSpacing: 20,
                        headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
                        columns: const [
                          DataColumn(label: Text('Test', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Value', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Result', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _validationResults.entries.map((entry) {
                          final result = entry.value;
                          return DataRow(
                            cells: [
                              DataCell(Text(entry.key)),
                              DataCell(Text(result.testType)),
                              DataCell(Text(
                                result.value, 
                                overflow: TextOverflow.ellipsis,
                              )),
                              DataCell(Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: result.isValid ? Colors.green.shade100 : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      result.isValid ? Icons.check_circle : Icons.error,
                                      size: 16,
                                      color: result.isValid ? Colors.green : Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      result.isValid ? 'Pass' : 'Fail',
                                      style: TextStyle(
                                        color: result.isValid ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    
                    // Results message
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _allTestsPassed() ? Colors.green.shade50 : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _allTestsPassed() ? Colors.green : Colors.orange,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _allTestsPassed() 
                                    ? Icons.check_circle 
                                    : Icons.warning,
                                color: _allTestsPassed() ? Colors.green : Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _allTestsPassed()
                                    ? 'All validation tests passed successfully!'
                                    : 'Some validation tests failed.',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _allTestsPassed() ? Colors.green : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _allTestsPassed()
                                ? 'The GS1 validator implementation in the frontend correctly matches the expected behavior and is aligned with the backend implementation.'
                                : 'There may be discrepancies between frontend and backend validation rules. Check the failed tests for details.',
                          ),
                          if (!_allTestsPassed()) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Action required: Review the failed tests and update the validation logic to ensure consistency between frontend and backend.',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
  
  bool _allTestsPassed() {
    return _validationResults.values.every((result) => result.isValid);
  }
}

class ValidationResult {
  final bool isValid;
  final String testType;
  final String value;
  final String message;
  
  ValidationResult({
    required this.isValid,
    required this.testType,
    required this.value,
    required this.message,
  });
}
