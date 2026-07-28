import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';

class SerializeImportTool extends StatefulWidget {
  const SerializeImportTool({super.key});

  @override
  State<SerializeImportTool> createState() => _SerializeImportToolState();
}

class _SerializeImportToolState extends State<SerializeImportTool> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Gs1ToolsCubit, Gs1ToolsState>(
      buildWhen: (p, c) => p.serializeImport != c.serializeImport,
      builder: (context, state) {
        final cubit = context.read<Gs1ToolsCubit>();
        final slice = state.serializeImport;
        return WorkbenchPanelShell(
          title: 'Import',
          slice: slice,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Paste an EPCIS XML or JSON-LD document to import events via the backend.',
                style: context.text.bodySm.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
              const SizedBox(height: TraqSpacing.md),
              TextField(
                controller: _input,
                minLines: 10,
                maxLines: 16,
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
                        : () => cubit.importEpcisEvents(
                              input: _input.text,
                              format: 'XML',
                            ),
                    child: const Text('Import XML'),
                  ),
                  FilledButton.tonal(
                    onPressed: slice.isLoading
                        ? null
                        : () => cubit.importEpcisEvents(
                              input: _input.text,
                              format: 'JSON-LD',
                            ),
                    child: const Text('Import JSON-LD'),
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
