import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';

enum _AiParserMode { parse, build }

class AiParserTool extends StatefulWidget {
  const AiParserTool({super.key});

  @override
  State<AiParserTool> createState() => _AiParserToolState();
}

class _AiParserToolState extends State<AiParserTool> {
  final _formKey = GlobalKey<FormState>();
  final _parseController = TextEditingController();
  final _ai1Controller = TextEditingController();
  final _val1Controller = TextEditingController();
  final _ai2Controller = TextEditingController();
  final _val2Controller = TextEditingController();
  final _ai3Controller = TextEditingController();
  final _val3Controller = TextEditingController();
  _AiParserMode _mode = _AiParserMode.parse;

  @override
  void dispose() {
    _parseController.dispose();
    _ai1Controller.dispose();
    _val1Controller.dispose();
    _ai2Controller.dispose();
    _val2Controller.dispose();
    _ai3Controller.dispose();
    _val3Controller.dispose();
    super.dispose();
  }

  void _submit(Gs1ToolsCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    if (_mode == _AiParserMode.parse) {
      cubit.parseElementString(_parseController.text);
      return;
    }
    cubit.buildElementString({
      _ai1Controller.text: _val1Controller.text,
      _ai2Controller.text: _val2Controller.text,
      _ai3Controller.text: _val3Controller.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Gs1ToolsCubit, Gs1ToolsState>(
      buildWhen: (p, c) => p.aiParser != c.aiParser,
      builder: (context, state) {
        final cubit = context.read<Gs1ToolsCubit>();
        final slice = state.aiParser;
        return WorkbenchPanelShell(
          title: 'AI Parser',
          slice: slice,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<_AiParserMode>(
                  segments: const [
                    ButtonSegment(value: _AiParserMode.parse, label: Text('Parse')),
                    ButtonSegment(value: _AiParserMode.build, label: Text('Build')),
                  ],
                  selected: {_mode},
                  onSelectionChanged: slice.isLoading
                      ? null
                      : (s) => setState(() => _mode = s.first),
                ),
                const SizedBox(height: TraqSpacing.lg),
                if (_mode == _AiParserMode.parse)
                  TextFormField(
                    controller: _parseController,
                    decoration: const InputDecoration(
                      labelText: 'GS1 element string',
                      hintText: 'Paste barcode data or human-readable AIs',
                    ),
                    maxLines: 6,
                    enabled: !slice.isLoading,
                    validator: (v) => (v ?? '').trim().isEmpty
                        ? 'Element string is required'
                        : null,
                  )
                else ...[
                  _AiPairRow(
                    aiController: _ai1Controller,
                    valueController: _val1Controller,
                    enabled: !slice.isLoading,
                    required: true,
                  ),
                  const SizedBox(height: TraqSpacing.md),
                  _AiPairRow(
                    aiController: _ai2Controller,
                    valueController: _val2Controller,
                    enabled: !slice.isLoading,
                  ),
                  const SizedBox(height: TraqSpacing.md),
                  _AiPairRow(
                    aiController: _ai3Controller,
                    valueController: _val3Controller,
                    enabled: !slice.isLoading,
                  ),
                ],
                const SizedBox(height: TraqSpacing.lg),
                FilledButton(
                  onPressed: slice.isLoading ? null : () => _submit(cubit),
                  child: Text(_mode == _AiParserMode.parse ? 'Parse' : 'Build'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AiPairRow extends StatelessWidget {
  const _AiPairRow({
    required this.aiController,
    required this.valueController,
    required this.enabled,
    this.required = false,
  });

  final TextEditingController aiController;
  final TextEditingController valueController;
  final bool enabled;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: aiController,
            decoration: const InputDecoration(labelText: 'AI'),
            keyboardType: TextInputType.number,
            enabled: enabled,
            validator: required
                ? (v) => (v ?? '').trim().isEmpty ? 'AI is required' : null
                : null,
          ),
        ),
        const SizedBox(width: TraqSpacing.md),
        Expanded(
          flex: 5,
          child: TextFormField(
            controller: valueController,
            decoration: const InputDecoration(labelText: 'Value'),
            enabled: enabled,
            validator: required
                ? (v) => (v ?? '').trim().isEmpty ? 'Value is required' : null
                : null,
          ),
        ),
      ],
    );
  }
}
