import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_info_row.dart';

/// Comments card for shipping operation detail.
class CancelReceivingDetailCommentsCard extends StatelessWidget {
  const CancelReceivingDetailCommentsCard({
    super.key,
    required this.operation,
  });

  final CancelReceivingResponse operation;

  @override
  Widget build(BuildContext context) {
    return CancelReceivingDetailGroupCard(
      title: 'Comments',
      children: [
        CancelReceivingDetailInfoRow(label: 'Notes', value: operation.comments!),
      ],
    );
  }
}
