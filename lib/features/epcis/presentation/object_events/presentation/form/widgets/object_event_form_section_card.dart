import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_required_indicator.dart';

class ObjectEventFormSectionCard extends StatelessWidget {
  final String? title;
  final bool showTitleRequiredIndicator;
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? margin;

  const ObjectEventFormSectionCard({
    super.key,
    this.title,
    this.showTitleRequiredIndicator = false,
    required this.child,
    this.color,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  if (showTitleRequiredIndicator)
                    const ObjectEventFormRequiredIndicator(),
                ],
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
