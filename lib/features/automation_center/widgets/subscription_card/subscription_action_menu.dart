import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/automation_center/notification_subscription.dart';

class SubscriptionActionMenu extends StatelessWidget {
  const SubscriptionActionMenu({
    super.key,
    required this.subscription,
    required this.onEdit,
    required this.onPause,
    required this.onResume,
    required this.onDelete,
  });

  final NotificationSubscription subscription;
  final VoidCallback onEdit;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Subscription actions',
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
            break;
          case 'pause':
            onPause();
            break;
          case 'resume':
            onResume();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              TraqIcon(AppAssets.iconEdit),
              SizedBox(width: TraqSpacing.sm),
              Text('Edit'),
            ],
          ),
        ),
        if (subscription.status.toLowerCase() == 'active')
          const PopupMenuItem(
            value: 'pause',
            child: Row(
              children: [
                TraqIcon(AppAssets.iconMinus),
                SizedBox(width: TraqSpacing.sm),
                Text('Pause'),
              ],
            ),
          ),
        if (subscription.status.toLowerCase() == 'paused')
          const PopupMenuItem(
            value: 'resume',
            child: Row(
              children: [
                TraqIcon(AppAssets.iconArrowR),
                SizedBox(width: TraqSpacing.sm),
                Text('Resume'),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              TraqIcon(
                AppAssets.iconTrash,
                color: AppColorMapper.errorColor(context),
              ),
              const SizedBox(width: TraqSpacing.sm),
              Text(
                'Delete',
                style: TextStyle(color: AppColorMapper.errorColor(context)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
