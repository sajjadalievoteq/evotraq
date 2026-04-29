import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/uae_regulatory/validators/uae_regulatory_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/section_label.dart';

class UaeLabelingSection extends StatelessWidget {
  const UaeLabelingSection({
    super.key,
    required this.isReadOnly,
    required this.showFieldSkeleton,
    required this.isUaeMarket,
    required this.regulatedProductNameController,
  });

  final bool isReadOnly;
  final bool showFieldSkeleton;
  final bool isUaeMarket;
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
            'UAE labeling',
            padding: EdgeInsets.only(bottom: 12),
          ),
          GtinValidatedField(
            controller: regulatedProductNameController,
            fieldName: 'regulatedProductName',
            label: 'Regulated Product Name (English) *',
            helperText:
                'Arabic name is mandatory for UAE labeling and should be captured in multilingual name records',
            maxLength: 200,
            inputFormatters: [LengthLimitingTextInputFormatter(200)],
            readOnly: isReadOnly,
            validator: (v) => UaeRegulatoryValidators.validateUaeEnglishRegulatedName(
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
                'UAE labeling',
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
