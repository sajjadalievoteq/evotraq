import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/automation_center/widgets/notification_quick_guide.dart';

class NotificationListEmptyState extends StatelessWidget {
  const NotificationListEmptyState({
    super.key,
    required this.onCreate,
  });

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const NotificationQuickGuide(),
          const SizedBox(height: 24),
          TraqIcon(
            NavIcons.notifications,
            size: 64,
            color: context.colors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'No notification subscriptions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: context.colors.textMuted,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first subscription to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.colors.textMuted,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onCreate,
            icon: TraqIcon(AppAssets.iconPlus),
            label: const Text('Create Subscription'),
          ),
        ],
      ),
    );
  }
}
