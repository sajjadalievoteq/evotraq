import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/gs1_tools/models/gs1_tool_kind.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';

/// Shared Identifier / Validator panel — same CheckDigitUtils path via cubit.
class IdentifierValidationTool extends StatefulWidget {
  const IdentifierValidationTool({
    super.key,
    this.target = Gs1ToolKind.validator,
  });

  final Gs1ToolKind target;

  @override
  State<IdentifierValidationTool> createState() =>
      _IdentifierValidationToolState();
}

class _IdentifierValidationToolState extends State<IdentifierValidationTool> {
  final _formKey = GlobalKey<FormState>();
  final _gtinController = TextEditingController();
  final _glnController = TextEditingController();
  final _ssccController = TextEditingController();
  final _sgtinController = TextEditingController();

  @override
  void dispose() {
    _gtinController.dispose();
    _glnController.dispose();
    _ssccController.dispose();
    _sgtinController.dispose();
    super.dispose();
  }

  void _submit(Gs1ToolsCubit cubit) {
    final gtin = _gtinController.text.trim();
    final gln = _glnController.text.trim();
    final sscc = _ssccController.text.trim();
    final sgtin = _sgtinController.text.trim();
    if (gtin.isEmpty && gln.isEmpty && sscc.isEmpty && sgtin.isEmpty) {
      return;
    }
    cubit.validateIdentifiers(
      gtin: gtin.isEmpty ? null : gtin,
      gln: gln.isEmpty ? null : gln,
      sscc: sscc.isEmpty ? null : sscc,
      sgtin: sgtin.isEmpty ? null : sgtin,
      target: widget.target,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Gs1ToolsCubit, Gs1ToolsState>(
      buildWhen: (p, c) =>
          p.sliceFor(widget.target) != c.sliceFor(widget.target),
      builder: (context, state) {
        final cubit = context.read<Gs1ToolsCubit>();
        final slice = state.sliceFor(widget.target);
        final title = widget.target == Gs1ToolKind.identifier
            ? 'Identifier / GS1 Validation'
            : 'GS1 Identifier Validator';
        return WorkbenchPanelShell(
          title: title,
          slice: slice,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Validate GTIN, GLN, SSCC, and SGTIN including mod-10 check digits.',
                  style: context.text.bodySm.copyWith(
                    color: context.colors.textMuted,
                  ),
                ),
                const SizedBox(height: TraqSpacing.md),
                TextFormField(
                  controller: _gtinController,
                  decoration:
                      const InputDecoration(labelText: 'GTIN (optional)'),
                  keyboardType: TextInputType.number,
                  enabled: !slice.isLoading,
                ),
                const SizedBox(height: TraqSpacing.md),
                TextFormField(
                  controller: _glnController,
                  decoration:
                      const InputDecoration(labelText: 'GLN (optional)'),
                  keyboardType: TextInputType.number,
                  enabled: !slice.isLoading,
                ),
                const SizedBox(height: TraqSpacing.md),
                TextFormField(
                  controller: _ssccController,
                  decoration:
                      const InputDecoration(labelText: 'SSCC (optional)'),
                  keyboardType: TextInputType.number,
                  enabled: !slice.isLoading,
                ),
                const SizedBox(height: TraqSpacing.md),
                TextFormField(
                  controller: _sgtinController,
                  decoration: const InputDecoration(
                    labelText: 'SGTIN (optional)',
                    hintText: '(01)GTIN(21)SERIAL or Digital Link',
                  ),
                  enabled: !slice.isLoading,
                ),
                const SizedBox(height: TraqSpacing.lg),
                FilledButton(
                  onPressed: slice.isLoading ? null : () => _submit(cubit),
                  child: const Text('Validate'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
