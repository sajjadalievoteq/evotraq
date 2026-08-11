import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_toolbar_constants.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_list_page_sizes.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_sort_menu_row.dart';

class Gs1ListSortMenu extends StatelessWidget {
  const Gs1ListSortMenu({
    required this.sortTooltip,
    required this.isAscending,
    required this.onSortOrderSelected,
    required this.onOpenOptions,
  });

  final String? sortTooltip;
  final bool isAscending;
  final ValueChanged<String> onSortOrderSelected;
  final VoidCallback onOpenOptions;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: sortTooltip ?? 'Sort',
      padding: EdgeInsets.zero,
      icon: TraqIcon(
        isAscending ? AppAssets.iconArrowUpR : AppAssets.iconArrowD,
        size: kGs1ListFieldIconSize,
      ),
      iconColor: kGs1ListToolbarIconColor,
      iconSize: kGs1ListFieldIconSize,
      onSelected: (value) {
        switch (value) {
          case 'asc':
          case 'desc':
            onSortOrderSelected(value);
          case 'options':
            onOpenOptions();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'asc',
          child: Gs1ListSortMenuRow(label: 'Ascending', selected: isAscending),
        ),
        PopupMenuItem(
          value: 'desc',
          child: Gs1ListSortMenuRow(
            label: 'Descending',
            selected: !isAscending,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'options',
          child: Text('Sort field & filtersâ€¦'),
        ),
      ],
    );
  }
}
