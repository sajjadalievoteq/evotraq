import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/utils/packing_detail_formatters.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_info_row_copy.dart';

/// Reference details card for packing operation detail.
class PackingDetailReferenceCard extends StatelessWidget {
  const PackingDetailReferenceCard({
    super.key,
    required this.operation,
  });

  final PackingResponse operation;

  @override
  Widget build(BuildContext context) {
    return PackingDetailGroupCard(
      title: 'Reference Details',
      children: [
        if (operation.packingReference != null)
          PackingDetailInfoRowCopy(
            label: 'Packing Reference',
            value: operation.packingReference!,
          ),
        if (operation.operatorId != null)
          PackingDetailInfoRow(label: 'Operator ID', value: operation.operatorId!),
        if (operation.processedAt != null)
          PackingDetailInfoRow(
            label: 'Processed At',
            value: PackingDetailFormatters.formatDateTime(operation.processedAt!),
          ),
      ],
    );
  }
}
