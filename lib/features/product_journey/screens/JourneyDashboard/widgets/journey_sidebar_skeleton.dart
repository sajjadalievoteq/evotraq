import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';




class JourneySidebarSkeleton extends StatelessWidget {
  const JourneySidebarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(context.padding.top,context.padding.top-20,context.padding.top, 0),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            _Section(
              child: _KpiGridSkeleton(),
            ),
            const SizedBox(height: TraqSpacing.lg),

            
            _Section(
              child: _ProductSummarySkeleton(),
            ),
            const SizedBox(height: TraqSpacing.lg),

            
            _Section(
              child: _IconRowCardSkeleton(rowCount: 4),
            ),
            const SizedBox(height: TraqSpacing.lg),

            
            _Section(
              child: _IconRowCardSkeleton(rowCount: 3),
            ),
            const SizedBox(height: TraqSpacing.lg),

            const SizedBox(height: TraqSpacing.xl),
          ],
        ),
      ),
    );
  }
}






class _Box extends StatelessWidget {
  const _Box({
    this.width = double.infinity,
    this.height = 14.0,
    this.radius = 6.0,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonBox(width: width, height: height, radius: radius);
  }
}



class _Section extends StatelessWidget {
  const _Section({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        
        const _Box(width: 88, height: 10),
        const SizedBox(height: TraqSpacing.sm),
        child,
      ],
    );
  }
}






class _KpiGridSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: TraqSpacing.sm,
      crossAxisSpacing: TraqSpacing.sm,
      childAspectRatio: 1.55,
      children: List.generate(4, (_) => const _KpiTileSkeleton()),
    );
  }
}

class _KpiTileSkeleton extends StatelessWidget {
  const _KpiTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TraqSpacing.md,
          vertical: TraqSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            
            const _Box(width: 16, height: 16, radius: 4),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                _Box(width: 48, height: 18),
                SizedBox(height: 4),
                _Box(width: 72, height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



class _ProductSummarySkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(TraqSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Row(
              children: const [
                _Box(width: 18, height: 18, radius: 4),
                SizedBox(width: TraqSpacing.sm),
                Expanded(child: _Box(height: 14)),
                SizedBox(width: TraqSpacing.sm),
                _Box(width: 44, height: 20, radius: 10),
              ],
            ),
            const SizedBox(height: TraqSpacing.md),
            
            const _Box(width: 56, height: 10),
            const SizedBox(height: 4),
            const _Box(height: 12),
            const Divider(height: TraqSpacing.xl),
            
            ..._labelValueRows(count: 4),
          ],
        ),
      ),
    );
  }
}



class _IconRowCardSkeleton extends StatelessWidget {
  const _IconRowCardSkeleton({required this.rowCount});

  final int rowCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(TraqSpacing.lg),
        child: Column(
          children: List.generate(rowCount, (i) => _IconRow(last: i == rowCount - 1)),
        ),
      ),
    );
  }
}

class _IconRow extends StatelessWidget {
  const _IconRow({required this.last});

  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : TraqSpacing.md),
      child: Row(
        children: const [
          _Box(width: 16, height: 16, radius: 4),
          SizedBox(width: TraqSpacing.sm),
          _Box(width: 80, height: 10),
          SizedBox(width: TraqSpacing.sm),
          Expanded(child: _Box(height: 12)),
        ],
      ),
    );
  }
}

List<Widget> _labelValueRows({required int count}) {
  return List.generate(count, (i) {
    final last = i == count - 1;
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : TraqSpacing.sm),
      child: Row(
        children: const [
          _Box(width: 108, height: 10),
          SizedBox(width: TraqSpacing.sm),
          Expanded(child: _Box(height: 10)),
        ],
      ),
    );
  });
}
