import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_response_model.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_info_row.dart';

/// Comments card for unpacking operation detail.
class UnpackingDetailCommentsCard extends StatelessWidget {
  const UnpackingDetailCommentsCard({
    super.key,
    required this.operation,
  });

  final UnpackingResponse operation;

  @override
  Widget build(BuildContext context) {
    return UnpackingDetailGroupCard(
      title: 'Comments',
      children: [
        UnpackingDetailInfoRow(label: 'Notes', value: operation.comments!),
      ],
    );
  }
}
