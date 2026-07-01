import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';

import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class Gs1ListSortingControls extends StatelessWidget {
  const Gs1ListSortingControls({
    super.key,
    required this.label,
    required this.sortOrder,
    required this.onToggleSortOrder,
  });

  final String label;
  final String sortOrder;
  final VoidCallback onToggleSortOrder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final text = Text(
      label,
      style: theme.textTheme.bodyMedium,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    final toggle = IconButton(
      onPressed: onToggleSortOrder,
      icon: TraqIcon(
        sortOrder == 'asc' ? AppAssets.iconArrowUpR : AppAssets.iconArrowD,
      ),
      color: Theme.of(context).brightness==Brightness.dark? Colors.white:Colors.black,
      tooltip: sortOrder == 'asc' ? 'Ascending' : 'Descending',
    );

    return AppLayoutBuilder(
      builder: (context, layout) {
        return Card(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: layout.resolve(compact: 12.0, medium: 16.0),
              vertical: layout.resolve(compact: 10.0, medium: 8.0),
            ),
            decoration: BoxDecoration(
              color: context.colors.surface,

            ),
            child: layout.isCompact
                ? Row(
                    children: [
                      Expanded(child: text),
                      toggle,
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: text),
                      const SizedBox(width: 16),
                      toggle,
                    ],
                  ),
          ),
        );
      },
    );
  }
}
