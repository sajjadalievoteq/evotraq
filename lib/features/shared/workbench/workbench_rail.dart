import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class WorkbenchRailItem {
  const WorkbenchRailItem({
    required this.id,
    required this.iconAsset,
    required this.label,
  });

  final String id;
  final String iconAsset;
  final String label;
}

/// Non-selectable section in a workbench rail (TOOLS / VALIDATION / …).
class WorkbenchRailGroup {
  const WorkbenchRailGroup({
    required this.title,
    required this.items,
  });

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

  /// Flat list of all selectable items across groups.
  static List<WorkbenchRailItem> flatten(List<WorkbenchRailGroup> groups) => [
        for (final g in groups) ...g.items,
      ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListView(
      padding: const EdgeInsets.symmetric(
        vertical: TraqSpacing.md,
        horizontal: TraqSpacing.sm,
      ),
      children: [
        for (var gi = 0; gi < groups.length; gi++) ...[
          if (gi > 0) const SizedBox(height: TraqSpacing.md),
          _SectionHeader(title: groups[gi].title, colors: colors),
          const SizedBox(height: TraqSpacing.xs),
          for (final item in groups[gi].items)
            _RailItem(
              icon: item.iconAsset,
              label: item.label,
              selected: item.id == selectedId,
              onTap: () => onSelect(item.id),
              colors: colors,
            ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.colors});

  final String title;
  final TraqColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TraqSpacing.md,
        TraqSpacing.xs,
        TraqSpacing.md,
        TraqSpacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: context.text.cap.copyWith(
          color: colors.textMuted,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
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
    final fg = selected ? colors.primary : colors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: TraqSpacing.xs),
      child: Material(
        color: selected ? colors.primaryMuted : Colors.transparent,
        borderRadius: BorderRadius.circular(TraqRadius.sm.x),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TraqRadius.sm.x),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TraqSpacing.md,
              vertical: TraqSpacing.sm,
            ),
            child: Row(
              children: [
                TraqIcon(icon, size: 18, color: fg),
                const SizedBox(width: TraqSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: context.text.body.copyWith(
                      color: fg,
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
