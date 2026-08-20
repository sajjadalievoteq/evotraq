import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_pin_layout.dart';

class JourneyPinSkeleton extends StatelessWidget {
  const JourneyPinSkeleton({required this.isFirst, required this.isLast});

  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    const r = JourneyPinLayout.pinRadius;
    const pinH = r * 2 + r * 0.5;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppSkeletonBox(width: r * 2, height: pinH, radius: r),
        const SizedBox(height: 6),
        const AppSkeletonBox(width: 96, height: 22, radius: 11),
        const SizedBox(height: 4),
        const AppSkeletonBox(width: double.infinity, height: 52, radius: 8),
        if (isFirst || isLast) ...[
          const SizedBox(height: 3),
          AppSkeletonBox(width: isFirst ? 36 : 32, height: 14, radius: 7),
        ],
      ],
    );
  }
}
