import 'package:flutter/material.dart';

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
