import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class DeliveryTestFeedback extends StatelessWidget {
  const DeliveryTestFeedback({
    super.key,
    required this.testing,
    required this.success,
    required this.message,
  });
  final bool testing;
  final bool? success;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final color = testing
        ? context.colors.secondary
        : success == true
        ? AppColorMapper.successColor(context)
        : AppColorMapper.errorColor(context);
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(TraqSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.35)),
          borderRadius: TraqRadius.card,
        ),
        child: Row(
          children: [
            if (testing)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            else
              TraqIcon(
                success == true
                    ? AppAssets.iconCheckCircle
                    : AppAssets.iconXCircle,
                color: color,
              ),
            const SizedBox(width: TraqSpacing.sm),
            Expanded(
              child: Text(
                testing ? 'Testing delivery connection…' : message ?? '',
                style: context.text.bodySm.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
