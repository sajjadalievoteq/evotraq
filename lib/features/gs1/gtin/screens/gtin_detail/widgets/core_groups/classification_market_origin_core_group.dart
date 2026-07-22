import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_country_code_picker_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';


class ClassificationMarketOriginCoreGroup extends StatelessWidget {
  const ClassificationMarketOriginCoreGroup({
    super.key,
    required this.isReadOnly,
    required this.countryOfOriginController,
    this.showFieldSkeleton = false,
  });

  final bool isReadOnly;
  final TextEditingController countryOfOriginController;
  final bool showFieldSkeleton;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: GtinUiConstants.sectionClassificationMarketOrigin,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      showFieldSkeleton: showFieldSkeleton,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          GtinSkeletonOutlineField(color: c, height: 76),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GtinCountryCodePickerField(
            controller: countryOfOriginController,
            labelText: GtinUiConstants.labelCountryOfOrigin,
            helperText: GtinUiConstants.helperIso3166Numeric3,
            enabled: !isReadOnly,
            validator: GtinFieldValidators.validateCountryOfOrigin,
          ),
        ],
      ),
    );
  }
}
