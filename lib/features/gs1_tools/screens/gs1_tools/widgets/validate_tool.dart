import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_validation_actions.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/mode_selector.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/validate_batch_fields.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/validate_kind_value_fields.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/validate_single_fields.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_instructions.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';

/// Consolidated validation workbench: single identifier, batch paste,
/// check-digit calculator, and AI/identifier anatomy decomposer.
class ValidateTool extends StatefulWidget {
  const ValidateTool({super.key});

  @override
  State<ValidateTool> createState() => _ValidateToolState();
}

class _ValidateToolState extends State<ValidateTool> with Gs1InitialModeMixin {
  static const _modes = [
    ('single', 'Single'),
    ('batch', 'Batch'),
    ('check-digit', 'Check digit'),
    ('anatomy', 'Anatomy'),
  ];

  static const _identifierKinds = [
    ('gtin', 'GTIN'),
    ('gln', 'GLN'),
    ('sscc', 'SSCC'),
    ('sgtin', 'SGTIN'),
    ('grai', 'GRAI'),
    ('giai', 'GIAI'),
    ('gdti', 'GDTI'),
    ('gsrn', 'GSRN'),
    ('cpid', 'CPID'),
  ];

  static const _checkDigitKinds = [
    ('gtin', 'GTIN'),
    ('gln', 'GLN'),
    ('sscc', 'SSCC'),
    ('gsrn', 'GSRN'),
    ('gdti', 'GDTI'),
    ('grai', 'GRAI'),
  ];

  static const _instructionsByMode = <String, WorkbenchInstructions>{
    'single': WorkbenchInstructions(
      summary:
          'Check one GS1 identifier — format, length, and mod‑10 check digit.',
      useCase:
          'Use before entering or trusting a GTIN, GLN, SSCC, or SGTIN you received.',
      audience: 'Everyday',
      steps: [
        'Pick the identifier type.',
        'Enter the value (plus the serial for SGTIN).',
        'See pass/fail with the reason, the expected check digit, and the breakdown.',
      ],
      exampleInput: '10614141073464',
      exampleNote: 'Valid GTIN‑14 (indicator 1 + company prefix 0614141)',
    ),
    'batch': WorkbenchInstructions(
      summary: 'Check a whole list of identifiers in one pass.',
      useCase:
          'Use to screen a supplier file or a spreadsheet column before importing it.',
      audience: 'Everyday',
      steps: [
        'Paste one identifier per line.',
        'Prefix a line with its type (GTIN,value · SGTIN,gtin,serial), or leave bare digits to auto-detect by length.',
        'Review pass/fail per line and fix the flagged rows at the source.',
      ],
      exampleInput:
          'GTIN,10614141073464\nSSCC,006141411234567890\n0614141000005',
      exampleNote: 'Mixed list — type prefix is optional',
    ),
    'check-digit': WorkbenchInstructions(
      summary:
          'Calculate the mod‑10 check digit for an identifier body, or verify the one you already have.',
      useCase:
          'Use when you hold an identifier without its last digit, or suspect a transcription typo.',
      audience: 'Everyday',
      steps: [
        'Pick the key type (GTIN, GLN, SSCC, GSRN, GDTI, GRAI).',
        'Paste the body without the check digit, or the full identifier to verify it.',
        'Get the computed digit and the corrected full identifier.',
      ],
      exampleInput: '1061414107346',
      exampleNote: 'GTIN‑14 body → check digit 4',
    ),
    'anatomy': WorkbenchInstructions(
      summary:
          'Break an identifier into its parts — company prefix, reference, and check digit.',
      useCase:
          'Use to see which company prefix owns an identifier, or to explain one to a colleague.',
      audience: 'Advanced',
      steps: [
        'Pick the identifier type.',
        'Enter the value.',
        'Read the segment-by-segment breakdown.',
      ],
      exampleInput: '10614141073464',
      exampleNote:
          'GTIN‑14 → indicator + company prefix + item reference + check digit',
    ),
  };

  final _formKey = GlobalKey<FormState>();
  final _singleValueController = TextEditingController();
  final _singleSerialController = TextEditingController();
  final _pasteController = TextEditingController();
  final _checkDigitController = TextEditingController();
  final _anatomyValueController = TextEditingController();

  String _mode = 'single';
  String _singleKind = 'gtin';
  String _checkDigitKind = 'gtin';
  String _anatomyKind = 'gtin';

