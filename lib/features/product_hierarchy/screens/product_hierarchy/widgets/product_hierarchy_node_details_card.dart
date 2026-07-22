import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/hierarchy/hierarchy_node.dart';
import 'package:traqtrace_app/data/models/product_journey/product_info.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_sidebar_chrome.dart';
import 'package:traqtrace_app/features/product_hierarchy/utils/product_hierarchy_display_utils.dart';


class ProductHierarchyNodeDetailsCard extends StatelessWidget {
  const ProductHierarchyNodeDetailsCard({
    super.key,
    required this.node,
    required this.journey,
    required this.info,
  });

  final HierarchyNode node;
  final ProductJourney journey;
  final ProductInfo? info;

  @override
  Widget build(BuildContext context) {
    final commission = info?.manufacturingDate;
    final commissionLabel = commission != null
        ? DateFormat('MMM dd, yyyy').format(commission.toLocal())
        : null;

    final identifierValue = ProductHierarchyDisplayUtils.shortIdentifier(
      node: node,
      info: info,
      journeyIdentifier: journey.identifier,
    );

    final rows = <Widget>[
      ProductHierarchyDetailRow(label: 'Identifier Type', value: node.type),
      ProductHierarchyDetailRow(
        label: node.isSscc ? 'SSCC' : 'SGTIN',
        value: node.isSscc
            ? (info?.sscc ?? node.sscc ?? identifierValue)
            : identifierValue,
      ),
      ProductHierarchyDetailRow(label: 'Identifier', value: journey.identifier),
      ProductHierarchyDetailRow(
        label: 'Packaging Level',
        value: ProductHierarchyDisplayUtils.packagingLevelLabel(
          node: node,
          info: info,
        ),
      ),
      ProductHierarchyDetailRow(label: 'Packaging Type', value: info?.packagingType),
      ProductHierarchyDetailRow(
        label: 'Aggregation Status',
        value: info?.status ?? node.status,
      ),
      ProductHierarchyDetailRow(
        label: 'Current State',
        value: journey.currentDisposition ?? node.disposition,
      ),
      ProductHierarchyDetailRow(
        label: 'Current Owner',
        value: info?.manufacturer ?? info?.mahName,
      ),
      ProductHierarchyDetailRow(
        label: 'Current Location',
        value: info?.currentLocationName ?? journey.currentLocation,
      ),
      ProductHierarchyDetailRow(label: 'Commission Date', value: commissionLabel),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProductHierarchySectionLabel('Node Details'),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(TraqSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rows,
            ),
          ),
        ),
      ],
    );
  }
}
