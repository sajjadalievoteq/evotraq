import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/barcode_tool_fields.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/gtin_entry_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/validated_text_field_wrapper.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_date_utils.dart';
import 'package:traqtrace_app/core/web/web_download_stub.dart'
    if (dart.library.html) 'package:traqtrace_app/core/web/web_download_web.dart'
    if (dart.library.io) 'package:traqtrace_app/core/web/web_download_io.dart'
    as web_download;
import 'package:traqtrace_app/core/web/web_print_stub.dart'
    if (dart.library.html) 'package:traqtrace_app/core/web/web_print_web.dart'
    if (dart.library.io) 'package:traqtrace_app/core/web/web_print_io.dart'
    as web_print;
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/mode_selector.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_instructions.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';

/// Consolidated barcode generation / verification workbench.
class BarcodeTool extends StatefulWidget {
  const BarcodeTool({super.key});

  @override
  State<BarcodeTool> createState() => _BarcodeToolState();
}

class _BarcodeToolState extends State<BarcodeTool> with Gs1InitialModeMixin {
  static const _modes = [
    ('datamatrix', 'GS1 DataMatrix'),
    ('gs1128', 'GS1-128'),
    ('pharma', 'Pharma 01/21/17/10'),
    ('sscc', 'SSCC'),
    ('ean13', 'EAN-13'),
    ('upca', 'UPC-A'),
    ('itf14', 'ITF-14'),
    ('qrdl', 'QR (Digital Link)'),
    ('verify', 'Verify'),
  ];

  static const _instructionsByMode = <String, WorkbenchInstructions>{
    'datamatrix': WorkbenchInstructions(
      summary: 'Generate a GS1 DataMatrix from a GS1 element string.',
      useCase:
          'Use for serialized item-level labels (pharma, medical devices) where a 2D symbol is required.',
      audience: 'Advanced',
      steps: [
        'Paste the element string, including every AI the label must carry.',
        'Generate, then Save the PNG or Print it.',
        'Confirm the printed symbol with Verify mode.',
      ],
      exampleInput: '(01)10614141073464(17)250101(21)1234(10)LOT1',
      exampleNote: 'GTIN + expiry + serial + lot',
    ),
    'gs1128': WorkbenchInstructions(
      summary: 'Generate a GS1‑128 linear barcode from a GS1 element string.',
      useCase:
          'Use for logistics labels — pallet or case SSCC plus shipment AIs.',
      audience: 'Advanced',
      steps: [
        'Paste the element string for the logistics AIs you need.',
        'Keep variable-length AIs last, or separate them with FNC1.',
        'Generate, then Save or Print the symbol.',
      ],
      exampleInput: '(00)006141411234567890',
      exampleNote: 'SSCC on a pallet label',
    ),
    'pharma': WorkbenchInstructions(
      summary:
          'Generate the pharma pack code — GTIN, expiry, serial, and lot in one GS1 DataMatrix.',
      useCase:
          'Use for DSCSA / EU FMD saleable units that must carry all four fields.',
      audience: 'Everyday',
      steps: [
        'Enter GTIN (01), serial (21), expiry YYMMDD (17), and batch/lot (10).',
        'Generate; the AIs are assembled in the right order with separators.',
        'Save or Print the symbol.',
      ],
      exampleInput: 'GTIN 10614141073464 · exp 250101 · serial 1234 · lot LOT1',
      exampleNote: 'Expiry day 00 means "last day of the month"',
    ),
    'sscc': WorkbenchInstructions(
      summary: 'Generate an SSCC barcode for a pallet or other logistic unit.',
      useCase: 'Use when labelling a shipping unit that receiving will scan.',
      audience: 'Everyday',
      steps: [
        'Enter the 18-digit SSCC; its check digit is validated.',
        'Generate, then Save or Print.',
        'Use the Build tool first if you still need to create the SSCC.',
      ],
      exampleInput: '006141411234567890',
      exampleNote: 'Valid SSCC‑18',
    ),
    'ean13': WorkbenchInstructions(
      summary: 'Generate an EAN‑13 retail barcode from a GTIN‑13.',
      useCase: 'Use for consumer units scanned at retail POS.',
      audience: 'Everyday',
      steps: [
        'Enter the 13-digit GTIN.',
        'Generate, then Save or Print at the correct magnification.',
      ],
      exampleInput: '4006381333931',
      exampleNote: 'Valid GTIN‑13',
    ),
    'upca': WorkbenchInstructions(
      summary: 'Generate a UPC‑A retail barcode from a GTIN‑12.',
      useCase: 'Use for consumer units sold in the US and Canada.',
      audience: 'Everyday',
      steps: [
        'Enter the 12-digit GTIN.',
        'Generate, then Save or Print at the correct magnification.',
      ],
      exampleInput: '036000291452',
      exampleNote: 'Valid GTIN‑12',
    ),
    'itf14': WorkbenchInstructions(
      summary: 'Generate an ITF‑14 barcode from a GTIN‑14.',
      useCase:
          'Use for cases and outer packaging that is not scanned at retail POS.',
      audience: 'Everyday',
      steps: [
        'Enter the 14-digit GTIN, including its indicator digit.',
        'Generate, then Save or Print with a bearer bar.',
      ],
      exampleInput: '10614141073464',
      exampleNote: 'Indicator 1 = a case of the base unit',
    ),
    'qrdl': WorkbenchInstructions(
      summary: 'Generate a QR code carrying a GS1 Digital Link URL.',
      useCase:
          'Use for consumer-facing packs where a scan should open product information.',
      audience: 'Everyday',
      steps: [
        'Paste the Digital Link URL — the Convert tool can build one from an identifier.',
        'Generate, then Save or Print.',
        'Check the link resolves before releasing artwork.',
      ],
      exampleInput: 'https://id.gs1.org/01/10614141073464/21/1234',
      exampleNote: 'GTIN + serial as a resolvable link',
    ),
    'verify': WorkbenchInstructions(
      summary: 'Decode an existing barcode and validate what it carries.',
      useCase:
          'Use to check a scanned or supplier-provided barcode is well-formed before accepting it.',
      audience: 'Everyday',
      steps: [
        'Scan into the field, or paste the barcode data.',
        'Verify to see the decoded AIs plus any format, length, or check-digit problems.',
      ],
      exampleInput: '(01)10614141073464(17)250101(21)1234(10)LOT1',
      exampleNote: 'A well-formed pharma pack code',
    ),
  };

