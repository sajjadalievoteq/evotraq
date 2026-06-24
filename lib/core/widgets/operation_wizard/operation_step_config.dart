import 'package:flutter/material.dart';

/// Configuration for a single step in an operation wizard stepper.
class OperationStepConfig {
  const OperationStepConfig({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}
