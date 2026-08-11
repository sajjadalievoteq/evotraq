import 'package:flutter/material.dart';

class TransformationEventsHelpSection extends StatelessWidget {
  const TransformationEventsHelpSection({
    super.key,
    required this.title,
    required this.description,
    this.bulletPoints = const [],
  });

  final String title;
  final String description;
  final List<String> bulletPoints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(description),
        if (bulletPoints.isNotEmpty) const SizedBox(height: 4),
        for (final point in bulletPoints)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(point)),
              ],
            ),
          ),
      ],
    );
  }
}
