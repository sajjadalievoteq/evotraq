import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';

enum _DigitalLinkMode { build, parse }

class DigitalLinkTool extends StatefulWidget {
  const DigitalLinkTool({super.key});

  @override
  State<DigitalLinkTool> createState() => _DigitalLinkToolState();
}

class _DigitalLinkToolState extends State<DigitalLinkTool> {
  final _formKey = GlobalKey<FormState>();
  final _primaryController = TextEditingController();
  final _serialController = TextEditingController();
  final _lotController = TextEditingController();
  final _extensionController = TextEditingController();
  final _parseController = TextEditingController();
  _DigitalLinkMode _mode = _DigitalLinkMode.build;
  String _kind = 'gtin';

  @override
  void dispose() {
    _primaryController.dispose();
    _serialController.dispose();
    _lotController.dispose();
    _extensionController.dispose();
    _parseController.dispose();
    super.dispose();
  }

  void _submit(Gs1ToolsCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    if (_mode == _DigitalLinkMode.parse) {
      cubit.parseDigitalLink(_parseController.text);
      return;
    }
    cubit.buildDigitalLink(
      kind: _kind,
      primary: _primaryController.text,
      serial: _serialController.text,
      lot: _lotController.text,
      extension: _extensionController.text,
    );
  }

  String? _validatePrimary(String? v) {
    return switch (_kind) {
      'sscc' => CheckDigitUtils.validateGS1CheckDigit(
          v,
          allowedLengths: CheckDigitUtils.ssccLengths,
          label: 'SSCC',
        ),
      'gln' => CheckDigitUtils.validateGS1CheckDigit(
          v,
          allowedLengths: CheckDigitUtils.glnLengths,
          label: 'GLN',
        ),
      _ => CheckDigitUtils.validateGS1CheckDigit(
          v,
          allowedLengths: CheckDigitUtils.gtinLengths,
          label: 'GTIN',
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Gs1ToolsCubit, Gs1ToolsState>(
      buildWhen: (p, c) => p.digitalLink != c.digitalLink,
      builder: (context, state) {
        final cubit = context.read<Gs1ToolsCubit>();
        final slice = state.digitalLink;
        return WorkbenchPanelShell(
          title: 'Digital Link',
          slice: slice,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<_DigitalLinkMode>(
                  segments: const [
                    ButtonSegment(value: _DigitalLinkMode.build, label: Text('Build')),
                    ButtonSegment(value: _DigitalLinkMode.parse, label: Text('Parse')),
                  ],
                  selected: {_mode},
                  onSelectionChanged: slice.isLoading
                      ? null
                      : (s) => setState(() => _mode = s.first),
                ),
                const SizedBox(height: TraqSpacing.lg),
                if (_mode == _DigitalLinkMode.build) ...[
                  DropdownButtonFormField<String>(
                    value: _kind,
                    decoration: const InputDecoration(labelText: 'Kind'),
                    items: const [
                      DropdownMenuItem(value: 'gtin', child: Text('GTIN')),
                      DropdownMenuItem(value: 'sgtin', child: Text('SGTIN')),
                      DropdownMenuItem(value: 'sscc', child: Text('SSCC')),
                      DropdownMenuItem(value: 'gln', child: Text('GLN')),
                    ],
                    onChanged: slice.isLoading
                        ? null
                        : (v) => setState(() => _kind = v!),
                  ),
                  const SizedBox(height: TraqSpacing.md),
                  TextFormField(
                    controller: _primaryController,
                    decoration: InputDecoration(
                      labelText: _kind == 'sscc'
                          ? 'SSCC'
                          : _kind == 'gln'
                              ? 'GLN'
                              : 'GTIN',
                    ),
                    keyboardType: TextInputType.number,
                    enabled: !slice.isLoading,
                    validator: _validatePrimary,
                  ),
                  if (_kind == 'sgtin') ...[
                    const SizedBox(height: TraqSpacing.md),
                    TextFormField(
                      controller: _serialController,
                      decoration: const InputDecoration(labelText: 'Serial'),
                      enabled: !slice.isLoading,
                      validator: (v) =>
                          (v ?? '').trim().isEmpty ? 'Serial is required' : null,
                    ),
                  ],
                  if (_kind == 'gtin') ...[
                    const SizedBox(height: TraqSpacing.md),
                    TextFormField(
                      controller: _lotController,
                      decoration: const InputDecoration(
                        labelText: 'Lot / batch (optional)',
                      ),
                      enabled: !slice.isLoading,
                    ),
                  ],
                  if (_kind == 'gln') ...[
                    const SizedBox(height: TraqSpacing.md),
                    TextFormField(
                      controller: _extensionController,
                      decoration: const InputDecoration(
                        labelText: 'Extension (default 0)',
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !slice.isLoading,
                    ),
                  ],
                ] else
                  TextFormField(
                    controller: _parseController,
                    decoration: const InputDecoration(
                      labelText: 'Digital Link URL or URN',
                      hintText: 'https://id.gs1.org/…',
                    ),
                    maxLines: 3,
                    enabled: !slice.isLoading,
                    validator: (v) => (v ?? '').trim().isEmpty
                        ? 'Digital Link is required'
                        : null,
                  ),
                const SizedBox(height: TraqSpacing.lg),
                FilledButton(
                  onPressed: slice.isLoading ? null : () => _submit(cubit),
                  child: Text(_mode == _DigitalLinkMode.build ? 'Build' : 'Parse'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
