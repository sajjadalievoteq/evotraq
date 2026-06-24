import 'package:flutter/material.dart';

class AggregationEventDetailAwaitingPane extends StatelessWidget {
  const AggregationEventDetailAwaitingPane({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.layers_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'Select an event from the list',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
