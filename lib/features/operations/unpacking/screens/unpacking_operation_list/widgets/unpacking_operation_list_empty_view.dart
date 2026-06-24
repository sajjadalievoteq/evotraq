import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';

/// Empty state for unpacking operation list.
class UnpackingOperationListEmptyView extends StatelessWidget {
  const UnpackingOperationListEmptyView({
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
          Icon(Icons.inventory_2, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            hasOperations
                ? 'No operations match your search or filters.'
                : 'No unpacking operations yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            hasOperations
                ? 'Try a different search term, or clear your filters to see all operations.'
                : 'Tap the + button to create your first unpacking operation.',
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
