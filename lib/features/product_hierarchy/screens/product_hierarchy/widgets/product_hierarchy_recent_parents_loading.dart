import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';

class ProductHierarchyRecentParentsLoading extends StatelessWidget {
  const ProductHierarchyRecentParentsLoading();

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
                      AppSkeletonBox(
                        width: double.infinity,
                        height: 20,
                        radius: 6,
                      ),
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
