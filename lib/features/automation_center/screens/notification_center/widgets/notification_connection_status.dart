import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class NotificationConnectionStatus extends StatelessWidget {
  const NotificationConnectionStatus({
    super.key,
    required this.live,
  });

  final bool live;

  @override
  Widget build(BuildContext context) {
    final color = live
        ? AppColorMapper.successColor(context)
        : AppColorMapper.errorColor(context);
    return Semantics(
      label: live ? 'Live connection' : 'Offline',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TraqSpacing.sm,

        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color),
          borderRadius: const BorderRadius.all(TraqRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TraqIcon(
              live ? AppAssets.iconCheckCircle : AppAssets.iconCircle,
              size: 14,
              color: color,
            ),
            const SizedBox(width: TraqSpacing.xs),
            Text(
              live ? 'Live' : 'Offline',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                height: 1
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
