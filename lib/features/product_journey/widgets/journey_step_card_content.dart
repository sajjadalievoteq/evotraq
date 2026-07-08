import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/cbv_display_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_formatters.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_step_style.dart';
import 'package:traqtrace_app/features/product_journey/widgets/journey_step_card_badge.dart';

class JourneyStepCardContent extends StatelessWidget {
  const JourneyStepCardContent({
    super.key,
    required this.step,
    required this.color,
    required this.isSelected,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final JourneyStep step;
  final Color color;
  final bool isSelected;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textColor = isSelected ? Colors.white : c.textPrimary;
    final mutedColor = isSelected ? Colors.white70 : c.textMuted;
    final faintColor = isSelected ? Colors.white54 : c.textFaint;

    return Card(
      elevation: isSelected ? 6 : 1,
      color: isSelected ? color : c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : color.withValues(alpha: 0.30),
          width: isSelected ? 0 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white24
                          : color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white38
                            : color.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TraqIcon(
                          JourneyStepStyle.iconFor(step.businessStep),
                          size: 13,
                          color: isSelected ? Colors.white : color,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          JourneyStepStyle.titleFor(step.businessStep),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (isFirst)
                    JourneyStepCardBadge(
                      label: 'START',
                      color: const Color(0xFF7BD389),
                      onSelected: isSelected,
                    ),
                  if (isLast)
                    JourneyStepCardBadge(
                      label: 'LATEST',
                      color: const Color(0xFF6FB7DC),
                      onSelected: isSelected,
                    ),
                  const Spacer(),
                  Text(
                    JourneyFormatters.shortDate(step.eventTime),
                    style: TextStyle(fontSize: 11, color: mutedColor),
                  ),
                ],
              ),
              if (step.locationName != null || step.locationGLN != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    TraqIcon(AppAssets.iconGln, size: 13, color: mutedColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        step.locationName ?? step.locationGLN ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (step.disposition.isNotEmpty) ...[
                const SizedBox(height: 3),
                Row(
                  children: [
                    TraqIcon(
                      AppAssets.iconCheckCircle,
                      size: 12,
                      color: faintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      CbvDisplayUtils.displayDisposition(step.disposition),
                      style: TextStyle(fontSize: 11, color: faintColor),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
