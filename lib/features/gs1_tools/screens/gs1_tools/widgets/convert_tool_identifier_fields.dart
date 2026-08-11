import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/gtin_entry_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/validated_text_field_wrapper.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/mode_selector.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_instructions.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';

/// Consolidated conversion workbench: URN ⇄ Digital Link, EPC ⇄ GS1
/// identifiers, and Digital Link ⇄ element string.

class ConvertToolIdentifierFields extends StatelessWidget {
  const ConvertToolIdentifierFields({
    super.key,
    required this.idKind,
    required this.loading,
    required this.showLotExtension,
    required this.gtinController,
    required this.serialController,
    required this.ssccController,
    required this.glnController,
    required this.extraController,
    required this.gtinValidator,
    required this.ssccValidator,
    required this.glnValidator,
    required this.requiredValidator,
  });

  final String idKind;
  final bool loading;
  final bool showLotExtension;
  final TextEditingController gtinController;
  final TextEditingController serialController;
  final TextEditingController ssccController;
  final TextEditingController glnController;
  final TextEditingController extraController;
  final String? Function(String?) gtinValidator;
  final String? Function(String?) ssccValidator;
  final String? Function(String?) glnValidator;
  final String? Function(String?, String) requiredValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: switch (idKind) {
        'sgtin' => [
          GtinEntryField(
            controller: gtinController,
            label: 'GTIN',
            enabled: !loading,
            validator: gtinValidator,
          ),
          const SizedBox(height: TraqSpacing.md),
          ValidatedTextFieldWrapper(
            controller: serialController,
            fieldName: 'serial',
            decoration: const InputDecoration(labelText: 'Serial'),
            readOnly: loading,
            validator: (v) => requiredValidator(v, 'Serial'),
          ),
        ],
        'sscc' => [
          ValidatedTextFieldWrapper(
            controller: ssccController,
            fieldName: 'sscc',
            decoration: const InputDecoration(labelText: 'SSCC'),
            readOnly: loading,
            keyboardType: TextInputType.number,
            validator: ssccValidator,
          ),
        ],
        'gln' => [
          ValidatedTextFieldWrapper(
            controller: glnController,
            fieldName: 'gln',
            decoration: const InputDecoration(labelText: 'GLN'),
            readOnly: loading,
            keyboardType: TextInputType.number,
            validator: glnValidator,
          ),
          const SizedBox(height: TraqSpacing.md),
          ValidatedTextFieldWrapper(
            controller: extraController,
            fieldName: 'extension',
            decoration: const InputDecoration(
              labelText: 'Extension (optional)',
            ),
            readOnly: loading,
            keyboardType: TextInputType.number,
          ),
        ],
        _ => [
          GtinEntryField(
            controller: gtinController,
            label: 'GTIN',
            enabled: !loading,
            validator: gtinValidator,
          ),
          if (showLotExtension) ...[
            const SizedBox(height: TraqSpacing.md),
            ValidatedTextFieldWrapper(
              controller: extraController,
              fieldName: 'lot',
              decoration: const InputDecoration(
                labelText: 'Lot / batch (optional)',
              ),
              readOnly: loading,
            ),
          ],
        ],
      },
    );
  }
}
