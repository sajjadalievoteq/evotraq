import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';

enum _EpcMode { sgtin, sscc, gln, epcToGs1, element }

class EpcConversionTool extends StatefulWidget {
  const EpcConversionTool({super.key});

  @override
  State<EpcConversionTool> createState() => _EpcConversionToolState();
}

class _EpcConversionToolState extends State<EpcConversionTool> {
  final _formKey = GlobalKey<FormState>();
  final _gtinController = TextEditingController();
  final _serialController = TextEditingController();
  final _ssccController = TextEditingController();
  final _glnController = TextEditingController();
  final _extensionController = TextEditingController();
  final _epcUriController = TextEditingController();
  final _elementController = TextEditingController();
  _EpcMode _mode = _EpcMode.sgtin;
  String _epcType = 'SGTIN';

  @override
  void dispose() {
    _gtinController.dispose();
    _serialController.dispose();
    _ssccController.dispose();
    _glnController.dispose();
    _extensionController.dispose();
    _epcUriController.dispose();
    _elementController.dispose();
    super.dispose();
  }

  void _submit(Gs1ToolsCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    switch (_mode) {
      case _EpcMode.sgtin:
        cubit.convertSgtinToEpc(
          gtin: _gtinController.text,
          serial: _serialController.text,
        );
      case _EpcMode.sscc:
        cubit.convertSsccToEpc(_ssccController.text);
      case _EpcMode.gln:
        cubit.convertGlnToEpc(
          gln: _glnController.text,
          extension: _extensionController.text,
        );
      case _EpcMode.epcToGs1:
        cubit.convertEpcToGs1(
          epcUri: _epcUriController.text,
          type: _epcType,
        );
      case _EpcMode.element:
        cubit.convertElementStringToEpc(_elementController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Gs1ToolsCubit, Gs1ToolsState>(
      buildWhen: (p, c) => p.epc != c.epc,
      builder: (context, state) {
        final cubit = context.read<Gs1ToolsCubit>();
        final slice = state.epc;
        return WorkbenchPanelShell(
          title: 'EPC Conversion',
          slice: slice,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<_EpcMode>(
                  segments: const [
                    ButtonSegment(
                      value: _EpcMode.sgtin,
                      label: Text('SGTIN→EPC'),
                    ),
                    ButtonSegment(
                      value: _EpcMode.sscc,
                      label: Text('SSCC→EPC'),
                    ),
                    ButtonSegment(
                      value: _EpcMode.gln,
                      label: Text('GLN→EPC'),
                    ),
                    ButtonSegment(
                      value: _EpcMode.epcToGs1,
                      label: Text('EPC→GS1'),
                    ),
                    ButtonSegment(
                      value: _EpcMode.element,
                      label: Text('Element→EPC'),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: slice.isLoading
                      ? null
                      : (s) => setState(() => _mode = s.first),
                ),
                const SizedBox(height: TraqSpacing.lg),
                ...switch (_mode) {
                  _EpcMode.sgtin => [
                    TextFormField(
                      controller: _gtinController,
                      decoration: const InputDecoration(labelText: 'GTIN'),
                      keyboardType: TextInputType.number,
                      enabled: !slice.isLoading,
                      validator: (v) => CheckDigitUtils.validateGS1CheckDigit(
                        v,
                        allowedLengths: CheckDigitUtils.gtinLengths,
                        label: 'GTIN',
                      ),
                    ),
                    const SizedBox(height: TraqSpacing.md),
                    TextFormField(
                      controller: _serialController,
                      decoration: const InputDecoration(labelText: 'Serial'),
                      enabled: !slice.isLoading,
                      validator: (v) =>
                          (v ?? '').trim().isEmpty ? 'Serial is required' : null,
                    ),
                  ],
                  _EpcMode.sscc => [
                    TextFormField(
                      controller: _ssccController,
                      decoration: const InputDecoration(labelText: 'SSCC'),
                      keyboardType: TextInputType.number,
                      enabled: !slice.isLoading,
                      validator: (v) => CheckDigitUtils.validateGS1CheckDigit(
                        v,
                        allowedLengths: CheckDigitUtils.ssccLengths,
                        label: 'SSCC',
                      ),
                    ),
                  ],
                  _EpcMode.gln => [
                    TextFormField(
                      controller: _glnController,
                      decoration: const InputDecoration(labelText: 'GLN'),
                      keyboardType: TextInputType.number,
                      enabled: !slice.isLoading,
                      validator: (v) => CheckDigitUtils.validateGS1CheckDigit(
                        v,
                        allowedLengths: CheckDigitUtils.glnLengths,
                        label: 'GLN',
                      ),
                    ),
                    const SizedBox(height: TraqSpacing.md),
                    TextFormField(
                      controller: _extensionController,
                      decoration: const InputDecoration(
                        labelText: 'Extension (optional)',
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !slice.isLoading,
                    ),
                  ],
                  _EpcMode.epcToGs1 => [
                    DropdownButtonFormField<String>(
                      value: _epcType,
                      decoration: const InputDecoration(labelText: 'GS1 type'),
                      items: const [
                        DropdownMenuItem(value: 'SGTIN', child: Text('SGTIN')),
                        DropdownMenuItem(value: 'SSCC', child: Text('SSCC')),
                        DropdownMenuItem(value: 'GLN', child: Text('GLN')),
                      ],
                      onChanged: slice.isLoading
                          ? null
                          : (v) => setState(() => _epcType = v!),
                    ),
                    const SizedBox(height: TraqSpacing.md),
                    TextFormField(
                      controller: _epcUriController,
                      decoration: const InputDecoration(labelText: 'EPC URI'),
                      enabled: !slice.isLoading,
                      validator: (v) =>
                          (v ?? '').trim().isEmpty ? 'EPC URI is required' : null,
                    ),
                  ],
                  _EpcMode.element => [
                    TextFormField(
                      controller: _elementController,
                      decoration: const InputDecoration(
                        labelText: 'GS1 element string',
                        hintText: 'Paste (01)…(21)… or FNC1-separated AIs',
                      ),
                      maxLines: 4,
                      enabled: !slice.isLoading,
                      validator: (v) => (v ?? '').trim().isEmpty
                          ? 'Element string is required'
                          : null,
                    ),
                  ],
                },
                const SizedBox(height: TraqSpacing.lg),
                FilledButton(
                  onPressed: slice.isLoading ? null : () => _submit(cubit),
                  child: const Text('Convert'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
