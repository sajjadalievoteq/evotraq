import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/loading/widgets/dashboard_skeleton_box.dart';

class DashboardQuickActionsSkeleton extends StatelessWidget {
  const DashboardQuickActionsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashboardSkeletonBox(width: 150, height: 20),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = switch (constraints.maxWidth) {
              < 360 => 2,
              < 500 => 2,
              < 700 => 2,
              < 900 => 3,
              _ => 4,
            };
            return SelectionContainer.disabled(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 18 / 6,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 8,
                itemBuilder: (context, index) => const Card(),
              ),
            );
          },
        ),
      ],
    );
  }
}
