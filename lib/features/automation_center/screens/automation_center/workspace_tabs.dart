import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class WorkspaceTab {
  const WorkspaceTab({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final String icon;
}

class WorkspaceTabs extends StatelessWidget {
  const WorkspaceTabs({
    required this.tabs,
    required this.selectedId,
    required this.onSelected,
  });

  final List<WorkspaceTab> tabs;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final tab in tabs)
            Semantics(
              button: true,
              selected: tab.id == selectedId,
              child: InkWell(
                onTap: () => onSelected(tab.id),
                borderRadius: TraqRadius.button,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TraqSpacing.lg,
                    vertical: TraqSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: tab.id == selectedId
                            ? colors.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      TraqIcon(
                        tab.icon,
                        size: 16,
                        color: tab.id == selectedId
                            ? colors.primary
                            : colors.textMuted,
                      ),
                      const SizedBox(width: TraqSpacing.sm),
                      Text(
                        tab.label,
                        style: context.text.bodySm.copyWith(
                          color: tab.id == selectedId
                              ? colors.primary
                              : colors.textSecondary,
                          fontWeight: tab.id == selectedId
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
