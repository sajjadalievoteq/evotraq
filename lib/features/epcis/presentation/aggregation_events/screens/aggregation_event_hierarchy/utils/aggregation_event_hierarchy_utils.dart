import 'package:flutter/material.dart';

abstract final class AggregationEventHierarchyUtils {
  static Icon actionIcon(String action) {
    switch (action) {
      case 'ADD':
        return const Icon(Icons.add_circle, color: Colors.green);
      case 'DELETE':
        return const Icon(Icons.remove_circle, color: Colors.red);
      case 'OBSERVE':
        return const Icon(Icons.visibility, color: Colors.blue);
      default:
        return const Icon(Icons.event);
    }
  }
}
