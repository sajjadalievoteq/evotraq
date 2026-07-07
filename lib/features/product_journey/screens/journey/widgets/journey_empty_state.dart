import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class JourneyEmptyState extends StatelessWidget {
  const JourneyEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.colors;
    final muted = theme.colorScheme.onSurfaceVariant;

    return Center(
      child: Padding(
        padding: context.horizontalPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TraqIcon(
              AppAssets.iconGlobe,
              size: 64,
              color: muted.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Track Product Journey',
              style: theme.textTheme.bodyLarge?.copyWith(color: muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a serial number, SGTIN, or SSCC to view\nthe complete supply chain journey',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: muted.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _hintChip(c, 'Serial Number', AppAssets.iconQr),
                _hintChip(c, 'SGTIN URI', AppAssets.iconLink),
                _hintChip(c, 'SSCC', AppAssets.iconBox),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _hintChip(TraqColors c, String label, String iconAsset) {
    return Chip(
      avatar: TraqIcon(iconAsset, size: 18, color: c.textMuted),
      label: Text(label, style: TextStyle(color: c.textSecondary)),
      backgroundColor: c.surfaceMuted,
      side: BorderSide(color: c.border),
    );
  }
}
