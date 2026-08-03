import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/features/automation_center/widgets/notification_quick_guide/quick_guide_step.dart';

class NotificationQuickGuide extends StatelessWidget {
  const NotificationQuickGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(
                  AppAssets.iconLightbulb,
                  color: AppColorMapper.warningColor(context),
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Setup Guide',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColorMapper.warningColor(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            QuickGuideStep(
              number: '1.',
              title: 'Create Subscription',
              description:
                  'Tap the + button to create your first notification subscription',
              iconAsset: AppAssets.iconAddCircle,
            ),
            QuickGuideStep(
              number: '2.',
              title: 'Configure Webhook',
              description:
                  'Set up your webhook URL where notifications will be sent',
              iconAsset: NavIcons.webhookConfiguration,
            ),
            QuickGuideStep(
              number: '3.',
              title: 'Filter Events',
              description:
                  'Use advanced options to filter specific event types, business steps, or dispositions',
              iconAsset: AppAssets.iconFilter,
            ),
            QuickGuideStep(
              number: '4.',
              title: 'Test & Monitor',
              description:
                  'Test your webhook and monitor delivery statistics',
              iconAsset: AppAssets.iconBarChart,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TraqIcon(
                  AppAssets.iconInfo,
                  size: 16,
                  color: AppColorMapper.infoColor(context),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Click the help icon (?) in the create dialog for detailed guidance',
                    style: TextStyle(
                      color: AppColorMapper.infoColor(context),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
