import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

/// Legacy operational subtype dropdown (warehouse, pharmacy, …).
class GlnOperationalLocationTypeCoreGroup extends StatelessWidget {
  const GlnOperationalLocationTypeCoreGroup({
    super.key,
    required this.isEditing,
    required this.locationTypeLabel,
    required this.onLocationTypeChanged,
  });

  final bool isEditing;
  final String locationTypeLabel;
  final ValueChanged<String?> onLocationTypeChanged;

  static final _items = [
    'Manufacturing Site',
    'Warehouse',
    'Distribution Center',
    'Pharmacy',
    'Hospital',
    'Wholesaler',
    'Clinic',
    'Regulatory Body',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Operational location type'),
        DropdownButtonFormField<String>(
          value: _items.contains(locationTypeLabel) ? locationTypeLabel : 'Other',
          decoration: const InputDecoration(
            labelText: 'Legacy location subtype',
            helperText: 'Operational category (warehouse, pharmacy, …)',
            border: OutlineInputBorder(),
          ),
          items: _items
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: isEditing ? onLocationTypeChanged : null,
        ),
      ],
    );
  }
}
