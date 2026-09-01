import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/theme/traq_theme_widgets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class TatmeenStatCard extends StatelessWidget {
  const TatmeenStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.iconAsset,
    required this.color,
    required this.width,
    this.trend,
    this.onTap,
  });

  final String label;
  final String value;
  final String iconAsset;
  final Color color;
  final double width;
  final double? trend;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: TraqRadius.card,
        child: TraqCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TraqIcon(iconAsset, size: 18, color: color),
                  const SizedBox(width: TraqSpacing.xs),
                  Expanded(
                    child: Text(
                      label,
                      style: context.text.bodySm.copyWith(
                        color: context.colors.textMuted,
                      ),
                    ),
                  ),
                  if (onTap != null)
                    TraqIcon(
                      AppAssets.iconChevronR,
                      size: 14,
                      color: context.colors.textMuted,
                    ),
                ],
              ),
              const SizedBox(height: TraqSpacing.sm),
              Text(
                value,
                style: context.text.h2.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: TraqSpacing.xs),
              Visibility(
                visible: trend != null,
                maintainAnimation: true,
                maintainSize: true,
                maintainState: true,
                child: Text(
                  '${(trend ?? 0) >= 0 ? '↑' : '↓'} ${(trend ?? 0).abs().toStringAsFixed(1)}% vs last month',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySm.copyWith(
                    color: (trend ?? 0) >= 0
                        ? context.colors.success
                        : context.colors.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
