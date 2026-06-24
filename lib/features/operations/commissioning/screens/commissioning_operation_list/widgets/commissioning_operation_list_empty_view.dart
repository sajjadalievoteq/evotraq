import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';

class CommissioningOperationListEmptyView extends StatelessWidget {
  const CommissioningOperationListEmptyView({
    super.key,
    required this.hasOperations,
    required this.hasActiveFilters,
    required this.onClearFilters,
  });

  final bool hasOperations;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.play_for_work, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            hasOperations
                ? 'No operations match your search or filters'
                : 'No commissioning operations found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            hasOperations
                ? 'Try a different search term or clear filters'
                : 'Create your first commissioning operation',
            style: TextStyle(color: Colors.grey[500]),
          ),
          if (hasOperations && hasActiveFilters) ...[
            const SizedBox(height: 16),
            CustomButtonWidget(onTap: onClearFilters, title: 'Clear Filters'),
          ],
        ],
      ),
    );
  }
}
