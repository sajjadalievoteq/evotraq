import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row.dart';

class OperationDetailCommentsCard extends StatelessWidget {
  const OperationDetailCommentsCard({super.key, required this.comments});

  final String comments;

  @override
  Widget build(BuildContext context) {
    return OperationDetailGroupCard(
      title: 'Comments',
      children: [
        OperationDetailInfoRow(label: 'Notes', value: comments),
      ],
    );
  }
}
