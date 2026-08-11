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

import 'package:traqtrace_app/features/gs1_tools/screens/gs1_tools/widgets/convert_tool_identifier_fields.dart';

class ConvertToolFields extends StatelessWidget {
  const ConvertToolFields({
    super.key,
    required this.slice,
    required this.mode,
    required this.direction,
    required this.idKind,
    required this.epcType,
    required this.inputController,
    required this.gtinController,
    required this.serialController,
    required this.ssccController,
    required this.glnController,
    required this.extraController,
    required this.urnDlDirections,
    required this.urnDlKinds,
    required this.epcDirections,
    required this.epcKinds,
    required this.elementDirections,
    required this.onDirectionChanged,
    required this.onIdKindChanged,
    required this.onEpcTypeChanged,
    required this.gtinValidator,
    required this.ssccValidator,
    required this.glnValidator,
    required this.requiredValidator,
  });

  final WorkbenchSlice slice;
  final String mode;
  final String direction;
  final String idKind;
  final String epcType;
  final TextEditingController inputController;
  final TextEditingController gtinController;
  final TextEditingController serialController;
  final TextEditingController ssccController;
  final TextEditingController glnController;
  final TextEditingController extraController;
  final List<(String, String)> urnDlDirections;
  final List<(String, String)> urnDlKinds;
  final List<(String, String)> epcDirections;
  final List<(String, String)> epcKinds;
  final List<(String, String)> elementDirections;
  final ValueChanged<String> onDirectionChanged;
  final ValueChanged<String> onIdKindChanged;
  final ValueChanged<String> onEpcTypeChanged;
  final String? Function(String?) gtinValidator;
  final String? Function(String?) ssccValidator;
  final String? Function(String?) glnValidator;
  final String? Function(String?, String) requiredValidator;

  @override
  Widget build(BuildContext context) {
    final loading = slice.isLoading;
    switch (mode) {
      case 'urn-dl':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Gs1ToolModeSelector(
              modes: urnDlDirections,
              value: direction,
              enabled: !loading,
              label: 'Direction',
              onChanged: onDirectionChanged,
            ),
            const SizedBox(height: TraqSpacing.lg),
            if (direction == 'parse')
              ValidatedTextFieldWrapper(
                controller: inputController,
                fieldName: 'input',
                decoration: const InputDecoration(
                  labelText: 'Digital Link URL or EPC URN',
                  hintText: 'https://id.gs1.org/… or urn:epc:id:…',
                ),
                maxLines: 3,
                readOnly: loading,
                validator: (v) => requiredValidator(v, 'Input'),
              )
            else ...[
              Gs1ToolModeSelector(
                modes: urnDlKinds,
                value: idKind,
                enabled: !loading,
                label: 'Identifier kind',
                onChanged: onIdKindChanged,
              ),
              const SizedBox(height: TraqSpacing.md),
              ConvertToolIdentifierFields(
                idKind: idKind,
                loading: loading,
                showLotExtension: true,
                gtinController: gtinController,
                serialController: serialController,
                ssccController: ssccController,
                glnController: glnController,
                extraController: extraController,
                gtinValidator: gtinValidator,
                ssccValidator: ssccValidator,
                glnValidator: glnValidator,
                requiredValidator: requiredValidator,
              ),
            ],
          ],
        );
      case 'epc':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Gs1ToolModeSelector(
              modes: epcDirections,
              value: direction,
              enabled: !loading,
              label: 'Direction',
              onChanged: onDirectionChanged,
            ),
            const SizedBox(height: TraqSpacing.lg),
            if (direction == 'to-epc') ...[
              Gs1ToolModeSelector(
                modes: epcKinds,
                value: idKind,
                enabled: !loading,
                label: 'Identifier kind',
                onChanged: onIdKindChanged,
              ),
              const SizedBox(height: TraqSpacing.md),
              ConvertToolIdentifierFields(
                idKind: idKind,
                loading: loading,
                showLotExtension: false,
                gtinController: gtinController,
                serialController: serialController,
                ssccController: ssccController,
                glnController: glnController,
                extraController: extraController,
                gtinValidator: gtinValidator,
                ssccValidator: ssccValidator,
                glnValidator: glnValidator,
                requiredValidator: requiredValidator,
              ),
            ] else ...[
              Gs1ToolModeSelector(
                modes: const [
                  ('SGTIN', 'SGTIN'),
                  ('SSCC', 'SSCC'),
                  ('GLN', 'GLN'),
                ],
                value: epcType,
                enabled: !loading,
                label: 'GS1 type',
                onChanged: onEpcTypeChanged,
              ),
              const SizedBox(height: TraqSpacing.md),
              ValidatedTextFieldWrapper(
                controller: inputController,
                fieldName: 'epc_uri',
                decoration: const InputDecoration(labelText: 'EPC URI'),
                readOnly: loading,
                validator: (v) => requiredValidator(v, 'EPC URI'),
              ),
            ],
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Gs1ToolModeSelector(
              modes: elementDirections,
              value: direction,
              enabled: !loading,
              label: 'Direction',
              onChanged: onDirectionChanged,
            ),
            const SizedBox(height: TraqSpacing.lg),
            ValidatedTextFieldWrapper(
              controller: inputController,
              fieldName: 'element_input',
              decoration: InputDecoration(
                labelText: direction == 'dl-to-element'
                    ? 'Digital Link URL'
                    : 'GS1 element string',
              ),
              maxLines: 4,
              readOnly: loading,
              validator: (v) => requiredValidator(v, 'Input'),
            ),
          ],
        );
    }
  }
}
