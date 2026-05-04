import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_extension_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/regulatory_authority/validators/regulatory_authority_validators.dart';

class RegulatoryAuthorityIdentifiersSection extends StatelessWidget {
  const RegulatoryAuthorityIdentifiersSection({
    super.key,
    required this.isReadOnly,
    required this.showFieldSkeleton,
    required this.isRegulatoryAuthorityMarket,
    required this.localDrugCodeController,
    required this.marketingAuthorizationNumberController,
  });

  final bool isReadOnly;
  final bool showFieldSkeleton;
  final bool isRegulatoryAuthorityMarket;
  final TextEditingController localDrugCodeController;
  final TextEditingController marketingAuthorizationNumberController;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(
            GtinRegulatoryAuthorityExtensionUiConstants.sectionIdentifiers,
            padding: EdgeInsets.only(bottom: 12),
          ),
          GtinValidatedField(
            controller: localDrugCodeController,
            fieldName: 'localDrugCodeUaeGcc',
            label: GtinRegulatoryAuthorityExtensionUiConstants.labelLocalDrugCode,
            helperText: GtinRegulatoryAuthorityExtensionUiConstants.helperLocalDrugCode,
            maxLength: 50,
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            readOnly: isReadOnly,
            validator: (v) =>
                RegulatoryAuthorityValidators.validateLocalDrugCodeForRegulatoryAuthority(
              v,
              isRegulatoryAuthorityMarket: isRegulatoryAuthorityMarket,
            ),
          ),
          const SizedBox(height: 8),
          GtinValidatedField(
            controller: marketingAuthorizationNumberController,
            fieldName: 'marketingAuthorizationNumber',
            label: GtinRegulatoryAuthorityExtensionUiConstants.labelMarketingAuthorizationNumber,
            helperText: GtinRegulatoryAuthorityExtensionUiConstants.helperMarketingAuthorizationNumber,
            maxLength: 50,
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            readOnly: isReadOnly,
            validator: (v) => RegulatoryAuthorityValidators
                .validateMarketingAuthorizationForRegulatoryAuthority(
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
                GtinRegulatoryAuthorityExtensionUiConstants.sectionIdentifiers,
                padding: EdgeInsets.only(bottom: 12),
              ),
              GtinSkeletonOutlineField(color: c, height: 56),
              const SizedBox(height: 8),
              GtinSkeletonOutlineField(color: c, height: 56),
            ],
          ),
        ),
      ),
    );
  }
}
