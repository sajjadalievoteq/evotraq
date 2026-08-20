import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_master_list_skeleton_row.dart';

class SubscriptionMasterListSkeleton extends StatelessWidget {
  const SubscriptionMasterListSkeleton({super.key,
    required this.rowCount,
    required this.shrinkWrap,
  });

  final int rowCount;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    if (shrinkWrap) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(
          rowCount,
          (index) => Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : TraqSpacing.sm),
            child: SubscriptionMasterListSkeletonRow(index: index),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: rowCount,
      separatorBuilder: (_, __) => const SizedBox(height: TraqSpacing.sm),
      itemBuilder: (_, index) =>
          SubscriptionMasterListSkeletonRow(index: index),
    );
  }
}
