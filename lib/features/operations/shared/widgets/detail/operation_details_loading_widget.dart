import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_details_skeleton_box.dart';

class OperationDetailsLoadingWidget extends StatelessWidget {
  const OperationDetailsLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          context.padding.top,
          context.padding.top,
          context.padding.top,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OperationDetailsSkeletonBox(height: 180),
            const SizedBox(height: 8),
            OperationDetailsSkeletonBox(height: 120),
            const SizedBox(height: 8),
            OperationDetailsSkeletonBox(height: 160),
            const SizedBox(height: 8),
            OperationDetailsSkeletonBox(height: 100),
            const SizedBox(height: 8),
            OperationDetailsSkeletonBox(height: 100),
            const SizedBox(height: 8),
            OperationDetailsSkeletonBox(height: 100),
            const SizedBox(height: 8),
            OperationDetailsSkeletonBox(height: 100),
          ],
        ),
      ),
    );
  }
}
