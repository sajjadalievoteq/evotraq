import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';

class TatmeenStatusBreakdownSkeletonLegend extends StatelessWidget {
  const TatmeenStatusBreakdownSkeletonLegend({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
          child: Row(
            children: [
              AppSkeletonBox(width: 10, height: 10, radius: 5, color: color),
              const SizedBox(width: TraqSpacing.xs),
              Expanded(
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.55,
                  child: AppSkeletonBox(height: 12, color: color),
                ),
              ),
              AppSkeletonBox(width: 40, height: 12, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
