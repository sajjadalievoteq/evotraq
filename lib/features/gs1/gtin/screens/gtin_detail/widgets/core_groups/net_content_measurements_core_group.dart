import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';


class NetContentMeasurementsCoreGroup extends StatelessWidget {
  const NetContentMeasurementsCoreGroup({
    super.key,
    required this.isReadOnly,
    required this.netContentController,
    required this.netContentUomController,
    required this.grossWeightController,
    required this.grossWeightUomController,
    required this.heightController,
    required this.widthController,
    required this.depthController,
    required this.dimUomController,
    this.showFieldSkeleton = false,
  });

  final bool isReadOnly;
  final bool showFieldSkeleton;
  final TextEditingController netContentController;
  final TextEditingController netContentUomController;
  final TextEditingController grossWeightController;
  final TextEditingController grossWeightUomController;
  final TextEditingController heightController;
  final TextEditingController widthController;
  final TextEditingController depthController;
  final TextEditingController dimUomController;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gs1ValidatedField(
          controller: netContentController,
          fieldName: 'net_content_value',
          label: GtinUiConstants.labelNetContentValue,
          readOnly: isReadOnly,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          validator: GtinFieldValidators.validateNetContentValueRequired,
        ),
        const SizedBox(height: 12),
        Gs1ValidatedField(
          controller: netContentUomController,
          fieldName: 'net_content_uom',
          label: GtinUiConstants.labelNetContentUom,
          helperText: GtinUiConstants.helperUneceRec20,
          readOnly: isReadOnly,
          maxLength: 3,
          validator: GtinFieldValidators.validateNetContentUomRequired,
        ),
        const SizedBox(height: 12),
        Gs1ValidatedField(
          controller: grossWeightController,
          fieldName: 'gross_weight_value',
          label: GtinUiConstants.labelGrossWeightValue,
          readOnly: isReadOnly,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          validator: GtinFieldValidators.validateGrossWeightValue,
        ),
        const SizedBox(height: 12),
        Gs1ValidatedField(
          controller: grossWeightUomController,
          fieldName: 'gross_weight_uom',
          label: GtinUiConstants.labelGrossWeightUom,
          helperText: GtinUiConstants.helperUneceRec20,
          readOnly: isReadOnly,
          maxLength: 3,
          validator: GtinFieldValidators.validateGrossWeightUom,
        ),
        const SizedBox(height: 12),
        Gs1ValidatedField(
          controller: heightController,
          fieldName: 'height_value',
          label: GtinUiConstants.labelHeight,
          readOnly: isReadOnly,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          validator: GtinFieldValidators.validateHeightValue,
        ),
        const SizedBox(height: 12),
        Gs1ValidatedField(
          controller: widthController,
          fieldName: 'width_value',
          label: GtinUiConstants.labelWidth,
          readOnly: isReadOnly,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          validator: GtinFieldValidators.validateWidthValue,
        ),
        const SizedBox(height: 12),
        Gs1ValidatedField(
          controller: depthController,
          fieldName: 'depth_value',
          label: GtinUiConstants.labelDepth,
          readOnly: isReadOnly,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          validator: GtinFieldValidators.validateDepthValue,
        ),
        const SizedBox(height: 12),
        Gs1ValidatedField(
          controller: dimUomController,
          fieldName: 'dim_uom',
          label: GtinUiConstants.labelDimensionUom,
          helperText: GtinUiConstants.helperUneceRec20,
          readOnly: isReadOnly,
          maxLength: 3,
          validator: GtinFieldValidators.validateDimUom,
        ),
      ],
    );

    return Gs1GroupCard(
      title: GtinUiConstants.sectionNetContentMeasurements,
      showRequiredStar: true,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      showFieldSkeleton: showFieldSkeleton,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          for (var i = 0; i < 8; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            GtinSkeletonOutlineField(
              color: c,
              height: {1, 3, 7}.contains(i) ? 76 : 56,
            ),
          ],
        ],
      ),
      child: body,
    );
  }
}
