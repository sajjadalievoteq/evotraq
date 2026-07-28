import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';

class SerializeValidateTool extends StatefulWidget {
  const SerializeValidateTool({super.key});

  @override
  State<SerializeValidateTool> createState() => _SerializeValidateToolState();
}

class _SerializeValidateToolState extends State<SerializeValidateTool> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Gs1ToolsCubit, Gs1ToolsState>(
      buildWhen: (p, c) => p.serializeValidate != c.serializeValidate,
      builder: (context, state) {
        final cubit = context.read<Gs1ToolsCubit>();
        final slice = state.serializeValidate;
        return WorkbenchPanelShell(
          title: 'Schema Validation',
          slice: slice,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Validate an EPCIS document against XML (1.2/1.3) or JSON-LD (2.0) schemas.',
                style: context.text.bodySm.copyWith(
                  color: context.colors.textMuted,
                ),
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
                  labelText: 'EPCIS document',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: TraqSpacing.lg),
              Wrap(
                spacing: TraqSpacing.sm,
                runSpacing: TraqSpacing.sm,
                children: [
                  FilledButton(
                    onPressed: slice.isLoading
                        ? null
                        : () => cubit.validateEpcisSchema(
                              input: _input.text,
                              format: 'XML',
                            ),
                    child: const Text('Validate XML'),
                  ),
                  FilledButton.tonal(
                    onPressed: slice.isLoading
                        ? null
                        : () => cubit.validateEpcisSchema(
                              input: _input.text,
                              format: 'JSON',
                            ),
                    child: const Text('Validate JSON-LD'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
