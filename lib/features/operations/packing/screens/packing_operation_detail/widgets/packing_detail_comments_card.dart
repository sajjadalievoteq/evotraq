import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_info_row.dart';

/// Comments card for packing operation detail.
class PackingDetailCommentsCard extends StatelessWidget {
  const PackingDetailCommentsCard({
    super.key,
    required this.operation,
  });

  final PackingResponse operation;

  @override
  Widget build(BuildContext context) {
    return PackingDetailGroupCard(
      title: 'Comments',
      children: [
        PackingDetailInfoRow(label: 'Notes', value: operation.comments!),
      ],
    );
  }
}
