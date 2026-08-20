import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/skeleton_box.dart';

class AggregationDetailSkeletonGroupCard extends StatelessWidget {
  const AggregationDetailSkeletonGroupCard({super.key,
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
                  child: SkeletonBox(base, width: 80, height: 13),
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
