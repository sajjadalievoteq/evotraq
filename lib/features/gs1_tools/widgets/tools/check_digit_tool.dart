import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';

class CheckDigitTool extends StatefulWidget {
  const CheckDigitTool({super.key});

  @override
  State<CheckDigitTool> createState() => _CheckDigitToolState();
}

class _CheckDigitToolState extends State<CheckDigitTool> {
  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();
  String _kind = 'gtin';

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _submit(Gs1ToolsCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    cubit.computeCheckDigit(input: _inputController.text, kind: _kind);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Gs1ToolsCubit, Gs1ToolsState>(
      buildWhen: (p, c) => p.checkDigit != c.checkDigit,
      builder: (context, state) {
        final cubit = context.read<Gs1ToolsCubit>();
        final slice = state.checkDigit;
        return WorkbenchPanelShell(
          title: 'Check-Digit Calculator',
          slice: slice,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _kind,
                  decoration: const InputDecoration(labelText: 'Kind'),
                  items: const [
                    DropdownMenuItem(value: 'gtin', child: Text('GTIN')),
                    DropdownMenuItem(value: 'gln', child: Text('GLN')),
                    DropdownMenuItem(value: 'sscc', child: Text('SSCC')),
                  ],
                  onChanged: slice.isLoading
                      ? null
                      : (v) => setState(() => _kind = v!),
                ),
                const SizedBox(height: TraqSpacing.md),
                TextFormField(
                  controller: _inputController,
                  decoration: const InputDecoration(
                    labelText: 'Identifier or body (digits)',
                    hintText: 'Enter GTIN, GLN, or SSCC',
                  ),
                  keyboardType: TextInputType.number,
                  enabled: !slice.isLoading,
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Input is required' : null,
                ),
                const SizedBox(height: TraqSpacing.lg),
                FilledButton(
                  onPressed: slice.isLoading ? null : () => _submit(cubit),
                  child: const Text('Compute / Validate'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
