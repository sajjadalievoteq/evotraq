import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_canonical_identifier.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';
import 'package:traqtrace_app/features/shared/validation/gs1_batch_validator.dart';

class GS1ValidationScreen extends StatefulWidget {
  const GS1ValidationScreen({super.key, this.embedded = false});

  /// When true, renders body only (no Scaffold/drawer) for workbench hosting.
  final bool embedded;

  @override
  State<GS1ValidationScreen> createState() => _GS1ValidationScreenState();
}

class _GS1ValidationScreenState extends State<GS1ValidationScreen> {
  final _batchController = TextEditingController();
  final _gtinController = TextEditingController();
  final _glnController = TextEditingController();
  final _ssccController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _epcUriController = TextEditingController();
  final _barcodeDataController = TextEditingController();

  List<Gs1BatchValidationRow> _batchResults = const [];
  final Map<String, ValidationResult> _manualResults = {};

  @override
  void dispose() {
    _batchController.dispose();
    _gtinController.dispose();
    _glnController.dispose();
    _ssccController.dispose();
    _serialNumberController.dispose();
    _epcUriController.dispose();
    _barcodeDataController.dispose();
    super.dispose();
  }

  void _runBatchValidation() {
    final text = _batchController.text;
    if (text.trim().isEmpty) {
      context.showError('Paste one or more identifiers (one per line or CSV).');
      return;
    }
    setState(() {
      _batchResults = Gs1BatchValidator.validatePaste(text);
      _manualResults.clear();
    });
  }

  void _validateSingle(String type) {
    setState(() {
      switch (type) {
        case 'GTIN':
          final value = _gtinController.text.trim();
          final err = CheckDigitUtils.validateGtin(value);
          _manualResults['GTIN'] = ValidationResult(
            isValid: err == null,
            testType: 'GTIN',
            value: value,
            message: err ?? 'Valid GTIN',
          );
        case 'GLN':
          final value = _glnController.text.trim();
          final err = CheckDigitUtils.validateGln(value);
          _manualResults['GLN'] = ValidationResult(
            isValid: err == null,
            testType: 'GLN',
            value: value,
            message: err ?? 'Valid GLN',
          );
        case 'SSCC':
          final value = _ssccController.text.trim();
          final err = CheckDigitUtils.validateSscc(value);
          _manualResults['SSCC'] = ValidationResult(
            isValid: err == null,
            testType: 'SSCC',
            value: value,
            message: err ?? 'Valid SSCC',
          );
        case 'SGTIN':
          final gtin = _gtinController.text.trim();
          final serial = _serialNumberController.text.trim();
          final err = CheckDigitUtils.validateSgtin(gtin, serial);
          _manualResults['SGTIN'] = ValidationResult(
            isValid: err == null,
            testType: 'SGTIN',
            value: '$gtin + $serial',
            message: err ?? 'Valid SGTIN',
          );
        case 'EPC_URI':
          final value = _epcUriController.text.trim();
          final ok =
              value.isNotEmpty && Gs1CanonicalIdentifier.isValid(value);
          _manualResults['EPC URI'] = ValidationResult(
            isValid: ok,
            testType: 'EPC URI',
            value: value,
            message: value.isEmpty
                ? 'EPC URI is required'
                : (ok
                    ? 'Valid EPC / Digital Link URI'
                    : 'Invalid EPC / Digital Link URI'),
          );
        case 'BARCODE':
          final value = _barcodeDataController.text.trim();
          final message = _barcodeMessage(value);
          _manualResults['Barcode'] = ValidationResult(
            isValid: message == null,
            testType: 'Barcode',
            value: value,
            message: message ?? 'Valid GS1 element string',
          );
      }
      _batchResults = const [];
    });
  }

  String? _barcodeMessage(String value) {
    if (value.isEmpty) return 'Barcode data cannot be empty';
    final parsed = GS1BarcodeParser.parseGS1Barcode(value);
    if (parsed['valid'] == true) return null;
    final checkErrors = (parsed['checkDigitErrors'] as List?)
        ?.map((e) => '$e')
        .where((e) => e.isNotEmpty)
        .toList();
    if (checkErrors != null && checkErrors.isNotEmpty) {
      return checkErrors.join('; ');
    }
    final ais = parsed['parsedData'];
    if (ais is! Map || ais.isEmpty) {
      return 'Invalid barcode format: missing Application Identifiers';
    }
    return 'Invalid GS1 barcode data';
  }

