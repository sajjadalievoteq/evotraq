import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';

class BatchValidationTool extends StatefulWidget {
  const BatchValidationTool({super.key});

  @override
  State<BatchValidationTool> createState() => _BatchValidationToolState();
}

class _BatchValidationToolState extends State<BatchValidationTool> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Gs1ToolsCubit, Gs1ToolsState>(
      buildWhen: (p, c) => p.batch != c.batch,
      builder: (context, state) {
        final cubit = context.read<Gs1ToolsCubit>();
        final slice = state.batch;
        return WorkbenchPanelShell(
          title: 'Batch Validation',
          slice: slice,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Paste identifiers (one per line). Optional type prefix: '
                'GTIN,value · GLN,value · SSCC,value · SGTIN,gtin,serial. '
                'Bare digits auto-detect by length. Lines starting with # are ignored.',
                style: context.text.bodySm.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
              const SizedBox(height: TraqSpacing.md),
              TextField(
                controller: _controller,
                minLines: 8,
                maxLines: 16,
                enabled: !slice.isLoading,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Paste identifiers',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: TraqSpacing.lg),
              FilledButton(
                onPressed: slice.isLoading
                    ? null
                    : () => cubit.validateBatch(_controller.text),
                child: const Text('Validate batch'),
              ),
            ],
          ),
        );
      },
    );
  }
}
