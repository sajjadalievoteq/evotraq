import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

import '../../../../../../core/consts/app_consts.dart';
import '../../users/widgets/user_management_constants.dart';

class UserApprovalsLoadingView extends StatelessWidget {
  const UserApprovalsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;
    final g = context.gutter;

    return AppShimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _UserApprovalsHeaderSkeleton(baseColor: baseColor),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(g),
              physics: const ClampingScrollPhysics(),
              itemCount: 6,
              separatorBuilder: (_, __) => SizedBox(height: g),
              itemBuilder: (context, _) =>
                  _UserApprovalTileSkeleton(baseColor: baseColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header skeleton ────────────────────────────────────────────────────────

class _UserApprovalsHeaderSkeleton extends StatelessWidget {
  const _UserApprovalsHeaderSkeleton({required this.baseColor});

  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    final r = TraqRadius.md.x.toDouble();

    return Card(
      elevation: 1,
      child: Padding(
        padding: Constants.sectionPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _skeletonBox(baseColor, width: 250, height: 28, radius: r),
            const SizedBox(height: 10),
            _skeletonBox(baseColor, width: 420, height: 16, radius: r),
            const SizedBox(height: 8),
            _skeletonBox(baseColor, width: 340, height: 16, radius: r),
            const SizedBox(height: Constants.spacing),
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 600;
                final search = _skeletonBox(
                  baseColor,
                  width: double.infinity,
                  height: 50,
                  radius: r,
                );
                final refresh = _skeletonBox(
                  baseColor,
                  width: 50,
                  height: 50,
                  radius: r,
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      search,
                      const SizedBox(height: Constants.spacing),
                      Align(alignment: Alignment.centerRight, child: refresh),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: search),
                    const SizedBox(width: Constants.spacing),
                    refresh,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── List tile skeleton — mirrors list variant card layout ──────────────────

class _UserApprovalTileSkeleton extends StatelessWidget {
  const _UserApprovalTileSkeleton({required this.baseColor});

  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    final r = TraqRadius.md.x.toDouble();
    final btnRadius = TraqRadius.md.x.toDouble();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;

            // User info block
            final info = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full name
                _skeletonBox(baseColor, width: 160, height: 18, radius: r),
                const SizedBox(height: 6),
                // Username line
                _skeletonBox(baseColor, width: 120, height: 14, radius: r),
                const SizedBox(height: 4),
                // Email line
                _skeletonBox(baseColor, width: double.infinity, height: 14, radius: r),
              ],
            );

            // Approve / Reject buttons
            final buttons = Column(
              children: [
                _skeletonBox(baseColor, width: double.infinity, height: 40, radius: btnRadius),
                const SizedBox(height: Constants.spacing),
                _skeletonBox(baseColor, width: double.infinity, height: 40, radius: btnRadius),
              ],
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _skeletonBox(baseColor, width: 40, height: 40, radius: 999),
                    const SizedBox(width: 16),
                    Expanded(child: info),
                  ],
                ),
                const SizedBox(height: 16),
                // Registration date line
                _skeletonBox(baseColor, width: 180, height: 13, radius: r),
                const SizedBox(height: 16),
                if (compact)
                  buttons
                else
                  Row(
                    children: [
                      Expanded(
                        child: _skeletonBox(
                          baseColor,
                          width: double.infinity,
                          height: 40,
                          radius: btnRadius,
                        ),
                      ),
                      const SizedBox(width: Constants.spacing),
                      Expanded(
                        child: _skeletonBox(
                          baseColor,
                          width: double.infinity,
                          height: 40,
                          radius: btnRadius,
                        ),
                      ),
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

// ── Shared helper ──────────────────────────────────────────────────────────

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
