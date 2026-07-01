import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_info_row.dart';

/// Comments card for Return Receiving operation detail.
class ReturnReceivingDetailCommentsCard extends StatelessWidget {
  const ReturnReceivingDetailCommentsCard({
    super.key,
    required this.operation,
  });

  final ReturnReceivingResponse operation;

  @override
  Widget build(BuildContext context) {
    return ReturnReceivingDetailGroupCard(
      title: 'Comments',
      children: [
        ReturnReceivingDetailInfoRow(label: 'Notes', value: operation.comments!),
      ],
    );
  }
}

