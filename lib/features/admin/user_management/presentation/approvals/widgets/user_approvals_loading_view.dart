import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../users/widgets/user_management_constants.dart';
import '../../users/widgets/user_management_section_width.dart';

class UserApprovalsLoadingView extends StatelessWidget {
  const UserApprovalsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UserManagementSectionWidth(
            child: _UserApprovalsHeaderSkeleton(baseColor: baseColor),
          ),
          const SizedBox(height: UserManagementConstants.spacing),
          Expanded(
            child: ListView.separated(
              itemCount: 5,
              padding: EdgeInsets.zero,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: UserManagementConstants.spacing),
              itemBuilder: (context, index) {
                return UserManagementSectionWidth(
                  child: _UserApprovalCardSkeleton(baseColor: baseColor),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserApprovalsHeaderSkeleton extends StatelessWidget {
  const _UserApprovalsHeaderSkeleton({required this.baseColor});

  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UserManagementConstants.cardRadius),
      ),
      child: Padding(
        padding: UserManagementConstants.sectionPadding,
        child: Wrap(
          spacing: UserManagementConstants.spacing,
          runSpacing: UserManagementConstants.spacing,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _skeletonBox(baseColor, width: 250, height: 28, radius: 8),
                  const SizedBox(height: 10),
                  _skeletonBox(
                    baseColor,
                    width: 420,
                    height: 16,
                    radius: 8,
                  ),
                  const SizedBox(height: 8),
                  _skeletonBox(
                    baseColor,
                    width: 340,
                    height: 16,
                    radius: 8,
                  ),
                ],
              ),
            ),
            _skeletonBox(baseColor, width: 120, height: 44),
          ],
        ),
      ),
    );
  }
}

class _UserApprovalCardSkeleton extends StatelessWidget {
  const _UserApprovalCardSkeleton({required this.baseColor});

  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;

            final header = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(baseColor, width: 40, height: 40, radius: 999),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _skeletonBox(baseColor, width: 180, height: 20, radius: 8),
                      const SizedBox(height: 8),
                      _skeletonBox(baseColor, width: 140, height: 16, radius: 8),
                      const SizedBox(height: 8),
                      _skeletonBox(baseColor, width: 220, height: 16, radius: 8),
                    ],
                  ),
                ),
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  const SizedBox(height: 16),
                  _skeletonBox(baseColor, width: 150, height: 14, radius: 8),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: UserManagementConstants.spacing,
                    runSpacing: UserManagementConstants.spacing,
                    children: [
                      _skeletonBox(baseColor, width: 160, height: 50),
                      _skeletonBox(baseColor, width: 160, height: 50),
                    ],
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header,
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _skeletonBox(
                        baseColor,
                        width: double.infinity,
                        height: 14,
                        radius: 8,
                      ),
                    ),
                    const SizedBox(width: UserManagementConstants.spacing),
                    _skeletonBox(baseColor, width: 150, height: 50),
                    const SizedBox(width: UserManagementConstants.spacing),
                    _skeletonBox(baseColor, width: 150, height: 50),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget _skeletonBox(
  Color color, {
  required double width,
  required double height,
  double radius = 12,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
