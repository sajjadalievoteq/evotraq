import 'package:flutter/material.dart';

class TransformationScenarioHelp extends StatelessWidget {
  const TransformationScenarioHelp({
    super.key,
    required this.title,
    required this.process,
    required this.bizStep,
  });

  final String title;
  final String process;
  final String bizStep;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(process),
            const SizedBox(height: 2),
            Text(bizStep, style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}
