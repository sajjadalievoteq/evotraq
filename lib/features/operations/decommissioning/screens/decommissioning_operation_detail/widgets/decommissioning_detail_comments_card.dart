import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_response_model.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/widgets/decommissioning_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/widgets/decommissioning_detail_info_row.dart';

/// Comments card for Decommissioning operation detail.
class DecommissioningDetailCommentsCard extends StatelessWidget {
  const DecommissioningDetailCommentsCard({
    super.key,
    required this.operation,
  });

  final DecommissioningResponse operation;

  @override
  Widget build(BuildContext context) {
    return DecommissioningDetailGroupCard(
      title: 'Comments',
      children: [
        DecommissioningDetailInfoRow(label: 'Notes', value: operation.comments!),
      ],
    );
  }
}
