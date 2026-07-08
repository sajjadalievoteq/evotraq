import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';

class CbvVocabularySkeleton extends StatelessWidget {
  const CbvVocabularySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final base = AppShimmer.defaultBaseColor(context);
    final h = context.padding.left;

    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: context.padding.top),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SkeletonStatCards(base: base),
              const SizedBox(height: TraqSpacing.lg),

              _SkeletonBox(base: base, height: 44, radius: 8),
              const SizedBox(height: TraqSpacing.md),

              Row(
                children: [
                  _SkeletonBox(base: base, width: 80, height: 20, radius: 4),
                  const SizedBox(width: TraqSpacing.xl),
                  _SkeletonBox(base: base, width: 80, height: 20, radius: 4),
                  const SizedBox(width: TraqSpacing.xl),
                  _SkeletonBox(base: base, width: 100, height: 20, radius: 4),
                ],
              ),
              const Divider(height: TraqSpacing.xl),

              for (var i = 0; i < 10; i++) ...[
                _SkeletonPairingRow(base: base, chipCount: 2 + (i % 4)),
                const Divider(height: 1),
              ],

              const SizedBox(height: TraqSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonStatCards extends StatelessWidget {
  const _SkeletonStatCards({required this.base});
  final Color base;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 700;
      final cardWidth = isMobile
          ? constraints.maxWidth
          : (constraints.maxWidth - TraqSpacing.md) / 2;

      return Wrap(
        spacing: TraqSpacing.md,
        runSpacing: TraqSpacing.md,
        children: [
          SizedBox(width: cardWidth, child: _SkeletonStatCard(base: base)),
          SizedBox(width: cardWidth, child: _SkeletonStatCard(base: base)),
        ],
      );
    });
  }
}

class _SkeletonStatCard extends StatelessWidget {
  const _SkeletonStatCard({required this.base});
  final Color base;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(TraqSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _SkeletonBox(base: base, width: 20, height: 20, radius: 4),
              const SizedBox(width: TraqSpacing.sm),
              _SkeletonBox(base: base, width: 90, height: 14, radius: 4),
            ]),
            const SizedBox(height: TraqSpacing.md),
            Row(children: [
              Expanded(child: _SkeletonStatBlock(base: base)),
              Expanded(child: _SkeletonStatBlock(base: base)),
              Expanded(child: _SkeletonStatBlock(base: base)),
            ]),
          ],
        ),
      ),
    );
  }
}

class _SkeletonStatBlock extends StatelessWidget {
  const _SkeletonStatBlock({required this.base});
  final Color base;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SkeletonBox(base: base, width: 32, height: 22, radius: 4),
        const SizedBox(height: 4),
        _SkeletonBox(base: base, width: 48, height: 11, radius: 4),
      ],
    );
  }
}

class _SkeletonPairingRow extends StatelessWidget {
  const _SkeletonPairingRow({required this.base, required this.chipCount});
  final Color base;
  final int chipCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TraqSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(base: base, width: 130, height: 13, radius: 4),
                const SizedBox(height: 5),
                _SkeletonBox(base: base, width: 90, height: 10, radius: 3),
              ],
            ),
          ),
          const SizedBox(width: TraqSpacing.lg),
          Expanded(
            child: Wrap(
              spacing: TraqSpacing.sm,
              runSpacing: TraqSpacing.xs,
              children: [
                for (var i = 0; i < chipCount; i++)
                  _SkeletonBox(
                    base: base,
                    width: 72.0 + (i.isEven ? 16 : 0),
                    height: 26,
                    radius: 16,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.base,
    required this.height,
    this.width,
    this.radius = 6,
  });

  final Color base;
  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
