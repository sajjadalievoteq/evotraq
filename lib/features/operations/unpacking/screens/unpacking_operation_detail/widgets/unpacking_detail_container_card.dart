import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_response_model.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_info_row_copy.dart';

/// Container (SSCC) card for unpacking operation detail.
class UnpackingDetailContainerCard extends StatelessWidget {
  const UnpackingDetailContainerCard({
    super.key,
    required this.operation,
  });

  final UnpackingResponse operation;

  @override
  Widget build(BuildContext context) {
    return UnpackingDetailGroupCard(
      title: 'Container (SSCC)',
      children: [
        if (operation.parentContainerId != null)
          UnpackingDetailInfoRowCopy(label: 'SSCC', value: operation.parentContainerId!)
        else
          const UnpackingDetailInfoRow(label: 'SSCC', value: 'Not specified'),
      ],
    );
  }
}
