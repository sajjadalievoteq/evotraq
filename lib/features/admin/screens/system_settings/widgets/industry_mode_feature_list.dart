import 'package:flutter/material.dart';

class IndustryModeFeatureList extends StatelessWidget {
  const IndustryModeFeatureList({super.key});

  static const features = [
    'NDC Number Management',
    'Drug Classification',
    'Controlled Substance Tracking',
    'Temperature Requirements',
    'Therapeutic Class',
    'Dosage Form & Strength',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Features:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: features.map((feature) {
            return Chip(
              label: Text(
                feature,
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            );
          }).toList(),
        ),
      ],
    );
  }
}
