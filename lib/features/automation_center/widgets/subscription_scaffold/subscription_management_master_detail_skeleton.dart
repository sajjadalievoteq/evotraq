import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_detail_pane_skeleton.dart';
import 'package:traqtrace_app/features/automation_center/widgets/subscription_scaffold/subscription_master_list_skeleton.dart';

class SubscriptionManagementMasterDetailSkeleton extends StatelessWidget {
  const SubscriptionManagementMasterDetailSkeleton({super.key, required this.shrinkWrap});

  /// Matches [SubscriptionManagementBody.shrinkWrap]: intrinsic size when
  /// nested in a [ListView] (unbounded height). Flex children are only used
  /// when the parent provides a bounded height.
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 900 || context.isMobile;
        if (stacked) {
          return Column(
            mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 220,
                child: SubscriptionMasterListSkeleton(
                  rowCount: 3,
                  shrinkWrap: shrinkWrap,
                ),
              ),
              const SizedBox(height: TraqSpacing.md),
              if (shrinkWrap)
                const SubscriptionDetailPaneSkeleton()
              else
                const Expanded(child: SubscriptionDetailPaneSkeleton()),
            ],
          );
        }

        // IntrinsicHeight lets the Row stretch in unbounded parents (workbench
        // ListView) the same way SubscriptionManagementBody does.
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: constraints.maxWidth * 0.34,
                child: SubscriptionMasterListSkeleton(
                  rowCount: 5,
                  shrinkWrap: shrinkWrap,
                ),
              ),
              const SizedBox(width: TraqSpacing.md),
              const Expanded(child: SubscriptionDetailPaneSkeleton()),
            ],
          ),
        );
      },
    );
  }
}
