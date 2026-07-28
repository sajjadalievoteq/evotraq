import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';

class SerializeConvertTool extends StatefulWidget {
  const SerializeConvertTool({super.key});

  @override
  State<SerializeConvertTool> createState() => _SerializeConvertToolState();
}

class _SerializeConvertToolState extends State<SerializeConvertTool> {
  final _input = TextEditingController();
  String _inputFormat = 'XML';
  String _outputFormat = 'JSON-LD';

  static const _formats = ['XML', 'JSON-LD'];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Gs1ToolsCubit, Gs1ToolsState>(
      buildWhen: (p, c) => p.serializeConvert != c.serializeConvert,
      builder: (context, state) {
        final cubit = context.read<Gs1ToolsCubit>();
        final slice = state.serializeConvert;
        return WorkbenchPanelShell(
          title: 'Format Conversion',
          slice: slice,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Convert EPCIS documents between XML and JSON-LD via the backend.',
                style: context.text.bodySm.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
              const SizedBox(height: TraqSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _inputFormat,
                      decoration: const InputDecoration(
                        labelText: 'Input format',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final f in _formats)
                          DropdownMenuItem(value: f, child: Text(f)),
                      ],
                      onChanged: slice.isLoading
                          ? null
                          : (v) => setState(() => _inputFormat = v!),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Swap formats',
                    onPressed: slice.isLoading
                        ? null
                        : () => setState(() {
                              final tmp = _inputFormat;
                              _inputFormat = _outputFormat;
                              _outputFormat = tmp;
                            }),
                    icon: const TraqIcon(AppAssets.iconTransform),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _outputFormat,
                      decoration: const InputDecoration(
                        labelText: 'Output format',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final f in _formats)
                          DropdownMenuItem(value: f, child: Text(f)),
                      ],
                      onChanged: slice.isLoading
                          ? null
                          : (v) => setState(() => _outputFormat = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TraqSpacing.md),
              TextField(
                controller: _input,
                minLines: 8,
                maxLines: 14,
                enabled: !slice.isLoading,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Input document',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: TraqSpacing.lg),
              FilledButton(
                onPressed: slice.isLoading
                    ? null
                    : () => cubit.convertEpcisFormat(
                          input: _input.text,
                          inputFormat: _inputFormat,
                          outputFormat: _outputFormat,
                        ),
                child: const Text('Convert'),
              ),
            ],
          ),
        );
      },
    );
  }
}
