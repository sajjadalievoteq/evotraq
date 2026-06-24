import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';

class CommissioningDetailSkeleton extends StatelessWidget {
  const CommissioningDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          context.padding.left,
          0,
          context.padding.left,
          context.padding.left,
        ),
        child: Column(
          children: [
            _SkelBox(height: 100),
            const SizedBox(height: 12),
            _SkelBox(height: 160),
            const SizedBox(height: 12),
            _SkelBox(height: 180),
            const SizedBox(height: 12),
            _SkelBox(height: 140),
            const SizedBox(height: 12),
            _SkelBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _SkelBox extends StatelessWidget {
  const _SkelBox({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppShimmer.defaultBaseColor(context),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
