import 'package:flutter/material.dart';

class JobQueueJobTypeFilter extends StatelessWidget {
  final String selectedJobType;
  final List<String> jobTypes;
  final ValueChanged<String> onChanged;

  const JobQueueJobTypeFilter({
    super.key,
    required this.selectedJobType,
    required this.jobTypes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedJobType,
      items: jobTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
