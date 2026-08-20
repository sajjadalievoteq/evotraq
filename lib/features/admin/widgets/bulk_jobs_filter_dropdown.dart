import 'package:flutter/material.dart';

class BulkJobsFilterDropdown extends StatelessWidget {
  const BulkJobsFilterDropdown({
    required this.selectedFilter,
    required this.onChanged,
  });

  final String selectedFilter;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedFilter,
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      items: const [
        DropdownMenuItem(value: 'ALL', child: Text('All Jobs')),
        DropdownMenuItem(value: 'RUNNING', child: Text('Running')),
        DropdownMenuItem(value: 'COMPLETED', child: Text('Completed')),
        DropdownMenuItem(value: 'FAILED', child: Text('Failed')),
        DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
      ],
    );
  }
}
