import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/features/gs1/widgets/validated_text_field_wrapper.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_instructions.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';

/// GS1 registry lookup for a single GTIN or GLN. Requires network access.
class LookupTool extends StatefulWidget {
  const LookupTool({super.key});

  @override
  State<LookupTool> createState() => _LookupToolState();
}

class _LookupToolState extends State<LookupTool> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  void _submit(Gs1ToolsCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    cubit.lookupGs1(_identifierController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Gs1ToolsCubit, Gs1ToolsState>(
      buildWhen: (p, c) => p.lookup != c.lookup,
      builder: (context, state) {
        final cubit = context.read<Gs1ToolsCubit>();
        final slice = state.lookup;
        return WorkbenchPanelShell(
          title: 'GS1 Lookup',
          slice: slice,
          instructions: const WorkbenchInstructions(
            summary:
                'Look up the company/product registered to a GTIN or GLN in GS1\'s registry.',
            useCase:
                'Use to verify a trading partner or product identity against the official GS1 registry.',
            audience: 'Advanced (requires connection)',
            steps: [
              'Enter a GTIN or GLN.',
              'Run the lookup (requires network / configured access).',
              'See the registered party, or a clear \'unavailable\' if the registry isn\'t reachable.',
            ],
            exampleInput: '00614141073464',
            exampleNote:
                'Returns registrant if the registry is configured; otherwise \'unavailable\'',
          ),
          onLoadExample: (example) {
            setState(() => _identifierController.text = example);
          },
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ValidatedTextFieldWrapper(
                  controller: _identifierController,
                  fieldName: 'identifier',
                  decoration: const InputDecoration(
                    labelText: 'GTIN or GLN',
                  ),
                  keyboardType: TextInputType.number,
                  readOnly: slice.isLoading,
                  validator: (v) => (v ?? '').trim().isEmpty
                      ? 'Enter a GTIN or GLN'
                      : null,
                ),
                const SizedBox(height: TraqSpacing.lg),
                CustomElevatedButton(
                  label: 'Lookup',
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
