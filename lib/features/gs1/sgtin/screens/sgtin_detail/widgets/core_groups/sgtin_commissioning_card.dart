import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/core/widgets/gln_selector.dart';

class SgtinCommissioningCard extends StatelessWidget {
  const SgtinCommissioningCard({
    super.key,
    required this.borderColor,
    required this.isEditing,
    required this.isCreating,
    required this.onLocationChanged,
    this.sgtin,
    this.selectedLocation,
  });

  final Color borderColor;
  final bool isEditing;
  final bool isCreating;
  final ValueChanged<GLN?> onLocationChanged;
  final SGTIN? sgtin;
  final GLN? selectedLocation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Gs1GroupCard(
      title: 'Commissioning',
      outlineColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isEditing || isCreating)
            GLNSelector(
              label:
                  'Commissioning Location (GLN)',
              hintText: 'Select commissioning location',
              initialValue: selectedLocation,
              isRequired: isCreating,
              onChanged: onLocationChanged,
            )
          else
            SgtinInfoRow(
              'Commissioning Location',
              selectedLocation != null
                  ? '${selectedLocation!.glnCode} – ${selectedLocation!.locationName}'
                  : sgtin?.commissioningReadpointGln,
            ),
          if (!isEditing && sgtin?.commissioningReadpointGln != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow(
              'Commissioning Readpoint GLN',
              sgtin!.commissioningReadpointGln,
            ),
          ],
          if (sgtin?.commissioningEventId != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow(
              'Commissioning Event ID',
              sgtin!.commissioningEventId,
              monospace: true,
            ),
          ],
          if (isCreating)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Required: Where was this product commissioned?',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