  @override
  void dispose() {
    _singleValueController.dispose();
    _singleSerialController.dispose();
    _pasteController.dispose();
    _checkDigitController.dispose();
    _anatomyValueController.dispose();
    super.dispose();
  }

  WorkbenchInstructions get _instructions =>
      _instructionsByMode[_mode] ?? _instructionsByMode['single']!;

  void _loadExample(String example) {
    setState(() {
      switch (_mode) {
        case 'batch':
          _pasteController.text = example;
        case 'check-digit':
          _checkDigitKind = 'gtin';
          _checkDigitController.text = example;
        case 'anatomy':
          _anatomyKind = 'gtin';
          _anatomyValueController.text = example;
        default:
          _singleKind = 'gtin';
          _singleValueController.text = example;
      }
    });
  }

  String? _requiredValidator(String? v, String label) =>
      (v ?? '').trim().isEmpty ? '$label is required' : null;

  String? _validatorFor(String kind, String? v) {
    if ((v ?? '').trim().isEmpty) return '${kind.toUpperCase()} is required';
    return null;
  }

  void _submit(Gs1ToolsCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    switch (_mode) {
      case 'single':
        if (_singleKind == 'sgtin') {
          cubit.validateTool(
            mode: 'single',
            kind: 'sgtin',
            gtin: _singleValueController.text,
            serial: _singleSerialController.text,
          );
        } else {
          cubit.validateTool(
            mode: 'single',
            kind: _singleKind,
            value: _singleValueController.text,
          );
        }
      case 'batch':
        cubit.validateTool(mode: 'batch', paste: _pasteController.text);
      case 'check-digit':
        cubit.validateTool(
          mode: 'check-digit',
          checkDigitKind: _checkDigitKind,
          checkDigitInput: _checkDigitController.text,
        );
      case 'anatomy':
        cubit.validateTool(
          mode: 'anatomy',
          kind: _anatomyKind,
          value: _anatomyValueController.text,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Gs1ToolsCubit, Gs1ToolsState>(
      buildWhen: (p, c) =>
          p.validate != c.validate || p.initialMode != c.initialMode,
      builder: (context, state) {
        final cubit = context.read<Gs1ToolsCubit>();
        applyInitialMode(
          state.initialMode,
          const ['single', 'batch', 'check-digit', 'anatomy'],
          (m) => setState(() => _mode = m),
          clear: cubit.clearInitialMode,
        );
        final slice = state.validate;
        final loading = slice.isLoading;
        return WorkbenchPanelShell(
          title: 'Validate',
          slice: slice,
          instructions: _instructions,
          onLoadExample: _loadExample,
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
                switch (_mode) {
                  'batch' => ValidateBatchFields(
                    controller: _pasteController,
                    loading: loading,
                  ),
                  'check-digit' => ValidateKindValueFields(
                    kinds: _checkDigitKinds,
                    kind: _checkDigitKind,
                    controller: _checkDigitController,
                    fieldName: 'check_digit',
                    valueLabel: 'Identifier or body (digits)',
                    requiredLabel: 'Input',
                    keyboardType: TextInputType.number,
                    loading: loading,
                    onKindChanged: (value) {
                      setState(() => _checkDigitKind = value);
                    },
                    requiredValidator: _requiredValidator,
                  ),
                  'anatomy' => ValidateKindValueFields(
                    kinds: _identifierKinds,
                    kind: _anatomyKind,
                    controller: _anatomyValueController,
                    fieldName: 'anatomy_value',
                    valueLabel: 'Value',
                    requiredLabel: 'Value',
                    loading: loading,
                    onKindChanged: (value) {
                      setState(() => _anatomyKind = value);
                    },
                    requiredValidator: _requiredValidator,
                  ),
                  _ => ValidateSingleFields(
                    identifierKinds: _identifierKinds,
                    kind: _singleKind,
                    valueController: _singleValueController,
                    serialController: _singleSerialController,
                    loading: loading,
                    onKindChanged: (value) {
                      setState(() => _singleKind = value);
                    },
                    validatorFor: _validatorFor,
                    requiredValidator: _requiredValidator,
                  ),
                },
                const SizedBox(height: TraqSpacing.lg),
                CustomElevatedButton(
                  label: 'Validate',
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
