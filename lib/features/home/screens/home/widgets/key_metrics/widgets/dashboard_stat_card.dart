import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/home/screens/home/utils/dashboard_stat_card_sparkline_utils.dart';
import 'package:traqtrace_app/features/home/screens/home/widgets/key_metrics/widgets/dashboard_mini_line_sparkline.dart';

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.iconAsset,
    required this.color,
    this.width,
    this.onTap,
    this.valueTextColor,
    this.labelTextColor,
    this.sparkline,
    this.sparklineColor,
    this.dense = false,
  }) : assert(
          icon != null || iconAsset != null,
          'Provide icon or iconAsset',
        );

  final String title;
  final String value;
  final IconData? icon;
  final String? iconAsset;
  final Color color;
  final double? width;
  final VoidCallback? onTap;
  final Color? valueTextColor;
  final Color? labelTextColor;
  final List<double>? sparkline;
  final Color? sparklineColor;
  final bool dense;

  bool get _usesAsset => iconAsset != null;

  @override
  Widget build(BuildContext context) {
    final valueColor = valueTextColor ?? color;
    final captionColor = labelTextColor ?? context.colors.textMuted;
    final metric = DashboardStatCardSparklineUtils.parseMetricValue(value);
    final sparkHeights = metric == 0
        ? null
        : (sparkline ??
            (_usesAsset && metric != null
                ? DashboardStatCardSparklineUtils.sparklineFromMetric(metric)
                : null));
    final lineColor = sparklineColor ?? color;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : (width ?? 140);
        final h = constraints.maxHeight.isFinite ? constraints.maxHeight : null;

        return InkWell(
          onTap: onTap,
          child: Container(
            width: w,
            height: h,
            padding: EdgeInsets.all(dense ? 18 : 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 5,
                        children: [
                          if (iconAsset != null)
                            SvgPicture.asset(
                              iconAsset!,
                              width: dense ? 18 : 24,
                              height: dense ? 18 : 24,
                              colorFilter:
                                  ColorFilter.mode(color, BlendMode.srcIn),
                            )
                          else
                            Icon(icon!, color: color, size: dense ? 24 : 32),
                          Expanded(
                            child: Text(
                              title,
                              style: context.text.cap.copyWith(
                                fontSize: dense ? 10 : 20,
                                color: captionColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        value,
                        style: context.text.h2.copyWith(
                          fontWeight: FontWeight.bold,
                          color: valueColor,
                          fontSize: dense ? 20 : 44,
                          height: dense ? 1.1 : 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                if (sparkHeights != null) ...[
                  SizedBox(width: dense ? 12 : 20),
                  Expanded(
                    child: DashboardMiniLineSparkline(
                      heights: sparkHeights,
                      lineColor: lineColor,
                      minTrackHeight: dense ? 18 : 32,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
