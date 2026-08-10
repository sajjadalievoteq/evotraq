import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

/// Color emphasis for [SubscriptionDetailsStatTile].
enum SubscriptionStatTone { neutral, success, error, info }

/// Colored metric tile used in the subscription details page's delivery
/// statistics grid. Self-contained (doesn't depend on any shared card-list
/// stat widget) so it renders the same whether the details page is shown
/// full-page or embedded inside Subscription Management's inline panel.
class SubscriptionDetailsStatTile extends StatelessWidget {
  const SubscriptionDetailsStatTile({
    super.key,
    required this.label,
    required this.value,
    required this.iconAsset,
    this.tone = SubscriptionStatTone.neutral,
  });

  final String label;
  final String value;
  final String iconAsset;
  final SubscriptionStatTone tone;

  Color _toneColor(BuildContext context) {
    switch (tone) {
      case SubscriptionStatTone.success:
        return AppColorMapper.successColor(context);
      case SubscriptionStatTone.error:
        return AppColorMapper.errorColor(context);
      case SubscriptionStatTone.info:
        return AppColorMapper.infoColor(context);
      case SubscriptionStatTone.neutral:
        return context.colors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = _toneColor(context);
    return Container(
      padding: const EdgeInsets.all(TraqSpacing.md),
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: TraqRadius.card,
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              TraqIcon(iconAsset, size: 14, color: color),
              const SizedBox(width: TraqSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: context.text.cap,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: TraqSpacing.xs),
          Text(
            value,
            style: context.text.h2.copyWith(color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
