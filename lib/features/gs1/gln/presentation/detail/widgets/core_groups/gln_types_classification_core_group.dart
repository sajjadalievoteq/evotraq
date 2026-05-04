import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/gln_gln_type_chips_field.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

/// GLN types (multi), industry, source, supply-chain / location roles.
class GlnTypesClassificationCoreGroup extends StatelessWidget {
  const GlnTypesClassificationCoreGroup({
    super.key,
    this.showFieldSkeleton = false,
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

  final bool showFieldSkeleton;
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
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(GlnUiConstants.sectionGlnTypesClassification),
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
                key: ValueKey(industryClassification),
                initialValue: industryClassification,
                decoration: const InputDecoration(
                  labelText: GlnUiConstants.labelIndustryClassification,
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: GlnUiConstants.industryHealthcare,
                    child: Text(GlnUiConstants.industryHealthcare),
                  ),
                  DropdownMenuItem(
                    value: GlnUiConstants.industryCpg,
                    child: Text(GlnUiConstants.industryCpg),
                  ),
                  DropdownMenuItem(
                    value: GlnUiConstants.industryApparel,
                    child: Text(GlnUiConstants.industryApparel),
                  ),
                  DropdownMenuItem(
                    value: GlnUiConstants.industryFoodservice,
                    child: Text(GlnUiConstants.industryFoodservice),
                  ),
                  DropdownMenuItem(
                    value: GlnUiConstants.industryOther,
                    child: Text(GlnUiConstants.industryOther),
                  ),
                ],
                onChanged: isEditing ? onIndustryClassificationChanged : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                key: ValueKey(glnSource),
                initialValue: glnSource,
                decoration: const InputDecoration(
                  labelText: GlnUiConstants.labelGlnSource,
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: GlnUiConstants.glnSourceSelfAllocatedValue,
                    child: Text(GlnUiConstants.glnSourceSelfAllocatedLabel),
                  ),
                  DropdownMenuItem(
                    value: GlnUiConstants.glnSourcePartnerValue,
                    child: Text(GlnUiConstants.glnSourcePartnerLabel),
                  ),
                  DropdownMenuItem(
                    value: GlnUiConstants.glnSourceGs1Value,
                    child: Text(GlnUiConstants.glnSourceGs1Label),
                  ),
                  DropdownMenuItem(
                    value: GlnUiConstants.glnSourceRegulatorValue,
                    child: Text(GlnUiConstants.glnSourceRegulatorLabel),
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
          label: GlnUiConstants.labelSupplyChainRoles,
          helperText: GlnUiConstants.helperSupplyChainRoles,
          readOnly: readOnly,
          setFieldError: setFieldError,
          validator: GlnFieldValidators.validateCommaSeparatedRolesOptional,
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: locationRolesController,
          fieldName: 'locationRoles',
          label: GlnUiConstants.labelLocationRoles,
          helperText: GlnUiConstants.helperLocationRoles,
          readOnly: readOnly,
          setFieldError: setFieldError,
          validator: GlnFieldValidators.validateCommaSeparatedRolesOptional,
        ),
      ],
    );

    return GtinFieldSkeletonMask(
      show: showFieldSkeleton,
      child: body,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(GlnUiConstants.sectionGlnTypesClassification),
          GtinSkeletonOutlineField(color: c, height: 72),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: GtinSkeletonOutlineField(color: c, height: 56)),
              const SizedBox(width: 12),
              Expanded(child: GtinSkeletonOutlineField(color: c, height: 56)),
            ],
          ),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 56),
        ],
      ),
    );
  }
}
