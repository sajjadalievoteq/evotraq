import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_response_model.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/utils/unpacking_detail_formatters.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_info_row_copy.dart';

/// Reference details card for unpacking operation detail.
class UnpackingDetailReferenceCard extends StatelessWidget {
  const UnpackingDetailReferenceCard({
    super.key,
    required this.operation,
  });

  final UnpackingResponse operation;

  @override
  Widget build(BuildContext context) {
    return UnpackingDetailGroupCard(
      title: 'Reference Details',
      children: [
        if (operation.unpackingReference != null)
          UnpackingDetailInfoRowCopy(
            label: 'Unpacking Reference',
            value: operation.unpackingReference!,
          ),
        if (operation.operatorId != null)
          UnpackingDetailInfoRow(label: 'Operator ID', value: operation.operatorId!),
        if (operation.processedAt != null)
          UnpackingDetailInfoRow(
            label: 'Processed At',
            value: UnpackingDetailFormatters.formatDateTime(operation.processedAt!),
          ),
      ],
    );
  }
}
