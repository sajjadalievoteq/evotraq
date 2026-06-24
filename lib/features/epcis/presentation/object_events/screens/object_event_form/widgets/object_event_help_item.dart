import 'package:flutter/material.dart';

class ObjectEventHelpItem extends StatelessWidget {
  const ObjectEventHelpItem({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(description),
          const SizedBox(height: 4.0),
        ],
      ),
    );
  }
}
