import 'package:flutter/material.dart';

class Gs1ListSortMenuRow extends StatelessWidget {
  const Gs1ListSortMenuRow({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: selected
              ? Icon(
                  Icons.check,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
        ),
        Expanded(child: Text(label)),
      ],
    );
  }
}