  final _formKey = GlobalKey<FormState>();
  final _elementController = TextEditingController();
  final _gtinController = TextEditingController();
  final _serialController = TextEditingController();
  final _expiryController = TextEditingController();
  final _batchController = TextEditingController();
  final _ssccController = TextEditingController();
  final _dataController = TextEditingController();
  final _verifyController = TextEditingController();

  String _mode = 'datamatrix';

  @override
  void dispose() {
    _elementController.dispose();
    _gtinController.dispose();
    _serialController.dispose();
    _expiryController.dispose();
    _batchController.dispose();
    _ssccController.dispose();
    _dataController.dispose();
    _verifyController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? v, String label) =>
      (v ?? '').trim().isEmpty ? '$label is required' : null;

  WorkbenchInstructions get _instructions =>
      _instructionsByMode[_mode] ?? _instructionsByMode['datamatrix']!;

  void _loadExample(String example) {
    setState(() {
      switch (_mode) {
        case 'pharma':
          _gtinController.text = '10614141073464';
          _expiryController.text = '250101';
          _serialController.text = '1234';
          _batchController.text = 'LOT1';
        case 'sscc':
          _ssccController.text = example;
        case 'ean13':
        case 'upca':
        case 'itf14':
          _gtinController.text = example;
        case 'qrdl':
          _dataController.text = example;
        case 'verify':
          _verifyController.text = example;
        default:
          _elementController.text = example;
      }
    });
  }

  void _submit(Gs1ToolsCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    switch (_mode) {
      case 'datamatrix':
        cubit.barcodeTool(
          mode: 'datamatrix',
          elementString: _elementController.text,
        );
      case 'gs1128':
        cubit.barcodeTool(
          mode: 'gs1128',
          elementString: _elementController.text,
        );
      case 'pharma':
        cubit.barcodeTool(
          mode: 'pharma',
          gtin: _gtinController.text,
          serial: _serialController.text,
          expiry: _expiryController.text,
          batch: _batchController.text,
        );
      case 'sscc':
        cubit.barcodeTool(mode: 'sscc', sscc: _ssccController.text);
      case 'ean13':
        cubit.barcodeTool(mode: 'ean13', data: _gtinController.text);
      case 'upca':
        cubit.barcodeTool(mode: 'upca', data: _gtinController.text);
      case 'itf14':
        cubit.barcodeTool(mode: 'itf14', data: _gtinController.text);
      case 'qrdl':
        cubit.barcodeTool(mode: 'qrdl', data: _dataController.text);
      case 'verify':
        cubit.barcodeTool(mode: 'verify', verifyInput: _verifyController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Gs1ToolsCubit, Gs1ToolsState>(
      buildWhen: (p, c) =>
          p.barcode != c.barcode || p.initialMode != c.initialMode,
      builder: (context, state) {
        final cubit = context.read<Gs1ToolsCubit>();
        applyInitialMode(
          state.initialMode,
          const [
            'datamatrix',
            'pharma',
            'sgtin',
            'gs1128',
            'ean13',
            'upca',
            'itf14',
            'qrdl',
            'sscc',
            'verify',
          ],
          (m) => setState(() => _mode = m == 'sgtin' ? 'pharma' : m),
          clear: cubit.clearInitialMode,
        );
        final slice = state.barcode;
        final loading = slice.isLoading;
        return WorkbenchPanelShell(
          title: 'Barcode',
          slice: slice,
          instructions: _instructions,
          onLoadExample: _loadExample,
          actions: slice.imageBytes != null
              ? [
                  CustomOutlinedButtonWidget(
                    title: 'Save',
                    onTap: () {
                      web_download.downloadBytes(
                        bytes: slice.imageBytes!,
                        filename: 'barcode.png',
                        mimeType: 'image/png',
                      );
                    },
                  ),
                  CustomOutlinedButtonWidget(
                    title: 'Print',
                    onTap: () {
                      web_print.printImageBytes(
                        bytes: slice.imageBytes!,
                        title: 'Barcode',
                      );
                    },
                  ),
                ]
              : const [],
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Gs1ToolModeSelector(
                  modes: _modes,
                  value: _mode,
                  enabled: !loading,
                  onChanged: (v) => setState(() => _mode = v),
                ),
                const SizedBox(height: TraqSpacing.lg),
                BarcodeToolFields(
                  mode: _mode,
                  loading: loading,
                  elementController: _elementController,
                  gtinController: _gtinController,
                  serialController: _serialController,
                  expiryController: _expiryController,
                  batchController: _batchController,
                  ssccController: _ssccController,
                  dataController: _dataController,
                  verifyController: _verifyController,
                  requiredValidator: _requiredValidator,
                ),
                const SizedBox(height: TraqSpacing.lg),
                CustomElevatedButton(
                  label: _mode == 'verify' ? 'Verify' : 'Generate',
                  isLoading: loading,
                  isEnabled: !loading,
                  onPressed: () => _submit(cubit),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
