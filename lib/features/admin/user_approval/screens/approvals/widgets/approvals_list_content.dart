import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import 'package:traqtrace_app/features/admin/user_approval/screens/approvals/widgets/user_approval_card.dart';
import 'package:traqtrace_app/features/admin/user_approval/utils/user_approval_constants.dart';

class ApprovalsListContent extends StatelessWidget {
  const ApprovalsListContent({
    super.key,
    required this.approvals,
    required this.onApprove,
    required this.onReject,
  });

  final List<UserResponse> approvals;
  final ValueChanged<UserResponse> onApprove;
  final ValueChanged<UserResponse> onReject;

  @override
  Widget build(BuildContext context) {
    if (approvals.isEmpty) {
      return Center(
        child: Text(
          UserApprovalConstants.noPendingApprovals,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Colors.grey[700]),
          textAlign: TextAlign.center,
        ),
      );
    }

    final g = context.gutter;

    return ListView.separated(
      padding: EdgeInsets.all(g),
      physics: const ClampingScrollPhysics(),
      itemCount: approvals.length,
      separatorBuilder: (_, __) => SizedBox(height: g),
      itemBuilder: (context, index) {
        final approval = approvals[index];
        return UserApprovalCard(
          user: approval,
          onApprove: onApprove,
          onReject: onReject,
          variant: UserApprovalCardVariant.list,
        );
      },
    );
  }
}
