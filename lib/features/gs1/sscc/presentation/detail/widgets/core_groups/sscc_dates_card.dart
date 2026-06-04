import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/detail/widgets/core_groups/sscc_card_helpers.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class SsccDatesCard extends StatelessWidget {
  const SsccDatesCard({
    super.key,
    required this.borderColor,
    required this.isReadOnly,
    required this.isCreating,
    required this.packingDate,
    required this.onPackingDateSelected,
    this.sscc,
  });

  final Color borderColor;
  final bool isReadOnly;
  final bool isCreating;
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
          if (!isCreating || !isReadOnly)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Packing Date'),
              subtitle: Text(
                packingDate != null
                    ? ssccFormatDate(packingDate)!
                    : 'Not set',
              ),
              trailing: isReadOnly
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: onPackingDateSelected,
                    ),
              onTap: isReadOnly ? null : onPackingDateSelected,
            ),
          if (sscc?.shippingDate != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow('Shipped', ssccFormatDt(sscc!.shippingDate)),
          ],
          if (sscc?.receivingDate != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow('Received', ssccFormatDt(sscc!.receivingDate)),
          ],
          if (sscc?.lastShipmentAt != null) ...[
            const SizedBox(height: 12),
            SgtinInfoRow('Last Shipment', ssccFormatDt(sscc!.lastShipmentAt)),
          ],
        ],
      ),
    );
  }
}
