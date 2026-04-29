import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/section_label.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/uae_regulatory/validators/uae_regulatory_validators.dart';

class UaeRegulatoryIdentifiersSection extends StatelessWidget {
  const UaeRegulatoryIdentifiersSection({
    super.key,
    required this.isReadOnly,
    required this.showFieldSkeleton,
    required this.isUaeMarket,
    required this.localDrugCodeController,
    required this.marketingAuthorizationNumberController,
  });

  final bool isReadOnly;
  final bool showFieldSkeleton;
  final bool isUaeMarket;
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
            'UAE regulatory identifiers',
            padding: EdgeInsets.only(bottom: 12),
          ),
          GtinValidatedField(
            controller: localDrugCodeController,
            fieldName: 'localDrugCodeUaeGcc',
            label: 'UAE Local Drug Code (MoHAP) *',
            helperText: 'Required for UAE market; configurable MoHAP format',
            maxLength: 50,
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            readOnly: isReadOnly,
            validator: (v) => UaeRegulatoryValidators.validateUaeLocalDrugCode(
              v,
              isUaeMarket: isUaeMarket,
            ),
          ),
          const SizedBox(height: 8),
          GtinValidatedField(
            controller: marketingAuthorizationNumberController,
            fieldName: 'marketingAuthorizationNumber',
            label: 'UAE Marketing Authorization Number *',
            helperText: 'Example format: MOHAP-12345-2026 (configurable)',
            maxLength: 50,
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            readOnly: isReadOnly,
            validator: (v) => UaeRegulatoryValidators.validateUaeMarketingAuthorization(
              v,
              isUaeMarket: isUaeMarket,
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
                'UAE regulatory identifiers',
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
