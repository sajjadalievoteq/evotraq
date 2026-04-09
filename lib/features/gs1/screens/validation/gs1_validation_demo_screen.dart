import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/epcis/widgets/validated_text_field.dart';
import 'package:traqtrace_app/features/gs1/mixins/gs1_form_validation_mixin.dart';

/// A demo screen showcasing all GS1 validation capabilities.
/// This screen can be used for testing and demonstrating various GS1 validations.
class GS1ValidationDemoScreen extends StatefulWidget {
  const GS1ValidationDemoScreen({Key? key}) : super(key: key);

  @override
  State<GS1ValidationDemoScreen> createState() => _GS1ValidationDemoScreenState();
}

class _GS1ValidationDemoScreenState extends State<GS1ValidationDemoScreen> 
    with GS1FormValidationMixin<GS1ValidationDemoScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _gtinController = TextEditingController();
  final _glnController = TextEditingController();
  final _ssccController = TextEditingController();
  final _sgtinController = TextEditingController();
  final _companyPrefixController = TextEditingController();
  final _itemReferenceController = TextEditingController();
  final _applicationIdentifierController = TextEditingController();
  final _aiValueController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _gs1DateController = TextEditingController();
  
  String _selectedAI = '01'; // Default to GTIN AI
  bool _validationPassed = false;
  
  final _aiOptions = [
    {'code': '00', 'name': 'SSCC'},
    {'code': '01', 'name': 'GTIN'},
    {'code': '10', 'name': 'Batch/Lot'},
    {'code': '17', 'name': 'Expiration Date'},
    {'code': '21', 'name': 'Serial Number'},
    {'code': '414', 'name': 'GLN'},
  ];
  
  @override
  void dispose() {
    _gtinController.dispose();
    _glnController.dispose();
    _ssccController.dispose();
    _sgtinController.dispose();
    _companyPrefixController.dispose();
    _itemReferenceController.dispose();
    _applicationIdentifierController.dispose();
    _aiValueController.dispose();
    _barcodeController.dispose();
    _gs1DateController.dispose();
    super.dispose();
  }
  
  void _validateAll() {
    final allValidators = {
      'gtin': {'value': _gtinController.text, 'validator': validateGTIN},
      'gln': {'value': _glnController.text, 'validator': validateGLN},
      'sscc': {'value': _ssccController.text, 'validator': validateSSCC},
      'sgtin': {'value': _sgtinController.text, 'validator': validateSGTIN},
      'companyPrefix': {'value': _companyPrefixController.text, 'validator': validateCompanyPrefix},
      'itemReference': {'value': _itemReferenceController.text, 'validator': validateItemReference},
      'aiValue': {'value': _aiValueController.text, 'validator': (value) => validateGS1ApplicationIdentifier(value, _selectedAI)},
      'barcode': {'value': _barcodeController.text, 'validator': validateGS1Barcode},
      'gs1Date': {'value': _gs1DateController.text, 'validator': validateGS1Date},
    };
    
    final isValid = validateAllFields(allValidators);
    setState(() {
      _validationPassed = isValid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GS1 Validation Demo'),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Test GS1 Validations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // GTIN Validation
              _buildSection(
                'GTIN Validation',
                'Enter a GTIN to validate (e.g., 12345678901231)',
                _gtinController,
                'gtin',
              ),
              
              // GLN Validation
              _buildSection(
                'GLN Validation',
                'Enter a GLN to validate (e.g., 1234567890128)',
                _glnController,
                'gln',
              ),
              
              // SSCC Validation
              _buildSection(
                'SSCC Validation', 
                'Enter an SSCC to validate (e.g., 106141411234567895)',
                _ssccController,
                'sscc',
              ),
              
              // SGTIN Validation
              _buildSection(
                'SGTIN Validation',
                'Enter a SGTIN to validate (e.g., urn:epc:id:sgtin:...)',
                _sgtinController,
                'sgtin',
              ),
              
              // GS1 Company Prefix Validation
              _buildSection(
                'Company Prefix Validation',
                'Enter a GS1 Company Prefix (e.g., 614141)',
                _companyPrefixController,
                'companyPrefix',
              ),
              
              // Item Reference Validation
              _buildSection(
                'Item Reference Validation',
                'Enter an Item Reference (e.g., 12345)',
                _itemReferenceController,
                'itemReference',
              ),
              
              // Application Identifier Validation
              _buildAISection(),
              
              // GS1 Barcode Validation
              _buildSection(
                'GS1 Barcode Validation',
                'Enter a GS1 barcode (e.g., (01)12345678901231(10)ABC123)',
                _barcodeController,
                'barcode',
              ),
              
              // GS1 Date Validation
              _buildSection(
                'GS1 Date Validation (YYMMDD)',
                'Enter a date in YYMMDD format (e.g., 230531)',
                _gs1DateController,
                'gs1Date',
              ),
              
              const SizedBox(height: 20),
              
              // Validate All Button
              Center(
                child: ElevatedButton(
                  onPressed: _validateAll,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Validate All Fields'),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Overall validation result
              if (_validationPassed)
                const Center(
                  child: Chip(
                    avatar: Icon(Icons.check_circle, color: Colors.green),
                    label: Text('All validations passed!'),
                    backgroundColor: Color(0xFFE8F5E9),
                  ),
                ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSection(String title, String hint, TextEditingController controller, String fieldName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ValidatedTextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: (value) {
            switch (fieldName) {
              case 'gtin':
                return validateGTIN(value);
              case 'gln':
                return validateGLN(value);
              case 'sscc':
                return validateSSCC(value);
              case 'sgtin':
                return validateSGTIN(value);
              case 'companyPrefix':
                return validateCompanyPrefix(value);
              case 'itemReference':
                return validateItemReference(value);
              case 'barcode':
                return validateGS1Barcode(value);
              case 'gs1Date':
                return validateGS1Date(value);
              default:
                return null;
            }
          },
          onChanged: (value) {
            // Handle any specific logic on change if needed
          },
        ),
        if (getFieldError(fieldName) != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              getFieldError(fieldName)!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
  
  Widget _buildAISection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Application Identifier (AI) Validation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        // AI Selection
        DropdownButtonFormField<String>(
          value: _selectedAI,
          decoration: const InputDecoration(
            labelText: 'Select AI',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: _aiOptions.map((ai) {
            return DropdownMenuItem<String>(
              value: ai['code'],
              child: Text('(${ai['code']}) ${ai['name']}'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedAI = value!;
            });
          },
        ),
        const SizedBox(height: 16),
        
        // AI Value
        ValidatedTextField(
          controller: _aiValueController,
          decoration: InputDecoration(
            hintText: 'Enter value for AI ($_selectedAI)',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: (value) => validateGS1ApplicationIdentifier(value, _selectedAI),
          onChanged: (value) {
            // Handle any specific logic on change if needed
          },
        ),
        
        if (getFieldError('aiValue') != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              getFieldError('aiValue')!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}
