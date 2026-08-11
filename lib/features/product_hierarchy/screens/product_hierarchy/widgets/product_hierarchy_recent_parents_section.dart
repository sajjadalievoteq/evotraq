import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_recent_parents_loading.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/features/product_hierarchy/screens/product_hierarchy/widgets/product_hierarchy_recent_parent_card.dart';
import 'package:traqtrace_app/features/product_hierarchy/utils/product_hierarchy_identifier_utils.dart';

class ProductHierarchyRecentParentsSection extends StatelessWidget {
  const ProductHierarchyRecentParentsSection({
    super.key,
    required this.parents,
    required this.isLoading,
    required this.onTap,
  });

  final List<PackingResponse> parents;
  final bool isLoading;
  final ValueChanged<PackingResponse> onTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const ProductHierarchyRecentParentsLoading();
    }

    final actionable = parents
        .where((p) {
          final id = normalizeProductHierarchyInput(p.parentContainerId ?? '');
          return id.isNotEmpty;
        })
        .take(10)
        .toList(growable: false);

    if (actionable.isEmpty) {
      return AppEmptyState(
        iconAsset: NavIcons.sscc,
        title: 'No recent containers',
        subtitle: 'Pack items to see recent packed containers here.',
      );
    }

    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            context.padding.left,
            16,
            context.padding.left,
            0,
          ),
          child: Text(
            'Recent packed containers',
            style: context.text.body.copyWith(
              fontWeight: FontWeight.w700,
              color: c.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
              context.padding.left,
              16,
              context.padding.left,
              0,
            ),
            itemCount: actionable.length,
            itemBuilder: (context, index) {
              final op = actionable[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == actionable.length - 1
                      ? context.padding.left
                      : 0,
                ),
                child: ProductHierarchyRecentParentCard(
                  operation: op,
                  onTap: () => onTap(op),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
