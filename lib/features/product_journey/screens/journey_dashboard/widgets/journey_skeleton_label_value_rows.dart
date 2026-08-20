import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';

class JourneySkeletonLabelValueRows extends StatelessWidget {
  const JourneySkeletonLabelValueRows({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (index) => Padding(
          padding: EdgeInsets.only(
            bottom: index == count - 1 ? 0 : TraqSpacing.sm,
          ),
          child: const Row(
            children: [
              AppSkeletonBox(width: 108, height: 10),
              SizedBox(width: TraqSpacing.sm),
              Expanded(child: AppSkeletonBox(height: 10)),
            ],
          ),
        ),
      ),
    );
  }
}
