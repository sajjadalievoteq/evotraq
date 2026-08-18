import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/features/gs1/widgets/split_view/master_detail_split_layout.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_rail.dart';

/// Shared master–detail workbench chrome (grouped rail + panel).
class WorkbenchScaffold extends StatelessWidget {
  const WorkbenchScaffold({
    super.key,
    required this.title,
    required this.groups,
    required this.selectedId,
    required this.onSelect,
    required this.panelBuilder,
    this.narrowListFlex = 28,
    this.wideListFlex = 22,
  });

  final String title;
  final List<WorkbenchRailGroup> groups;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final Widget Function(BuildContext context, String selectedId) panelBuilder;
  final int narrowListFlex;
  final int wideListFlex;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.layout.isDesktopUp;
    final detail = panelBuilder(context, selectedId);
    final colors = context.colors;

    return Scaffold(
      appBar: TraqAppBar(context, title: Text(title)),
      drawer: const AppDrawer(),
      body: isDesktop
          ? MasterDetailSplitLayout(
              narrowListFlex: narrowListFlex,
              wideListFlex: wideListFlex,
              list: WorkbenchRail(
                groups: groups,
                selectedId: selectedId,
                onSelect: onSelect,
              ),
              detail: detail,
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    TraqSpacing.md,
                    TraqSpacing.md,
                    TraqSpacing.md,
                    TraqSpacing.sm,
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedId,
                    decoration: const InputDecoration(
                      labelText: 'Section',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      for (final group in groups) ...[
                        DropdownMenuItem<String>(
                          enabled: false,
                          value: '__hdr_${group.title}',
                          child: Text(
                            group.title.toUpperCase(),
                            style: context.text.cap.copyWith(
                              color: colors.textMuted,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        for (final item in group.items)
                          DropdownMenuItem<String>(
                            value: item.id,
                            child: Row(
                              children: [
                                Flexible(child: Text(item.label)),
                                if (item.badgeCount != null &&
                                    item.badgeCount! > 0) ...[
                                  const SizedBox(width: TraqSpacing.sm),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: TraqSpacing.sm,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.error,
                                      borderRadius: TraqRadius.chip,
                                    ),
                                    child: Text(
                                      item.badgeCount! > 99
                                          ? '99+'
                                          : '${item.badgeCount}',
                                      style: context.text.cap.copyWith(
                                        color: colors.textOnInverse,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ],
                    onChanged: (value) {
                      if (value != null && !value.startsWith('__hdr_')) {
                        onSelect(value);
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                Expanded(child: detail),
              ],
            ),
    );
  }
}
