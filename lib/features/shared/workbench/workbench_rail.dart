import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_rail_item_widget.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_rail_section_header.dart';

import '../../../core/utils/responsive_utils.dart';

class WorkbenchRailItem {
  const WorkbenchRailItem({
    required this.id,
    required this.iconAsset,
    required this.label,
    this.badgeCount,
  });

  final String id;
  final String iconAsset;
  final String label;
  final int? badgeCount;
}

class WorkbenchRailGroup {
  const WorkbenchRailGroup({required this.title, required this.items});

  final String title;
  final List<WorkbenchRailItem> items;
}

class WorkbenchRail extends StatelessWidget {
  const WorkbenchRail({
    super.key,
    required this.groups,
    required this.selectedId,
    required this.onSelect,
  });

  final List<WorkbenchRailGroup> groups;
  final String selectedId;
  final ValueChanged<String> onSelect;

  static List<WorkbenchRailItem> flatten(List<WorkbenchRailGroup> groups) => [
    for (final g in groups) ...g.items,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      color: colors.surface,
      child: ListView(
        padding: EdgeInsets.only(top: context.padding.top),
        children: [
          for (var gi = 0; gi < groups.length; gi++) ...[
            if (gi > 0) const SizedBox(height: TraqSpacing.md),
            WorkbenchRailSectionHeader(title: groups[gi].title, colors: colors),
            const SizedBox(height: TraqSpacing.xs),
            for (final item in groups[gi].items)
              WorkbenchRailItemWidget(
                icon: item.iconAsset,
                label: item.label,
                selected: item.id == selectedId,
                onTap: () => onSelect(item.id),
                colors: colors,
                badgeCount: item.badgeCount,
              ),
          ],
          SizedBox(height: context.padding.top),
        ],
      ),
    );
  }
}
