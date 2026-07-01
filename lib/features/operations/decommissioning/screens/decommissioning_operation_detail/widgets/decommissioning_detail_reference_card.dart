import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_response_model.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/utils/decommissioning_detail_formatters.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/widgets/decommissioning_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/widgets/decommissioning_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/widgets/decommissioning_detail_info_row_copy.dart';

/// Reference details card for Decommissioning operation detail.
class DecommissioningDetailReferenceCard extends StatelessWidget {
  const DecommissioningDetailReferenceCard({
    super.key,
    required this.operation,
  });

  final DecommissioningResponse operation;

  @override
  Widget build(BuildContext context) {
    return DecommissioningDetailGroupCard(
      title: 'Reference Details',
      children: [
        if (operation.decommissioningReference != null)
          DecommissioningDetailInfoRowCopy(
            label: 'Decommissioning Reference',
            value: operation.decommissioningReference!,
          ),
        if (operation.decommissioningOperationId != null)
          DecommissioningDetailInfoRowCopy(
            label: 'Operation ID',
            value: operation.decommissioningOperationId!,
          ),
        if (operation.processedAt != null)
          DecommissioningDetailInfoRow(
            label: 'Processed At',
            value: DecommissioningDetailFormatters.formatDateTime(operation.processedAt!),
          ),
      ],
    );
  }
}
