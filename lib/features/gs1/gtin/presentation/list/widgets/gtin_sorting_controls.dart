import 'package:flutter/material.dart';

import '../../../../../../core/consts/app_consts.dart';
import '../../../../../../core/theme/color_manager.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Constants.cardRadius),
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Sort by product name (A–Z)'),
          const SizedBox(width: 16),
          IconButton(
            onPressed: onToggleSortOrder,
            icon: Icon(
              sortOrder == 'asc' ? Icons.arrow_upward : Icons.arrow_downward,
            ),
            color: ColorManager.primary(context),
            tooltip: sortOrder == 'asc' ? 'Ascending' : 'Descending',
          ),
        ],
      ),
    );
  }
}
