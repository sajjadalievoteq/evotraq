import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_extension_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/regulatory_authority/validators/regulatory_authority_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

class RegulatoryAuthorityLabelingSection extends StatelessWidget {
  const RegulatoryAuthorityLabelingSection({
    super.key,
    required this.isReadOnly,
    required this.showFieldSkeleton,
    required this.isRegulatoryAuthorityMarket,
    required this.regulatedProductNameController,
  });

  final bool isReadOnly;
  final bool showFieldSkeleton;
  final bool isRegulatoryAuthorityMarket;
  final TextEditingController regulatedProductNameController;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(
            GtinRegulatoryAuthorityExtensionUiConstants.sectionLabeling,
            padding: EdgeInsets.only(bottom: 12),
          ),
          GtinValidatedField(
            controller: regulatedProductNameController,
            fieldName: 'regulatedProductName',
            label: GtinRegulatoryAuthorityExtensionUiConstants.labelRegulatedProductName,
            helperText: GtinRegulatoryAuthorityExtensionUiConstants.helperRegulatedProductName,
            maxLength: 200,
            inputFormatters: [LengthLimitingTextInputFormatter(200)],
            readOnly: isReadOnly,
            validator: (v) => RegulatoryAuthorityValidators
                .validateEnglishRegulatedNameForRegulatoryAuthority(
              v,
              isRegulatoryAuthorityMarket: isRegulatoryAuthorityMarket,
            ),
          ),
        ],
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: outline.withOpacity(0.45)),
      ),
      child: GtinFieldSkeletonMask(
        show: showFieldSkeleton,
        child: content,
        skeletonBuilder: (c) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionLabel(
                GtinRegulatoryAuthorityExtensionUiConstants.sectionLabeling,
                padding: EdgeInsets.only(bottom: 12),
              ),
              GtinSkeletonOutlineField(color: c, height: 56),
            ],
          ),
        ),
      ),
    );
  }
}
