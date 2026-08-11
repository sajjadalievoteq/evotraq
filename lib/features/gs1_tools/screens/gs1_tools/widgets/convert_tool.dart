import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/convert_tool_fields.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/gtin_entry_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/validated_text_field_wrapper.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/mode_selector.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_instructions.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';

/// Consolidated conversion workbench: URN ⇄ Digital Link, EPC ⇄ GS1
/// identifiers, and Digital Link ⇄ element string.
class ConvertTool extends StatefulWidget {
  const ConvertTool({super.key});

  @override
  State<ConvertTool> createState() => _ConvertToolState();
}

class _ConvertToolState extends State<ConvertTool> with Gs1InitialModeMixin {
  static const _urnDlDirections = [('parse', 'Parse'), ('build', 'Build')];
  static const _epcDirections = [
    ('to-epc', 'To EPC'),
    ('from-epc', 'From EPC'),
  ];
  static const _elementDirections = [
    ('dl-to-element', 'DL → Element'),
    ('element-to-dl', 'Element → DL'),
  ];
  static const _urnDlKinds = [
    ('gtin', 'GTIN'),
    ('sgtin', 'SGTIN'),
    ('sscc', 'SSCC'),
    ('gln', 'GLN'),
  ];
  static const _epcKinds = [
    ('sgtin', 'SGTIN'),
    ('sscc', 'SSCC'),
    ('gln', 'GLN'),
  ];

  static const _parseUrnDl = WorkbenchInstructions(
    summary:
        'Parse an EPC URN or GS1 Digital Link URL into the identifier it carries.',
    useCase:
        'Use when a partner sends an identifier in one form and you need to know what it actually contains.',
    audience: 'Advanced / Integrator',
    steps: [
      'Paste a Digital Link URL (https://id.gs1.org/…) or an EPC URN (urn:epc:id:…).',
      'Convert to see the identifier kind, key, serial, and the equivalent forms.',
      'Check digits are validated as part of the parse.',
    ],
    exampleInput: 'urn:epc:id:sgtin:0614141.107346.1234',
    exampleNote: 'SGTIN URN → GTIN 10614141073464 + serial 1234',
  );

  static const _buildUrnDl = WorkbenchInstructions(
    summary:
        'Build an EPC URN and GS1 Digital Link URL from plain identifier fields.',
    useCase:
        'Use to publish a product link, or to give a partner the URN form of an identifier you hold as separate fields.',
    audience: 'Advanced / Integrator',
    steps: [
      'Pick the identifier kind (GTIN, SGTIN, SSCC, GLN).',
      'Enter its parts; check digits are validated before conversion.',
      'Convert to get both the URN and the Digital Link URL.',
    ],
    exampleInput: 'SGTIN: GTIN 10614141073464 + serial 1234',
    exampleNote: '→ urn:epc:id:sgtin:0614141.107346.1234',
  );

  static const _toEpc = WorkbenchInstructions(
    summary:
        'Turn GS1 identifier fields into an EPC URI (SGTIN, SSCC, or SGLN).',
    useCase:
        'Use when an EPCIS event or an RFID encoder needs the pure-identity EPC form.',
    audience: 'Advanced / Integrator',
    steps: [
      'Pick the identifier kind and enter its parts.',
      'Convert to get the EPC URI.',
      'Copy the URI into your EPCIS event or tag encoder.',
    ],
    exampleInput: 'SGTIN: GTIN 10614141073464 + serial 1234',
    exampleNote: '→ urn:epc:id:sgtin:0614141.107346.1234',
  );

  static const _fromEpc = WorkbenchInstructions(
    summary: 'Extract the GS1 identifier fields out of an EPC URI.',
    useCase:
        'Use to read an EPCIS event or RFID tag value back into a GTIN, SSCC, or GLN you can look up.',
    audience: 'Advanced / Integrator',
    steps: [
      'Choose the GS1 type the EPC represents.',
      'Paste the EPC URI.',
      'Convert to get the plain identifier and its parts.',
    ],
    exampleInput: 'urn:epc:id:sgtin:0614141.107346.1234',
    exampleNote: '→ GTIN 10614141073464 + serial 1234',
  );

