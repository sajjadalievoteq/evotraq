import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/home/utils/home_strings.dart';

class LiveUpdatesIndicator extends StatelessWidget {
  const LiveUpdatesIndicator({
    super.key,
    required this.isLive,
    required this.servicesVersion,
  });
  final bool isLive;
  final String? servicesVersion;

  @override
  Widget build(BuildContext context) {
    final statusColor = isLive
        ? context.colors.success
        : context.colors.textMuted;
    return Semantics(
      container: true,
      liveRegion: true,
      label: isLive
          ? HomeStrings.liveDashboardUpdatesSemantics
          : HomeStrings.dashboardUpdatesNotLiveSemantics,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                boxShadow: isLive
                    ? [
                        BoxShadow(
                          color: statusColor.withOpacity(0.32),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 14,
              color: statusColor.withOpacity(0.30),
            ),
            const SizedBox(width: 8),
            Text(
              isLive
                  ? HomeStrings.liveDashboardUpdates
                  : HomeStrings.dashboardUpdatesNotLive,
              style: context.text.body.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (servicesVersion != null) ...[
              const SizedBox(width: 8),
              Text(
                servicesVersion!,
                style: context.text.bodySm.copyWith(
                  color: context.colors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
