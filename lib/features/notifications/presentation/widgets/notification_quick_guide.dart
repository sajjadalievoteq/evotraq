import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';

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
                TraqIcon(AppAssets.iconLightbulb, color: AppColorMapper.warningColor(context)),
                const SizedBox(width: 8),
                Text(
                  'Quick Setup Guide',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColorMapper.warningColor(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildGuideStep(
              context,
              '1.',
              'Create Subscription',
              'Tap the + button to create your first notification subscription',
              AppAssets.iconAddCircle,
            ),
            _buildGuideStep(
              context,
              '2.',
              'Configure Webhook',
              'Set up your webhook URL where notifications will be sent',
              NavIcons.webhookConfiguration,
            ),
            _buildGuideStep(
              context,
              '3.',
              'Filter Events',
              'Use advanced options to filter specific event types, business steps, or dispositions',
              AppAssets.iconFilter,
            ),
            _buildGuideStep(
              context,
              '4.',
              'Test & Monitor',
              'Test your webhook and monitor delivery statistics',
              AppAssets.iconBarChart,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TraqIcon(AppAssets.iconInfo, size: 16, color: AppColorMapper.infoColor(context)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Click the help icon (?) in the create dialog for detailed guidance',
                    style: TextStyle(
                      fontSize: 12,
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

  Widget _buildGuideStep(
    BuildContext context,
    String number,
    String title,
    String description,
    String iconAsset,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColorMapper.infoSoft(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColorMapper.infoColor(context),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          TraqIcon(iconAsset, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
  