  static const _dlToElement = WorkbenchInstructions(
    summary: 'Convert a GS1 Digital Link URL into a GS1 element string.',
    useCase:
        'Use when a QR Digital Link has to be re-encoded as barcode data (GS1‑128 or DataMatrix).',
    audience: 'Advanced / Integrator',
    steps: [
      'Paste the Digital Link URL.',
      'Convert to get the bracketed element string.',
      'Feed that string into the Barcode tool to generate a symbol.',
    ],
    exampleInput: 'https://id.gs1.org/01/10614141073464/21/1234',
    exampleNote: '→ (01)10614141073464(21)1234',
  );

  static const _elementToDl = WorkbenchInstructions(
    summary: 'Convert a GS1 element string into a GS1 Digital Link URL.',
    useCase:
        'Use to turn scanned barcode data into a web link for a resolver or a consumer-facing pack.',
    audience: 'Advanced / Integrator',
    steps: [
      'Paste the element string (bracketed or FNC1 form).',
      'Convert to get the canonical Digital Link URL.',
      'Use the URL in a QR code via the Barcode tool.',
    ],
    exampleInput: '(01)10614141073464(21)1234',
    exampleNote: '→ https://id.gs1.org/01/10614141073464/21/1234',
  );

  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();
  final _gtinController = TextEditingController();
  final _serialController = TextEditingController();
  final _ssccController = TextEditingController();
  final _glnController = TextEditingController();
  final _extraController = TextEditingController();

  String _mode = 'urn-dl';
  String _direction = 'parse';
  String _idKind = 'sgtin';
  String _epcType = 'SGTIN';

  @override
  void dispose() {
    _inputController.dispose();
    _gtinController.dispose();
    _serialController.dispose();
    _ssccController.dispose();
    _glnController.dispose();
    _extraController.dispose();
    super.dispose();
  }

  List<(String, String)> _directionsFor(String mode) => switch (mode) {
    'epc' => _epcDirections,
    'element' => _elementDirections,
    _ => _urnDlDirections,
  };

  void _onModeChanged(String mode) {
    setState(() {
      _mode = mode;
      _direction = _directionsFor(mode).first.$1;
      if (mode == 'epc' && _idKind == 'gtin') {
        _idKind = 'sgtin';
      }
    });
  }

  WorkbenchInstructions get _instructions => switch ((_mode, _direction)) {
    ('epc', 'to-epc') => _toEpc,
    ('epc', _) => _fromEpc,
    ('element', 'element-to-dl') => _elementToDl,
    ('element', _) => _dlToElement,
    (_, 'build') => _buildUrnDl,
    _ => _parseUrnDl,
  };

  void _loadExample(String example) {
    setState(() {
      if ((_mode == 'urn-dl' && _direction == 'build') ||
          (_mode == 'epc' && _direction == 'to-epc')) {
        _idKind = 'sgtin';
        _gtinController.text = '10614141073464';
        _serialController.text = '1234';
        return;
      }
      _inputController.text = example;
    });
  }

