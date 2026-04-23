import 'package:flutter/material.dart';

class GtinAdvancedFiltersToggle extends StatelessWidget {
  const GtinAdvancedFiltersToggle({
    super.key,
    required this.showAdvancedFilters,
    required this.onToggle,
    required this.onClearAll,
  });

  final bool showAdvancedFilters;
  final VoidCallback onToggle;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: onToggle,
            icon: Icon(
              showAdvancedFilters ? Icons.expand_less : Icons.expand_more,
            ),
            label: Text(
              showAdvancedFilters ? 'Hide Advanced Filters' : 'Show Advanced Filters',
            ),
          ),
          const Spacer(),
          if (showAdvancedFilters)
            TextButton(
              onPressed: onClearAll,
              child: const Text('Clear All Filters'),
            ),
        ],
      ),
    );
  }
}

