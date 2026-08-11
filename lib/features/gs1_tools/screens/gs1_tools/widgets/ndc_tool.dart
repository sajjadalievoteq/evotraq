import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/gtin_entry_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/validated_text_field_wrapper.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/mode_selector.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_instructions.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';

/// NDC ↔ GTIN converter (US pharma 10/11-digit NDC to GS1 GTIN-14).
class NdcTool extends StatefulWidget {
  const NdcTool({super.key});

  @override
  State<NdcTool> createState() => _NdcToolState();
}

class _NdcToolState extends State<NdcTool> with Gs1InitialModeMixin {
  static const _modes = [
    ('ndc-to-gtin', 'NDC → GTIN'),
    ('gtin-to-ndc', 'GTIN → NDC'),
  ];

  static const _formats = ['4-4-2', '5-3-2', '5-4-1', '5-4-2'];

  static const _ndcToGtinInstructions = WorkbenchInstructions(
    summary: 'Convert a US National Drug Code into a GTIN‑14.',
    useCase:
        'Use when a DSCSA partner or a GS1-based system needs the GTIN form of an NDC.',
    audience: 'Advanced (US pharma)',
    steps: [
      'Enter the NDC (10 or 11 digits, dashes optional).',
      'For a 10-digit NDC pick its segment format, so the zero is padded in the right place.',
      'Convert to get the 11-digit NDC and the GTIN‑14 (03 prefix + check digit).',
    ],
    exampleInput: '0002-7597-01',
    exampleNote: '4‑4‑2 NDC → NDC‑11 00002759701 → GTIN‑14',
  );

  static const _gtinToNdcInstructions = WorkbenchInstructions(
    summary: 'Recover the NDC from a US drug GTIN‑14.',
    useCase:
        'Use to map incoming GS1 data back to the NDC your US systems key on.',
    audience: 'Advanced (US pharma)',
    steps: [
      'Enter the 14-digit GTIN — US drug GTINs start with 003.',
      'Convert to get the NDC‑11 form.',
      'Confirm the result against your product master before relying on it.',
    ],
    exampleInput: '00300002759709',
    exampleNote: '003‑prefixed GTIN‑14 → its NDC‑11',
  );

  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();

  String _mode = 'ndc-to-gtin';
  String _format = '5-4-1';

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  WorkbenchInstructions get _instructions =>
      _mode == 'gtin-to-ndc' ? _gtinToNdcInstructions : _ndcToGtinInstructions;

  void _loadExample(String example) {
    setState(() {
      if (_mode == 'ndc-to-gtin') _format = '4-4-2';
      _inputController.text = example;
    });
  }

  void _submit(Gs1ToolsCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    cubit.convertNdc(
      mode: _mode,
      input: _inputController.text,
      format: _format,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Gs1ToolsCubit, Gs1ToolsState>(
      buildWhen: (p, c) => p.ndc != c.ndc || p.initialMode != c.initialMode,
      builder: (context, state) {
        final cubit = context.read<Gs1ToolsCubit>();
        applyInitialMode(
          state.initialMode,
          const ['ndc-to-gtin', 'gtin-to-ndc'],
          (m) => setState(() => _mode = m),
          clear: cubit.clearInitialMode,
        );
        final slice = state.ndc;
        final loading = slice.isLoading;
        return WorkbenchPanelShell(
          title: 'NDC ↔ GTIN',
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
                if (_mode == 'gtin-to-ndc')
                  GtinEntryField(
                    controller: _inputController,
                    label: 'GTIN-14',
                    hintText: '14-digit GTIN (prefix 003…)',
                    enabled: !loading,
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Input is required' : null,
                  )
                else
                  ValidatedTextFieldWrapper(
                    controller: _inputController,
                    fieldName: 'ndc',
                    decoration: const InputDecoration(
                      labelText: 'NDC',
                      hintText: '10 or 11-digit NDC',
                    ),
                    readOnly: loading,
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Input is required' : null,
                  ),
                if (_mode == 'ndc-to-gtin') ...[
                  const SizedBox(height: TraqSpacing.md),
                  DropdownButtonFormField<String>(
                    value: _format,
                    decoration: const InputDecoration(
                      labelText: 'NDC segment format (for 10-digit NDC)',
                    ),
                    items: [
                      for (final format in _formats)
                        DropdownMenuItem(value: format, child: Text(format)),
                    ],
                    onChanged: loading
                        ? null
                        : (v) => setState(() => _format = v ?? _format),
                  ),
                ],
                const SizedBox(height: TraqSpacing.lg),
                CustomElevatedButton(
                  label: 'Convert',
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
