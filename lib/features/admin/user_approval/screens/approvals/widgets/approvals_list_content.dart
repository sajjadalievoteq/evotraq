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
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
          textAlign: TextAlign.center,
        ),
      );
    }



    return ListView.separated(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      itemCount: approvals.length,
      separatorBuilder: (_, __) => SizedBox(height: 20),
      itemBuilder: (context, index) {
        final approval = approvals[index];
        return Padding(
          padding:  EdgeInsets.only(top:index==0?20:0, bottom: index==approvals.length-1?context.gutter:0),
          child: UserApprovalCard(
            user: approval,
            onApprove: onApprove,
            onReject: onReject,
            variant: UserApprovalCardVariant.list,
          ),
        );
      },
    );
  }
}
