import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/mode_selector.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_instructions.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';

/// One EPCIS document workbench with non-writing Convert and Validate modes.
class SerializeConvertTool extends StatefulWidget {
  const SerializeConvertTool({super.key});

  @override
  State<SerializeConvertTool> createState() => _SerializeConvertToolState();
}

class _SerializeConvertToolState extends State<SerializeConvertTool>
    with Gs1InitialModeMixin {
  final _input = TextEditingController();
  String _mode = 'convert';
  String _inputFormat = 'XML';
  String _outputFormat = 'JSON-LD';
  String _validationFormat = 'JSON-LD';

  static const _formats = ['XML', 'JSON-LD'];

  static const _convertInstructions = WorkbenchInstructions(
    summary:
        'Convert an EPCIS document between XML and JSON‑LD without writing to the database.',
    useCase:
        'Use when a trading partner needs the other serialization, or to read an XML document as JSON.',
    audience: 'Advanced / Integrator',
    steps: [
      'Pick the input and output formats — the swap button flips them.',
      'Paste the whole EPCIS document, header included.',
      'Convert, then review or copy the result; nothing is stored.',
    ],
  );

  static const _validateInstructions = WorkbenchInstructions(
    summary: 'Validate an EPCIS document against the EPCIS 2.0 schema.',
    useCase:
        'Use before sending a document to a partner or importing it, to catch structural errors early.',
    audience: 'Advanced / Integrator',
    steps: [
      'Pick the format of the document you have (XML or JSON‑LD).',
      'Paste the whole document.',
      'Validate to get each schema error with its location, or a clean pass.',
    ],
  );

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Gs1ToolsCubit, Gs1ToolsState>(
      buildWhen: (p, c) =>
          p.serializeConvert != c.serializeConvert ||
          p.initialMode != c.initialMode,
      builder: (context, state) {
        final cubit = context.read<Gs1ToolsCubit>();
        applyInitialMode(
          state.initialMode,
          const ['convert', 'validate'],
          (mode) => setState(() => _mode = mode),
          clear: cubit.clearInitialMode,
        );
        final slice = state.serializeConvert;
        final loading = slice.isLoading;

        return WorkbenchPanelShell(
          title: 'EPCIS Documents',
          slice: slice,
          instructions: _mode == 'validate'
              ? _validateInstructions
              : _convertInstructions,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Gs1ToolModeSelector(
                modes: const [('convert', 'Convert'), ('validate', 'Validate')],
                value: _mode,
                enabled: !loading,
                onChanged: (value) => setState(() => _mode = value),
              ),
              const SizedBox(height: TraqSpacing.lg),
              if (_mode == 'convert')
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _inputFormat,
                        decoration: const InputDecoration(
                          labelText: 'Input format',
                        ),
                        items: [
                          for (final format in _formats)
                            DropdownMenuItem(
                              value: format,
                              child: Text(format),
                            ),
                        ],
                        onChanged: loading
                            ? null
                            : (value) => setState(() => _inputFormat = value!),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Swap formats',
                      onPressed: loading
                          ? null
                          : () => setState(() {
                              final oldInput = _inputFormat;
                              _inputFormat = _outputFormat;
                              _outputFormat = oldInput;
                            }),
                      icon: const TraqIcon(AppAssets.iconTransform),
                    ),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _outputFormat,
                        decoration: const InputDecoration(
                          labelText: 'Output format',
                        ),
                        items: [
                          for (final format in _formats)
                            DropdownMenuItem(
                              value: format,
                              child: Text(format),
                            ),
                        ],
                        onChanged: loading
                            ? null
                            : (value) => setState(() => _outputFormat = value!),
                      ),
                    ),
                  ],
                )
              else
                DropdownButtonFormField<String>(
                  value: _validationFormat,
                  decoration: const InputDecoration(
                    labelText: 'Document format',
                  ),
                  items: [
                    for (final format in _formats)
                      DropdownMenuItem(value: format, child: Text(format)),
                  ],
                  onChanged: loading
                      ? null
                      : (value) => setState(() => _validationFormat = value!),
                ),
              const SizedBox(height: TraqSpacing.md),
              TextField(
                controller: _input,
                minLines: 8,
                maxLines: 14,
                enabled: !loading,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'EPCIS document',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: TraqSpacing.lg),
              CustomElevatedButton(
                label: _mode == 'validate' ? 'Validate' : 'Convert',
                isLoading: loading,
                isEnabled: !loading,
                onPressed: () {
                  if (_mode == 'validate') {
                    cubit.validateEpcisSchema(
                      input: _input.text,
                      format: _validationFormat == 'JSON-LD' ? 'JSON' : 'XML',
                    );
                  } else {
                    cubit.convertEpcisFormat(
                      input: _input.text,
                      inputFormat: _inputFormat,
                      outputFormat: _outputFormat,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
