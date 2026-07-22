import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_country_code_picker_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';


class TradeItemDescriptiveAttributesCoreGroup extends StatelessWidget {
  const TradeItemDescriptiveAttributesCoreGroup({
    super.key,
    required this.isReadOnly,
    required this.functionalNameController,
    required this.tradeItemDescriptionController,
    required this.gpcBrickCodeController,
    required this.targetMarketCountryController,
    this.showFieldSkeleton = false,
  });

  final bool isReadOnly;
  final TextEditingController functionalNameController;
  final TextEditingController tradeItemDescriptionController;
  final TextEditingController gpcBrickCodeController;
  final TextEditingController targetMarketCountryController;
  final bool showFieldSkeleton;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gs1ValidatedField(
          controller: functionalNameController,
          fieldName: 'functional_name',
          label: GtinUiConstants.labelFunctionalName,
          readOnly: isReadOnly,
          maxLength: 35,
          validator: (v) => GtinFieldValidators.validateFunctionalName(
            v,
            hasGpcBrickCode: gpcBrickCodeController.text.trim().isNotEmpty,
          ),
        ),
        const SizedBox(height: 12),
        Gs1ValidatedField(
          controller: tradeItemDescriptionController,
          fieldName: 'trade_item_description',
          label: GtinUiConstants.labelTradeItemDescription,
          readOnly: isReadOnly,
          maxLength: 200,
          validator: GtinFieldValidators.validateTradeItemDescription,
        ),
        const SizedBox(height: 12),
        Gs1ValidatedField(
          controller: gpcBrickCodeController,
          fieldName: 'gpc_brick_code',
          label: GtinUiConstants.labelGpcBrickCode,
          helperText: GtinUiConstants.helperGpcBrickCode,
          readOnly: isReadOnly,
          keyboardType: TextInputType.number,
          maxLength: 8,
          validator: GtinFieldValidators.validateGpcBrickCode,
        ),
        const SizedBox(height: 12),
        GtinCountryCodePickerField(
          controller: targetMarketCountryController,
          labelText: GtinUiConstants.labelTargetMarketCountryCode,
          helperText: GtinUiConstants.helperIso3166Numeric3,
          enabled: !isReadOnly,
          validator: GtinFieldValidators.validateTargetMarketCountry,
        ),
      ],
    );

    return Gs1GroupCard(
      title: GtinUiConstants.sectionTradeItemDescriptiveAttributes,
      showRequiredStar: true,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      showFieldSkeleton: showFieldSkeleton,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 56),
        ],
      ),
      child: body,
    );
  }
}
