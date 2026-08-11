import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/product_journey/product_info.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDetails/widgets/journey_identifier_type_badge.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDetails/widgets/journey_product_detail_rows.dart';
import 'package:traqtrace_app/features/product_journey/screens/JourneyDetails/widgets/journey_product_epc_row.dart';

class JourneyProductSummarySection extends StatelessWidget {
  const JourneyProductSummarySection({super.key, required this.journey});

  final ProductJourney journey;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final info = journey.productInfo;
    final isSscc =
        info?.isSscc == true || journey.identifierType.toUpperCase() == 'SSCC';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(TraqSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(
                  isSscc ? NavIcons.sscc : NavIcons.packaging,
                  size: 18,
                  color: colors.primary,
                ),
                const SizedBox(width: TraqSpacing.sm),
                Expanded(
                  child: Text(
                    _productName(info),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                JourneyIdentifierTypeBadge(type: journey.identifierType),
              ],
            ),
            const SizedBox(height: TraqSpacing.md),
            JourneyProductEpcRow(epc: journey.identifier),
            const Divider(height: TraqSpacing.xl),
            JourneyProductDetailRows(
              info: info,
              journey: journey,
              isSscc: isSscc,
            ),
          ],
        ),
      ),
    );
  }

  String _productName(ProductInfo? info) {
    return info?.regulatedProductName ??
        info?.tradeItemDescription ??
        info?.description ??
        info?.functionalName ??
        journey.identifierType;
  }
}
