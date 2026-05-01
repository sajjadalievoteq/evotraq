import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/gln_detail_form_types.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/gln_gln_type_chips_field.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_field_validators.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

/// GLN types (multi), industry, source, supply-chain / location roles.
class GlnTypesClassificationCoreGroup extends StatelessWidget {
  const GlnTypesClassificationCoreGroup({
    super.key,
    required this.isEditing,
    required this.setFieldError,
    required this.glnTypes,
    required this.onGlnTypesChanged,
    required this.glnTypesErrorText,
    required this.industryClassification,
    required this.onIndustryClassificationChanged,
    required this.glnSource,
    required this.onGlnSourceChanged,
    required this.supplyChainRolesController,
    required this.locationRolesController,
  });

  final bool isEditing;
  final GlnFormSetFieldError setFieldError;
  final List<String> glnTypes;
  final ValueChanged<List<String>> onGlnTypesChanged;
  final String? glnTypesErrorText;
  final String industryClassification;
  final ValueChanged<String?> onIndustryClassificationChanged;
  final String glnSource;
  final ValueChanged<String?> onGlnSourceChanged;
  final TextEditingController supplyChainRolesController;
  final TextEditingController locationRolesController;

  @override
  Widget build(BuildContext context) {
    final readOnly = !isEditing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('GLN types * & classification'),
        GlnGlnTypeChipsField(
          selection: glnTypes,
          onChanged: onGlnTypesChanged,
          enabled: isEditing,
          errorText: glnTypesErrorText,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: industryClassification,
                decoration: const InputDecoration(
                  labelText: 'Industry classification',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'HEALTHCARE',
                    child: Text('HEALTHCARE'),
                  ),
                  DropdownMenuItem(value: 'CPG', child: Text('CPG')),
                  DropdownMenuItem(
                    value: 'APPAREL',
                    child: Text('APPAREL'),
                  ),
                  DropdownMenuItem(
                    value: 'FOODSERVICE',
                    child: Text('FOODSERVICE'),
                  ),
                  DropdownMenuItem(value: 'OTHER', child: Text('OTHER')),
                ],
                onChanged: isEditing ? onIndustryClassificationChanged : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: glnSource,
                decoration: const InputDecoration(
                  labelText: 'GLN source',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'SELF_ALLOCATED',
                    child: Text('Self allocated'),
                  ),
                  DropdownMenuItem(
                    value: 'PARTNER_PROVIDED',
                    child: Text('Partner provided'),
                  ),
                  DropdownMenuItem(
                    value: 'GS1_MANAGED_GLN',
                    child: Text('GS1 managed'),
                  ),
                  DropdownMenuItem(
                    value: 'REGULATOR_ASSIGNED',
                    child: Text('Regulator assigned'),
                  ),
                ],
                onChanged: isEditing ? onGlnSourceChanged : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: supplyChainRolesController,
          fieldName: 'supplyChainRoles',
          label: 'Supply-chain roles',
          helperText: 'Comma-separated (e.g. MANUFACTURER, DISTRIBUTOR)',
          readOnly: readOnly,
          setFieldError: setFieldError,
          validator: GlnFieldValidators.validateCommaSeparatedRolesOptional,
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: locationRolesController,
          fieldName: 'locationRoles',
          label: 'Location roles',
          helperText: 'Comma-separated (e.g. WAREHOUSE, PHARMACY)',
          readOnly: readOnly,
          setFieldError: setFieldError,
          validator: GlnFieldValidators.validateCommaSeparatedRolesOptional,
        ),
      ],
    );
  }
}