  void _submit(Gs1ToolsCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    switch (_mode) {
      case 'urn-dl':
        if (_direction == 'parse') {
          cubit.convertIdentifier(
            mode: 'urn-dl',
            input: _inputController.text,
            direction: 'parse',
          );
        } else {
          cubit.convertIdentifier(
            mode: 'urn-dl',
            gtin: (_idKind == 'gtin' || _idKind == 'sgtin')
                ? _gtinController.text
                : null,
            serial: _idKind == 'sgtin' ? _serialController.text : null,
            sscc: _idKind == 'sscc' ? _ssccController.text : null,
            gln: _idKind == 'gln' ? _glnController.text : null,
            lot: _idKind == 'gtin' ? _extraController.text : null,
            extension: _idKind == 'gln' ? _extraController.text : null,
            direction: 'build',
          );
        }
      case 'epc':
        if (_direction == 'to-epc') {
          cubit.convertIdentifier(
            mode: 'epc',
            gtin: _idKind == 'sgtin' ? _gtinController.text : null,
            serial: _idKind == 'sgtin' ? _serialController.text : null,
            sscc: _idKind == 'sscc' ? _ssccController.text : null,
            gln: _idKind == 'gln' ? _glnController.text : null,
            extension: _idKind == 'gln' ? _extraController.text : null,
            direction: 'to-epc',
            epcType: _idKind.toUpperCase(),
          );
        } else {
          cubit.convertIdentifier(
            mode: 'epc',
            input: _inputController.text,
            direction: 'from-epc',
            epcType: _epcType,
          );
        }
      case 'element':
        cubit.convertIdentifier(
          mode: 'element',
          input: _inputController.text,
          direction: _direction,
        );
    }
  }

  String? _gtinValidator(String? v) => CheckDigitUtils.validateGS1CheckDigit(
    v,
    allowedLengths: CheckDigitUtils.gtinLengths,
    label: 'GTIN',
  );

  String? _ssccValidator(String? v) => CheckDigitUtils.validateGS1CheckDigit(
    v,
    allowedLengths: CheckDigitUtils.ssccLengths,
    label: 'SSCC',
  );

  String? _glnValidator(String? v) => CheckDigitUtils.validateGS1CheckDigit(
    v,
    allowedLengths: CheckDigitUtils.glnLengths,
    label: 'GLN',
  );

  String? _requiredValidator(String? v, String label) =>
      (v ?? '').trim().isEmpty ? '$label is required' : null;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Gs1ToolsCubit, Gs1ToolsState>(
      buildWhen: (p, c) =>
          p.convert != c.convert || p.initialMode != c.initialMode,
      builder: (context, state) {
        final cubit = context.read<Gs1ToolsCubit>();
        applyInitialMode(
          state.initialMode,
          const ['urn-dl', 'digital-link', 'epc', 'element'],
          (m) => _onModeChanged(m == 'digital-link' ? 'urn-dl' : m),
          clear: cubit.clearInitialMode,
        );
        final slice = state.convert;
        return WorkbenchPanelShell(
          title: 'Convert',
          slice: slice,
          instructions: _instructions,
          onLoadExample: _loadExample,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                Gs1ToolModeSelector(
                  modes: const [
                    ('urn-dl', 'URN ↔ DL'),
                    ('epc', 'EPC'),
                    ('element', 'Element'),
                  ],
                  value: _mode,
                  enabled: !slice.isLoading,
                  onChanged: _onModeChanged,
                ),
                const SizedBox(height: TraqSpacing.lg),
                ConvertToolFields(
                  slice: slice,
                  mode: _mode,
                  direction: _direction,
                  idKind: _idKind,
                  epcType: _epcType,
                  inputController: _inputController,
                  gtinController: _gtinController,
                  serialController: _serialController,
                  ssccController: _ssccController,
                  glnController: _glnController,
                  extraController: _extraController,
                  urnDlDirections: _urnDlDirections,
                  urnDlKinds: _urnDlKinds,
                  epcDirections: _epcDirections,
                  epcKinds: _epcKinds,
                  elementDirections: _elementDirections,
                  onDirectionChanged: (v) => setState(() => _direction = v),
                  onIdKindChanged: (v) => setState(() => _idKind = v),
                  onEpcTypeChanged: (v) => setState(() => _epcType = v),
                  gtinValidator: _gtinValidator,
                  ssccValidator: _ssccValidator,
                  glnValidator: _glnValidator,
                  requiredValidator: _requiredValidator,
                ),
                const SizedBox(height: TraqSpacing.lg),
                CustomElevatedButton(
                  label: 'Convert',
                  isLoading: slice.isLoading,
                  isEnabled: !slice.isLoading,
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
