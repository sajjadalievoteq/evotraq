import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/automation_center/screens/automation_center/utils/automation_center_sections.dart';

class SubscriptionNotFound extends StatelessWidget {
  const SubscriptionNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TraqIcon(
            AppAssets.iconAlert,
            size: 64,
            color: context.colors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'Subscription Not Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: context.colors.textMuted,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'The requested subscription could not be found or may have been deleted.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.colors.textMuted,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                context.go(AutomationCenterSections.alertSubscriptionsLocation),
            child: const Text('Back to Subscriptions'),
          ),
        ],
      ),
    );
  }
}
