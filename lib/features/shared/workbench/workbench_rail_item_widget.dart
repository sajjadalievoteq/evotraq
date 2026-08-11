import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class WorkbenchRailItemWidget extends StatelessWidget {
  const WorkbenchRailItemWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
  });
  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final TraqColors colors;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? colors.primary : colors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: TraqSpacing.xs),
      child: Material(
        color: selected ? colors.background : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.padding.top,
              vertical: TraqSpacing.lg,
            ),
            child: Row(
              children: [
                TraqIcon(icon, size: 18, color: foreground),
                const SizedBox(width: TraqSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: context.text.body.copyWith(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
