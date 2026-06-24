import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_status_rules.dart'
    as status_rules;
import 'package:traqtrace_app/core/widgets/gs1_fields/gtin_entry_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_validators.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_date_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class SsccClassificationCard extends StatelessWidget {
  const SsccClassificationCard({
    super.key,
    required this.borderColor,
    required this.isReadOnly,
    required this.unitType,
    required this.contentHomogeneity,
    required this.onUnitTypeChanged,
    required this.onHomogeneityChanged,
    this.containedGtinController,
    this.containedQuantityController,
    this.containedBatchController,
    this.containedExpiry,
    this.onPickContainedExpiry,
  });

  final Color borderColor;
  final bool isReadOnly;
  final UnitType unitType;
  final ContentHomogeneity contentHomogeneity;
  final ValueChanged<UnitType> onUnitTypeChanged;
  final ValueChanged<ContentHomogeneity> onHomogeneityChanged;
  final TextEditingController? containedGtinController;
  final TextEditingController? containedQuantityController;
  final TextEditingController? containedBatchController;
  final DateTime? containedExpiry;
  final VoidCallback? onPickContainedExpiry;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: 'Classification & Content',
      outlineColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<UnitType>(
            decoration: const InputDecoration(
              labelText: 'Unit Type',
              helperText: 'Physical logistic unit type',
              border: OutlineInputBorder(),
            ),
            value: unitType,
            items: UnitType.values
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(status_rules.friendlyUnitTypeLabel(t)),
                  ),
                )
                .toList(),
            onChanged: isReadOnly
                ? null
                : (v) {
                    if (v != null) onUnitTypeChanged(v);
                  },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ContentHomogeneity>(
            decoration: const InputDecoration(
              labelText: 'Content Homogeneity',
              helperText: 'Homogeneous vs mixed contents',
              border: OutlineInputBorder(),
            ),
            value: contentHomogeneity,
            items: ContentHomogeneity.values
                .map(
                  (h) => DropdownMenuItem(
                    value: h,
                    child: Text(h.name.replaceAll('_', ' ')),
                  ),
                )
                .toList(),
            onChanged: isReadOnly
                ? null
                : (v) {
                    if (v != null) onHomogeneityChanged(v);
                  },
          ),
          if (containedGtinController != null &&
              contentHomogeneity != ContentHomogeneity.MIXED) ...[
            const SizedBox(height: 16),
            GtinEntryField(
              controller: containedGtinController!,
              label: 'Contained GTIN',
              enabled: !isReadOnly,
              validator: (v) {
                if (v == null || v.isEmpty) return null;
                return GtinFieldValidators.validateGtinCode(v);
              },
            ),
          ],
          if (containedQuantityController != null &&
              contentHomogeneity == ContentHomogeneity.HOMOGENEOUS) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: containedQuantityController,
              readOnly: isReadOnly,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Contained Quantity',
                border: OutlineInputBorder(),
              ),
              validator: validateContainedQuantity,
            ),
          ],
          if (containedBatchController != null &&
              contentHomogeneity == ContentHomogeneity.HOMOGENEOUS) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: containedBatchController,
              readOnly: isReadOnly,
              decoration: const InputDecoration(
                labelText: 'Contained Batch',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          if (contentHomogeneity == ContentHomogeneity.HOMOGENEOUS) ...[
            const SizedBox(height: 16),
            Gs1DatePickerField(
              label: 'Contained Expiry',
              value: containedExpiry,
              onTap: isReadOnly ? null : onPickContainedExpiry,
              helperText: 'Optional — batch expiry for homogeneous contents',
              emptyValueLabel: 'Not set (optional)',
            ),
          ],
        ],
      ),
    );
  }
}
