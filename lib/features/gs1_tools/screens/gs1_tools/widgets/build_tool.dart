import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/gtin_entry_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/validated_text_field_wrapper.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/mode_selector.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_instructions.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';

class BuildTool extends StatefulWidget {
  const BuildTool({super.key});

  @override
  State<BuildTool> createState() => _BuildToolState();
}

class _BuildToolState extends State<BuildTool> with Gs1InitialModeMixin {
  final _formKey = GlobalKey<FormState>();
  final _ext = TextEditingController(text: '0');
  final _gcp = TextEditingController();
  final _serial = TextEditingController();
  final _gtin = TextEditingController();

  String _mode = 'sscc';
  int _targetLength = 14;
  int? _indicator;

  static const _modes = <(String, String)>[
    ('sscc', 'SSCC builder'),
    ('gtin', 'GTIN packaging'),
  ];

  static const _ssccInstructions = WorkbenchInstructions(
    summary:
        'Build a valid SSCC‑18 from an extension digit, company prefix, and serial reference.',
    useCase:
        'Use when you need a new SSCC for a pallet or shipping unit and want the check digit computed for you.',
    audience: 'Advanced',
    steps: [
      'Enter the extension digit and your GS1 Company Prefix.',
      'Enter a serial reference — its length is 16 − prefix length; Next serial increments it.',
      'Build to get the SSCC‑18 with its check digit.',
    ],
    exampleInput: 'ext 3 · GCP 0614141 · serial 000000001',
    exampleNote: '→ SSCC‑18 with an auto-computed check digit',
  );

  static const _gtinInstructions = WorkbenchInstructions(
    summary:
        'Convert or normalize a GTIN between packaging levels (GTIN‑8/12/13/14).',
    useCase:
        'Use to pad a GTIN‑12 up to a GTIN‑14 for case labels, or to set the indicator digit for a packaging level.',
    audience: 'Advanced',
    steps: [
      'Enter the source GTIN.',
      'Pick the target length, and for GTIN‑14 the indicator digit.',
      'Build to get the normalized GTIN with a recomputed check digit.',
    ],
    exampleInput: 'GTIN‑12 036000291452 → GTIN‑14, indicator 1',
    exampleNote: 'Indicator 0 = base unit · 9 = variable measure',
  );

  static String _indicatorLabel(int i) {
    if (i == 0) return '0 — base unit';
    if (i == 9) return '9 — variable measure';
    return '$i — company-assigned packaging level';
  }

  @override
  void dispose() {
    _ext.dispose();
    _gcp.dispose();
    _serial.dispose();
    _gtin.dispose();
    super.dispose();
  }

  void _nextSerial() {
    final digits = _serial.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      setState(() => _serial.text = '1');
      return;
    }
    final next = (BigInt.tryParse(digits) ?? BigInt.zero) + BigInt.one;
    setState(() {
      _serial.text = next.toString().padLeft(digits.length, '0');
    });
  }

  WorkbenchInstructions get _instructions =>
      _mode == 'gtin' ? _gtinInstructions : _ssccInstructions;

  void _loadExample() {
    setState(() {
      if (_mode == 'gtin') {
        _gtin.text = '036000291452';
        _targetLength = 14;
        _indicator = 1;
        return;
      }
      _ext.text = '3';
      _gcp.text = '0614141';
      _serial.text = '000000001';
    });
  }

  void _submit(Gs1ToolsCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    cubit.buildIdentifier(
      mode: _mode,
      extensionDigit: _ext.text,
      companyPrefix: _gcp.text,
      serialReference: _serial.text,
      gtin: _gtin.text,
      targetLength: _targetLength,
      indicator: _indicator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Gs1ToolsCubit, Gs1ToolsState>(
      buildWhen: (p, c) =>
          p.build != c.build || p.initialMode != c.initialMode,
      builder: (context, state) {
        final cubit = context.read<Gs1ToolsCubit>();
        applyInitialMode(
          state.initialMode,
          const ['sscc', 'gtin'],
          (m) => setState(() => _mode = m),
          clear: cubit.clearInitialMode,
        );
        final slice = state.build;
        return WorkbenchPanelShell(
          title: 'Build',
          slice: slice,
          instructions: _instructions,
          onLoadExample: (_) => _loadExample(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Gs1ToolModeSelector(
                  value: _mode,
                  modes: _modes,
                  enabled: !slice.isLoading,
                  onChanged: (v) => setState(() => _mode = v),
                ),
                const SizedBox(height: TraqSpacing.lg),
                if (_mode == 'sscc') ...[
                  ValidatedTextFieldWrapper(
                    controller: _ext,
                    fieldName: 'extension',
                    readOnly: slice.isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Extension digit (0–9)',
                    ),
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        (v ?? '').trim().length != 1 ? 'One digit' : null,
                  ),
                  const SizedBox(height: TraqSpacing.md),
                  ValidatedTextFieldWrapper(
                    controller: _gcp,
                    fieldName: 'gcp',
                    readOnly: slice.isLoading,
                    decoration: const InputDecoration(
                      labelText: 'GS1 Company Prefix (6–12 digits)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final d = (v ?? '').replaceAll(RegExp(r'\D'), '');
                      if (d.length < 6 || d.length > 12) {
                        return '6–12 digits required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: TraqSpacing.md),
                  ValidatedTextFieldWrapper(
                    controller: _serial,
                    fieldName: 'serial_reference',
                    readOnly: slice.isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Serial reference',
                      helperText: 'Length = 16 − GCP length',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: TraqSpacing.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CustomOutlinedButtonWidget(
                      title: 'Next serial',
                      onTap: _nextSerial,
                    ),
                  ),
                ] else ...[
                  GtinEntryField(
                    controller: _gtin,
                    label: 'Source GTIN',
                    enabled: !slice.isLoading,
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'GTIN is required' : null,
                  ),
                  const SizedBox(height: TraqSpacing.md),
                  DropdownButtonFormField<int>(
                    value: _targetLength,
                    decoration:
                        const InputDecoration(labelText: 'Target length'),
                    items: const [
                      DropdownMenuItem(value: 8, child: Text('GTIN-8')),
                      DropdownMenuItem(value: 12, child: Text('GTIN-12')),
                      DropdownMenuItem(value: 13, child: Text('GTIN-13')),
                      DropdownMenuItem(value: 14, child: Text('GTIN-14')),
                    ],
                    onChanged: slice.isLoading
                        ? null
                        : (v) => setState(() => _targetLength = v!),
                  ),
                  const SizedBox(height: TraqSpacing.md),
                  DropdownButtonFormField<int?>(
                    value: _indicator,
                    decoration: const InputDecoration(
                      labelText: 'Indicator digit (GTIN-14)',
                      helperText:
                          '0 = base unit · 9 = variable measure · 1–8 = company-assigned',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Keep / derive'),
                      ),
                      for (var i = 0; i <= 9; i++)
                        DropdownMenuItem(
                          value: i,
                          child: Text(_indicatorLabel(i)),
                        ),
                    ],
                    onChanged: slice.isLoading
                        ? null
                        : (v) => setState(() => _indicator = v),
                  ),
                ],
                gs1SubmitButton(
                  loading: slice.isLoading,
                  onPressed: () => _submit(cubit),
                  label: 'Build',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
