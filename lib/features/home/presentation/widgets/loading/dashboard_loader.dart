import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';

class DashboardLoader extends StatelessWidget {
  const DashboardLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: AppLayoutBuilder(
        builder: (context, layout) {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              ResponsiveUtils.gutter(context),
              ResponsiveUtils.gutter(context) * 0.5,
              ResponsiveUtils.gutter(context),
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _OperationsHeaderSkeleton(layout: layout),
                SizedBox(height: layout.isCompact ? 16 : 24),
                _StatusRailSkeleton(layout: layout),
                SizedBox(height: layout.isCompact ? 18 : 26),
                _KeyMetricsSectionSkeleton(layout: layout),
                SizedBox(height: layout.isCompact ? 20 : 28),
                _ThroughputAndEventsSkeleton(layout: layout),
                SizedBox(height: layout.isCompact ? 20 : 28),
                _QuickActionsAndComplianceSkeleton(layout: layout),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    this.width = double.infinity,
    this.height = 20,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _OperationsHeaderSkeleton extends StatelessWidget {
  const _OperationsHeaderSkeleton({required this.layout});
  final AppLayoutData layout;

  @override
  Widget build(BuildContext context) {
    if (layout.isTabletUp) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _SkeletonBox(width: 200, height: 32),
          const Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _SkeletonBox(width: 300, height: 40),
                SizedBox(width: 8),
                _SkeletonBox(width: 120, height: 40),
              ],
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SkeletonBox(width: 180, height: 28),
            _SkeletonBox(width: 100, height: 32),
          ],
        ),
        const SizedBox(height: 12),
        const _SkeletonBox(height: 44),
      ],
    );
  }
}

class _StatusRailSkeleton extends StatelessWidget {
  const _StatusRailSkeleton({required this.layout});
  final AppLayoutData layout;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.gutter(context),
          vertical: ResponsiveUtils.gutter(context) * 0.5,
        ),
        child: layout.isTabletUp
            ? const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonBox(width: 240, height: 24),
                        SizedBox(height: 8),
                        _SkeletonBox(width: 180, height: 16),
                      ],
                    ),
                  ),
                  _SkeletonBox(width: 60, height: 36),
                  SizedBox(width: 20),
                  _SkeletonBox(width: 100, height: 36),
                ],
              )
            : const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(width: 200, height: 24),
                  SizedBox(height: 8),
                  _SkeletonBox(width: 150, height: 16),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SkeletonBox(width: 60, height: 32),
                      _SkeletonBox(width: 100, height: 32),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _KeyMetricsSectionSkeleton extends StatelessWidget {
  const _KeyMetricsSectionSkeleton({required this.layout});
  final AppLayoutData layout;

  @override
  Widget build(BuildContext context) {
    const gap = 12.0;
    final minTileWidth = layout.isCompact ? 158.0 : 200.0;
    const maxCols = 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SkeletonBox(width: 140, height: 14),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final maxW = constraints.maxWidth;
            var cols = ((maxW + gap) / (minTileWidth + gap)).floor();
            if (cols < 1) cols = 1;
            if (cols > maxCols) cols = maxCols;
            final tileW = (maxW - gap * (cols - 1)) / cols;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: List.generate(
                9,
                (index) => SizedBox(
                  width: tileW,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _StatCardSkeleton(dense: layout.isCompact),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton({required this.dense});
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(dense ? 18 : 22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _SkeletonBox(
                        width: dense ? 18 : 24,
                        height: dense ? 18 : 24,
                        radius: 4,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SkeletonBox(height: dense ? 12 : 16),
                      ),
                    ],
                  ),
                  _SkeletonBox(width: dense ? 48 : 64, height: dense ? 24 : 36),
                ],
              ),
            ),
            SizedBox(width: dense ? 12 : 20),
            const Expanded(
              child: _SkeletonBox(height: double.infinity, radius: 4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThroughputAndEventsSkeleton extends StatelessWidget {
  const _ThroughputAndEventsSkeleton({required this.layout});
  final AppLayoutData layout;

  static double _pairSectionHeight(double maxWidth) {
    return (360 + maxWidth * 0.04).clamp(320.0, 460.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final h = _pairSectionHeight(c.maxWidth);
        if (layout.isTabletUp) {
          return SizedBox(
            height: h,
            child: Row(
              children: [
                Expanded(flex: 3, child: _ThroughputChartSkeleton()),
                SizedBox(width: layout.isCompact ? 12 : 20),
                Expanded(flex: 2, child: _EpcisEventStreamSkeleton()),
              ],
            ),
          );
        }
        return Column(
          children: [
            SizedBox(height: h, child: const _ThroughputChartSkeleton()),
            SizedBox(height: layout.isCompact ? 16 : 20),
            SizedBox(height: h, child: const _EpcisEventStreamSkeleton()),
          ],
        );
      },
    );
  }
}

class _ThroughputChartSkeleton extends StatelessWidget {
  const _ThroughputChartSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SkeletonBox(width: 180, height: 20),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  12,
                  (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: (index % 5 + 2) * 30.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EpcisEventStreamSkeleton extends StatelessWidget {
  const _EpcisEventStreamSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _SkeletonBox(width: 120, height: 20),
                Row(
                  children: [
                    const _SkeletonBox(width: 40, height: 16),
                    const SizedBox(width: 8),
                    const _SkeletonBox(width: 60, height: 20),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      const _SkeletonBox(width: 40, height: 40, radius: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SkeletonBox(width: 140, height: 16),
                            const SizedBox(height: 8),
                            const _SkeletonBox(width: 100, height: 12),
                          ],
                        ),
                      ),
                      const _SkeletonBox(width: 60, height: 14),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsAndComplianceSkeleton extends StatelessWidget {
  const _QuickActionsAndComplianceSkeleton({required this.layout});
  final AppLayoutData layout;

  @override
  Widget build(BuildContext context) {
    if (layout.isTabletUp) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(flex: 3, child: _QuickActionsSkeleton()),
          SizedBox(width: layout.isCompact ? 12 : 20),
          const Expanded(flex: 2, child: _ComplianceSkeleton()),
        ],
      );
    }
    return Column(
      children: [
        const _QuickActionsSkeleton(),
        SizedBox(height: layout.isCompact ? 16 : 20),
        const _ComplianceSkeleton(),
      ],
    );
  }
}

class _QuickActionsSkeleton extends StatelessWidget {
  const _QuickActionsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SkeletonBox(width: 150, height: 20),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = switch (constraints.maxWidth) {
              < 360 => 2,
              < 500 => 2,
              < 700 => 2,
              < 900 => 3,
              _ => 4,
            };
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 18 / 6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 8,
              itemBuilder: (context, index) => const Card(),
            );
          },
        ),
      ],
    );
  }
}

class _ComplianceSkeleton extends StatelessWidget {
  const _ComplianceSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SkeletonBox(width: 180, height: 20),
        SizedBox(height: 12),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _SkeletonBox(height: 24),
                SizedBox(height: 12),
                _SkeletonBox(height: 24),
                SizedBox(height: 12),
                _SkeletonBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
