import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';

class JourneySkeletonIconRow extends StatelessWidget {
  const JourneySkeletonIconRow({required this.last, super.key});

  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : TraqSpacing.md),
      child: const Row(
        children: [
          AppSkeletonBox(width: 16, height: 16, radius: 4),
          SizedBox(width: TraqSpacing.sm),
          AppSkeletonBox(width: 80, height: 10),
          SizedBox(width: TraqSpacing.sm),
          Expanded(child: AppSkeletonBox(height: 12)),
        ],
      ),
    );
  }
}
