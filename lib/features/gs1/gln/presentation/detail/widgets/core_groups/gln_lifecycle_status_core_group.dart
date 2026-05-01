import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gln/presentation/detail/widgets/gln_detail_date_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

/// Operating status, effective dates, non-reuse display.
class GlnLifecycleStatusCoreGroup extends StatelessWidget {
  const GlnLifecycleStatusCoreGroup({
    super.key,
    required this.isEditing,
    required this.operatingStatus,
    required this.onOperatingStatusChanged,
    required this.effectiveFrom,
    required this.effectiveTo,
    required this.nonReuseUntil,
    required this.onPickEffectiveFrom,
    required this.onPickEffectiveTo,
  });

  final bool isEditing;
  final String operatingStatus;
  final ValueChanged<String?> onOperatingStatusChanged;
  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;
  final DateTime? nonReuseUntil;
  final VoidCallback onPickEffectiveFrom;
  final VoidCallback onPickEffectiveTo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Lifecycle & status'),
        DropdownButtonFormField<String>(
          value: operatingStatus,
          decoration: const InputDecoration(
            labelText: 'Operating status',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'DRAFT', child: Text('DRAFT')),
            DropdownMenuItem(value: 'ACTIVE', child: Text('ACTIVE')),
            DropdownMenuItem(value: 'INACTIVE', child: Text('INACTIVE')),
            DropdownMenuItem(
              value: 'DISCONTINUED',
              child: Text('DISCONTINUED'),
            ),
          ],
          onChanged: isEditing ? onOperatingStatusChanged : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GlnDetailDateField(
                label: 'Effective from',
                value: effectiveFrom,
                onTap: isEditing ? onPickEffectiveFrom : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlnDetailDateField(
                label: 'Effective to',
                value: effectiveTo,
                onTap: isEditing ? onPickEffectiveTo : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Non-reuse waiting until',
            border: OutlineInputBorder(),
            helperText: 'Read-only — set by backend when discontinued',
          ),
          child: Text(
            nonReuseUntil != null
                ? GlnDetailDateField.displayFormat.format(nonReuseUntil!)
                : '—',
            style: TextStyle(
              color: nonReuseUntil != null ? Colors.black87 : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
