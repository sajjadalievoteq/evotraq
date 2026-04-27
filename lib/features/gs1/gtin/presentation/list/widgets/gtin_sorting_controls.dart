import 'package:flutter/material.dart';

import '../../../../../../core/consts/app_consts.dart';
import '../../../../../../core/theme/color_manager.dart';
import '../../../../../../shared/layout/layout_manager.dart';

class GtinSortingControls extends StatelessWidget {
  const GtinSortingControls({
    super.key,
    required this.sortOrder,
    required this.onToggleSortOrder,
  });

  final String sortOrder;
  final VoidCallback onToggleSortOrder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final label = Text(
      'Sort by product name (A–Z)',
      style: theme.textTheme.bodyMedium,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    final toggle = IconButton(
      onPressed: onToggleSortOrder,
      icon: Icon(
        sortOrder == 'asc' ? Icons.arrow_upward : Icons.arrow_downward,
      ),
      color: ColorManager.primary(context),
      tooltip: sortOrder == 'asc' ? 'Ascending' : 'Descending',
    );

    return AppLayoutBuilder(
      builder: (context, layout) {
        final horizontalMargin = layout.width < 420 ? 8.0 : 16.0;

        return Container(

          padding: EdgeInsets.symmetric(
            horizontal: layout.resolve(compact: 12.0, medium: 16.0),
            vertical: layout.resolve(compact: 10.0, medium: 8.0),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Constants.cardRadius),
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: layout.isCompact
              ? Row(
                  children: [
                    Expanded(child: label),
                    toggle,
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: label),
                    const SizedBox(width: 16),
                    toggle,
                  ],
                ),
        );
      },
    );
  }
}
