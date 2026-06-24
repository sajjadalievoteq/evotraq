import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/home/utils/home_strings.dart';

class ThroughputRangeToggle extends StatelessWidget {
  const ThroughputRangeToggle({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = HomeStrings.chartRangeLabels;
    final c = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.borderVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < labels.length; i++)
            Material(
              color: Colors.transparent,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: selectedIndex == i ? c.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: InkWell(
                  onTap: () => onChanged(i),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      labels[i],
                      style: context.text.bodySm.copyWith(
                        fontWeight: selectedIndex == i
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selectedIndex == i ? Colors.white : c.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
