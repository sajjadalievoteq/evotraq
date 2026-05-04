import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_extension_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

class RegulatoryAuthorityDistributionSection extends StatelessWidget {
  const RegulatoryAuthorityDistributionSection({
    super.key,
    required this.showFieldSkeleton,
    required this.isRegulatoryAuthorityMarket,
    required this.isImportedProduct,
  });

  final bool showFieldSkeleton;
  final bool isRegulatoryAuthorityMarket;
  final bool isImportedProduct;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel(
            GtinRegulatoryAuthorityExtensionUiConstants.sectionDistribution,
            padding: EdgeInsets.only(bottom: 12),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
                GtinRegulatoryAuthorityExtensionUiConstants.checkboxRegulatoryAuthorityMarket),
            value: isRegulatoryAuthorityMarket,
            onChanged: null,
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(GtinRegulatoryAuthorityExtensionUiConstants.checkboxImportedProduct),
            subtitle: const Text(
              GtinRegulatoryAuthorityExtensionUiConstants.subtitleImportedProduct,
            ),
            value: isRegulatoryAuthorityMarket && isImportedProduct,
            onChanged: null,
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
                GtinRegulatoryAuthorityExtensionUiConstants.sectionDistribution,
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
