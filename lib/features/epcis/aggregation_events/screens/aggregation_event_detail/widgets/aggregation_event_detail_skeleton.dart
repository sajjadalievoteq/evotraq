import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';

class AggregationEventDetailSkeleton extends StatelessWidget {
  const AggregationEventDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final base = AppShimmer.defaultBaseColor(context);
    final outline = Theme.of(context).colorScheme.outlineVariant.withValues(
          alpha: 0.45,
        );

    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.padding.top,
          context.padding.top,
          context.padding.top,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderBannerPlaceholder(),
            const SizedBox(height: 16),
            _SkeletonGroupCard(
              outlineColor: outline,
              base: base,
              child: (maxWidth) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldRow(base: base, maxWidth: maxWidth, withChip: true),
                  for (var i = 0; i < 5; i++)
                    _FieldRow(base: base, maxWidth: maxWidth),
                ],
              ),
            ),
            _SkeletonGroupCard(
              outlineColor: outline,
              base: base,
              child: (maxWidth) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonBox(
                          base: base,
                          width: maxWidth * 0.4,
                          height: 11,
                        ),
                        const SizedBox(height: 4),
                        _SkeletonBox(base: base, width: maxWidth, height: 13),
                      ],
                    ),
                  ),
                  _SkeletonBox(base: base, width: 50, height: 11),
                  const SizedBox(height: 6),
                  for (var i = 0; i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          _SkeletonBox(
                            base: base,
                            width: 6,
                            height: 6,
                            radius: 3,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _SkeletonBox(
                              base: base,
                              height: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            _SkeletonGroupCard(
              outlineColor: outline,
              base: base,
              child: (maxWidth) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldRow(base: base, maxWidth: maxWidth),
                  _FieldRow(base: base, maxWidth: maxWidth),
                ],
              ),
            ),
            _SkeletonGroupCard(
              outlineColor: outline,
              base: base,
              child: (maxWidth) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldRow(base: base, maxWidth: maxWidth),
                  _FieldRow(base: base, maxWidth: maxWidth),
                ],
              ),
            ),
            const SizedBox(height: Constants.spacing * 2),
          ],
        ),
      ),
    );
  }
}

class _HeaderBannerPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final bannerBase = Colors.white.withValues(alpha: 0.28);
    final bannerHighlight = Colors.white.withValues(alpha: 0.48);

    return Card(
      margin: EdgeInsets.zero,
      color: primary,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 120,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppShimmer(
            baseColor: bannerBase,
            highlightColor: bannerHighlight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    _SkeletonBox(
                      base: bannerBase,
                      width: w * 0.6,
                      height: 16,
                    ),
                    _SkeletonBox(
                      base: bannerBase,
                      width: w * 0.45,
                      height: 13,
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: _SkeletonBox(
                        base: bannerBase,
                        width: w * 0.3,
                        height: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonGroupCard extends StatelessWidget {
  const _SkeletonGroupCard({
    required this.outlineColor,
    required this.base,
    required this.child,
  });

  final Color outlineColor;
  final Color base;
  final Widget Function(double maxWidth) child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: BorderSide(color: outlineColor),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 12),
                  child: _SkeletonBox(base: base, width: 80, height: 13),
                ),
                child(constraints.maxWidth),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.base,
    required this.maxWidth,
    this.withChip = false,
  });

  final Color base;
  final double maxWidth;
  final bool withChip;

  @override
  Widget build(BuildContext context) {
    final field = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SkeletonBox(base: base, width: maxWidth * 0.4, height: 11),
        const SizedBox(height: 4),
        _SkeletonBox(base: base, width: maxWidth * 0.7, height: 14),
      ],
    );

    if (!withChip) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: field,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: field),
          const SizedBox(width: 12),
          _SkeletonBox(base: base, width: 60, height: 28, radius: 16),
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
