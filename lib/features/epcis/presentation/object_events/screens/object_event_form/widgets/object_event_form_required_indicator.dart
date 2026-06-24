import 'package:flutter/material.dart';

/// Primary-colored asterisk for required fields (matches TraqTrace form convention).
class ObjectEventFormRequiredIndicator extends StatelessWidget {
  const ObjectEventFormRequiredIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      ' *',
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class ObjectEventFormSectionTitle extends StatelessWidget {
  final String title;
  final bool showRequiredIndicator;

  const ObjectEventFormSectionTitle({
    super.key,
    required this.title,
    this.showRequiredIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        if (showRequiredIndicator) const ObjectEventFormRequiredIndicator(),
      ],
    );
  }
}

Widget objectEventFormFieldLabel(
  BuildContext context,
  String label,
  bool isMandatory,
) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label),
      if (isMandatory) const ObjectEventFormRequiredIndicator(),
    ],
  );
}
