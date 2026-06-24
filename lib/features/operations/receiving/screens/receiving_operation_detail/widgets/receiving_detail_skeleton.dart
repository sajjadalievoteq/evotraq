import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';

/// Shimmer skeleton placeholder for Receiving operation detail.
class ReceivingDetailSkeleton extends StatelessWidget {
  const ReceivingDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: context.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SkeletonBox(height: 180),
            const SizedBox(height: 8),
            _SkeletonBox(height: 120),
            const SizedBox(height: 8),
            _SkeletonBox(height: 160),
            const SizedBox(height: 8),
            _SkeletonBox(height: 100),
            const SizedBox(height: 8),
            _SkeletonBox(height: 100),
            const SizedBox(height: 8),
            _SkeletonBox(height: 100),
            const SizedBox(height: 8),
            _SkeletonBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppShimmer.defaultBaseColor(context),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
