import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_info_row.dart';

/// Comments card for Receiving operation detail.
class ReceivingDetailCommentsCard extends StatelessWidget {
  const ReceivingDetailCommentsCard({
    super.key,
    required this.operation,
  });

  final ReceivingResponse operation;

  @override
  Widget build(BuildContext context) {
    return ReceivingDetailGroupCard(
      title: 'Comments',
      children: [
        ReceivingDetailInfoRow(label: 'Notes', value: operation.comments!),
      ],
    );
  }
}
