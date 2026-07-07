import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row_copy.dart';

/// Shared SSCC container card for packing and unpacking detail screens.
class OperationDetailContainerCard extends StatelessWidget {
  const OperationDetailContainerCard({super.key, this.sscc});

  final String? sscc;

  @override
  Widget build(BuildContext context) {
    return OperationDetailGroupCard(
      title: 'Container (SSCC)',
      children: [
        if (sscc != null)
          OperationDetailInfoRowCopy(label: 'SSCC', value: sscc!)
        else
          const OperationDetailInfoRow(label: 'SSCC', value: 'Not specified'),
      ],
    );
  }
}
