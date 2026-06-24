import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_date_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class SsccDatesCard extends StatelessWidget {
  const SsccDatesCard({
    super.key,
    required this.borderColor,
    required this.isReadOnly,
    required this.packingDate,
    required this.onPackingDateSelected,
    this.sscc,
  });

  final Color borderColor;
  final bool isReadOnly;
  final DateTime? packingDate;
  final VoidCallback onPackingDateSelected;
  final SSCC? sscc;

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: 'Dates & Milestones',
      outlineColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gs1DatePickerField(
            label: 'Packing Date',
            value: packingDate,
            onTap: isReadOnly ? null : onPackingDateSelected,
            helperText: 'Optional — when the logistic unit was packed',
            emptyValueLabel: 'Not set (optional)',
          ),
          if (sscc?.shippingDate != null) ...[
            const SizedBox(height: 12),
            Gs1DatePickerField(
              label: 'Shipped',
              value: sscc!.shippingDate,
            ),
          ],
          if (sscc?.receivingDate != null) ...[
            const SizedBox(height: 12),
            Gs1DatePickerField(
              label: 'Received',
              value: sscc!.receivingDate,
            ),
          ],
          if (sscc?.lastShipmentAt != null) ...[
            const SizedBox(height: 12),
            Gs1DatePickerField(
              label: 'Last Shipment',
              value: sscc!.lastShipmentAt,
            ),
          ],
        ],
      ),
    );
  }
}
