import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_skeleton_box.dart';

class JourneySidebarSkeletonSection extends StatelessWidget {
  const JourneySidebarSkeletonSection({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSkeletonBox(width: 88, height: 10),
        const SizedBox(height: TraqSpacing.sm),
        child,
      ],
    );
  }
}
