import 'package:flutter/material.dart';
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
      return const _RecentParentsLoading();
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

class _RecentParentsLoading extends StatelessWidget {
  const _RecentParentsLoading();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.padding.left,
              16,
              context.padding.left,
              0,
            ),
            child: const AppSkeletonBox(height: 20, width: 160, radius: 6),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                context.padding.left,
                16,
                context.padding.left,
                0,
              ),
              itemCount: 6,
              itemBuilder: (_, __) => const Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppSkeletonBox(width: 56, height: 24, radius: 12),
                          Spacer(),
                          AppSkeletonBox(width: 56, height: 14, radius: 6),
                        ],
                      ),
                      SizedBox(height: 12),
                      AppSkeletonBox(width: double.infinity, height: 20, radius: 6),
                      SizedBox(height: 8),
                      AppSkeletonBox(width: 140, height: 14, radius: 6),
                      SizedBox(height: 4),
                      AppSkeletonBox(width: 120, height: 14, radius: 6),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