  @override
  Widget build(BuildContext context) {
    final body = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GS1 Identifier Validation',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Validate identifiers you supply using GS1 mod-10 check digits and '
            'length rules (GTIN‑8/12/13/14, GLN‑13, SSCC‑18, SGTIN). '
            'Paste a list or CSV below, or validate a single field.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          const Text(
            'Batch validation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'One identifier per line. Optional type prefix: '
            'GTIN,value · GLN,value · SSCC,value · SGTIN,gtin,serial · '
            'EPC,uri · BARCODE,element-string. '
            'Bare digits auto-detect by length. Lines starting with # are ignored.',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _batchController,
            minLines: 6,
            maxLines: 16,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText:
                  'GTIN,4006381333931\nGLN,1234567890128\nSSCC,106141412345678908\nSGTIN,12345678901231,ABC123',
              alignLabelWithHint: true,
              labelText: 'Paste identifiers',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _runBatchValidation,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TraqIcon(AppAssets.iconArrowR),
                  SizedBox(width: 8),
                  Text('Validate batch'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            'Single identifier',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _validateRow(
            controller: _gtinController,
            label: 'GTIN (8 / 12 / 13 / 14 digits)',
            onValidate: () => _validateSingle('GTIN'),
          ),
          const SizedBox(height: 16),
          _validateRow(
            controller: _glnController,
            label: 'GLN (13 digits)',
            onValidate: () => _validateSingle('GLN'),
          ),
          const SizedBox(height: 16),
          _validateRow(
            controller: _ssccController,
            label: 'SSCC (18 digits)',
            onValidate: () => _validateSingle('SSCC'),
          ),
          const SizedBox(height: 16),
          const Text('SGTIN (uses GTIN field above + serial)'),
          const SizedBox(height: 8),
          _validateRow(
            controller: _serialNumberController,
            label: 'Serial number (AI 21)',
            onValidate: () => _validateSingle('SGTIN'),
          ),
          const SizedBox(height: 16),
          _validateRow(
            controller: _epcUriController,
            label: 'EPC URI / Digital Link',
            onValidate: () => _validateSingle('EPC_URI'),
          ),
          const SizedBox(height: 16),
          _validateRow(
            controller: _barcodeDataController,
            label: 'GS1 barcode / element string',
            onValidate: () => _validateSingle('BARCODE'),
          ),
          if (_batchResults.isNotEmpty) ...[
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Batch results (${_batchResults.where((r) => r.isValid).length}/'
              '${_batchResults.length} passed)',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _resultsTable(
              rows: _batchResults
                  .map(
                    (r) => (
                      '#${r.lineNumber}',
                      r.type,
                      r.value,
                      r.isValid,
                      r.message,
                    ),
                  )
                  .toList(),
            ),
          ],
          if (_manualResults.isNotEmpty) ...[
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Single results',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _resultsTable(
              rows: _manualResults.entries
                  .map(
                    (e) => (
                      e.key,
                      e.value.testType,
                      e.value.value,
                      e.value.isValid,
                      e.value.message,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );

    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('GS1 Validation')),
      drawer: const AppDrawer(),
      body: body,
    );
  }

  Widget _validateRow({
    required TextEditingController controller,
    required String label,
    required VoidCallback onValidate,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: onValidate,
              child: const Text('Validate'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _resultsTable({
    required List<(String, String, String, bool, String)> rows,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
          columns: const [
            DataColumn(
              label: Text('Row', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('Value', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('Result', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('Reason', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
          rows: rows.map((row) {
            final (label, type, value, isValid, message) = row;
            final color = isValid
                ? AppColorMapper.successColor(context)
                : AppColorMapper.errorColor(context);
            return DataRow(
              cells: [
                DataCell(Text(label)),
                DataCell(Text(type)),
                DataCell(
                  SizedBox(
                    width: 220,
                    child: Text(value, overflow: TextOverflow.ellipsis),
                  ),
                ),
                DataCell(
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TraqIcon(
                          isValid
                              ? AppAssets.iconCheckCircle
                              : AppAssets.iconXCircle,
                          size: 16,
                          color: color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isValid ? 'Pass' : 'Fail',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 280,
                    child: Text(message, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
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
