import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class TatmeenMasterItem extends StatelessWidget {
  const TatmeenMasterItem({
    super.key,
    required this.label,
    required this.iconAsset,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final String label;
  final String iconAsset;
  final bool selected;
  final VoidCallback onTap;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(TraqSpacing.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? colors.primary : colors.border),
          color: selected ? colors.primary.withValues(alpha: 0.06) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TraqIcon(
                        iconAsset,
                        size: 16,
                        color: selected ? colors.primary : colors.textMuted,
                      ),
                      const SizedBox(width: TraqSpacing.xs),
                      Text(
                        label,
                        style: context.text.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: TraqSpacing.xs),
                    Text(
                      subtitle!,
                      style: context.text.bodySm.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: TraqSpacing.sm),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
