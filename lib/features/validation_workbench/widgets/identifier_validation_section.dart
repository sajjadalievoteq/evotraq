import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';
import 'package:traqtrace_app/features/validation_workbench/cubit/validation_workbench_cubit.dart';
import 'package:traqtrace_app/features/validation_workbench/cubit/validation_workbench_state.dart';

class IdentifierValidationSection extends StatefulWidget {
  const IdentifierValidationSection({super.key});

  @override
  State<IdentifierValidationSection> createState() =>
      _IdentifierValidationSectionState();
}

class _IdentifierValidationSectionState
    extends State<IdentifierValidationSection> {
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

  void _submit(ValidationWorkbenchCubit cubit) {
    final gtin = _gtinController.text.trim();
    final gln = _glnController.text.trim();
    final sscc = _ssccController.text.trim();
    final sgtin = _sgtinController.text.trim();
    cubit.validateIdentifiers(
      gtin: gtin.isEmpty ? null : gtin,
      gln: gln.isEmpty ? null : gln,
      sscc: sscc.isEmpty ? null : sscc,
      sgtin: sgtin.isEmpty ? null : sgtin,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ValidationWorkbenchCubit, ValidationWorkbenchState>(
      buildWhen: (p, c) => p.identifier != c.identifier,
      builder: (context, state) {
        final cubit = context.read<ValidationWorkbenchCubit>();
        final slice = state.identifier;
        return WorkbenchPanelShell(
          title: 'Identifier / GS1 Validation',
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
                ),
                const SizedBox(height: TraqSpacing.md),
                TextFormField(
                  controller: _glnController,
                  decoration:
                      const InputDecoration(labelText: 'GLN (optional)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: TraqSpacing.md),
                TextFormField(
                  controller: _ssccController,
                  decoration:
                      const InputDecoration(labelText: 'SSCC (optional)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: TraqSpacing.md),
                TextFormField(
                  controller: _sgtinController,
                  decoration: const InputDecoration(
                    labelText: 'SGTIN / element string (optional)',
                  ),
                ),
                const SizedBox(height: TraqSpacing.lg),
                FilledButton(
                  onPressed: () => _submit(cubit),
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
