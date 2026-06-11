import 'package:flutter/material.dart';

/// Reusable card wrapper for object event form sections.
class ObjectEventFormSectionCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? margin;

  const ObjectEventFormSectionCard({
    super.key,
    this.title,
    required this.child,
    this.color,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      margin: margin,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 8.0),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
