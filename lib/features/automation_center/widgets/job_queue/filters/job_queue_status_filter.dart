import 'package:flutter/material.dart';

class JobQueueStatusFilter extends StatelessWidget {
  final String selectedStatus;
  final List<String> statuses;
  final ValueChanged<String> onChanged;

  const JobQueueStatusFilter({
    super.key,
    required this.selectedStatus,
    required this.statuses,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedStatus,
      items: statuses.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
