import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/core/widgets/custom_outlined_button_widget.dart';
import 'package:traqtrace_app/data/models/user_management/user_management_models.dart';
import 'package:traqtrace_app/features/admin/user_approval/utils/user_approval_constants.dart';

class UserApprovalCardActionsCompact extends StatelessWidget {
  const UserApprovalCardActionsCompact({
    super.key,
    required this.user,
    required this.onApprove,
    required this.onReject,
  });

  final UserResponse user;
  final ValueChanged<UserResponse> onApprove;
  final ValueChanged<UserResponse> onReject;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: Constants.spacing,
      children: [
        SizedBox(
          width: double.infinity,
          child: CustomOutlinedButtonWidget(
            title: UserApprovalConstants.rejectLabel,
            onTap: () => onReject(user),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: CustomButtonWidget(
            onTap: () => onApprove(user),
            title: UserApprovalConstants.approveLabel,
            iconWidget: SvgPicture.asset(
              AppAssets.iconCheck,
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            backgroundColor: context.colors.success,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
