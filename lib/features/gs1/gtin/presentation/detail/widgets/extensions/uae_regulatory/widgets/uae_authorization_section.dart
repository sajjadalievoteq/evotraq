import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/uae_regulatory/validators/uae_regulatory_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

class UaeAuthorizationSection extends StatelessWidget {
  const UaeAuthorizationSection({
    super.key,
    required this.isReadOnly,
    required this.showFieldSkeleton,
    required this.isUaeMarket,
    required this.isImportedProduct,
    required this.licensedAgentGlnsController,
  });

  final bool isReadOnly;
  final bool showFieldSkeleton;
  final bool isUaeMarket;
  final bool isImportedProduct;
  final TextEditingController licensedAgentGlnsController;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(
            'UAE authorization',
            padding: EdgeInsets.only(bottom: 12),
          ),
          GtinValidatedField(
            controller: licensedAgentGlnsController,
            fieldName: 'licensedAgentGlns',
            label: 'Licensed Agent GLNs',
            helperText: 'Required for imported UAE products; comma/semicolon/newline separated',
            maxLines: 3,
            maxLength: 500,
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
            readOnly: isReadOnly,
            validator: (v) => UaeRegulatoryValidators.validateUaeLicensedAgent(
              v,
              isUaeMarket: isUaeMarket,
              isImportedProduct: isImportedProduct,
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
                'UAE authorization',
                padding: EdgeInsets.only(bottom: 12),
              ),
              GtinSkeletonOutlineField(color: c, height: 72),
            ],
          ),
        ),
      ),
    );
  }
}
