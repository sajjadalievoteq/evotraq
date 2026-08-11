import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';

class ProductHierarchyTreeIdleView extends StatelessWidget {
  const ProductHierarchyTreeIdleView({
    super.key,
    required this.hasRecentParents,
  });

  final bool hasRecentParents;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      iconAsset: NavIcons.aggregationHierarchy,
      title: hasRecentParents
          ? 'No SSCC or SGTIN has selected'
          : 'No hierarchy to display',
      subtitle: hasRecentParents
          ? 'Select an SSCC or SGTIN from the list to view its packaging tree.'
          : 'Search an SSCC or SGTIN to render its packaging tree.',
    );
  }
}
