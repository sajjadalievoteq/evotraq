import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/theme/evotraq_theme.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';

/// “Sort by … / direction” row (GTIN/GLN list “sort” tile). Build [label] in the parent.
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
    final c = context.colors;

    final text = Text(
      label,
      style: theme.textTheme.bodyMedium,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    final toggle = IconButton(
      onPressed: onToggleSortOrder,
      icon: Icon(
        sortOrder == 'asc' ? Icons.arrow_upward : Icons.arrow_downward,
      ),
      color: c.primary,
      tooltip: sortOrder == 'asc' ? 'Ascending' : 'Descending',
    );

    return AppLayoutBuilder(
      builder: (context, layout) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: layout.resolve(compact: 12.0, medium: 16.0),
            vertical: layout.resolve(compact: 10.0, medium: 8.0),
          ),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: EvotraqRadius.card,
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
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
        );
      },
    );
  }
}
