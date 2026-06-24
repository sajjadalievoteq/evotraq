import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_info_row_copy.dart';

/// Container (SSCC) card for packing operation detail.
class PackingDetailContainerCard extends StatelessWidget {
  const PackingDetailContainerCard({
    super.key,
    required this.operation,
  });

  final PackingResponse operation;

  @override
  Widget build(BuildContext context) {
    return PackingDetailGroupCard(
      title: 'Container (SSCC)',
      children: [
        if (operation.parentContainerId != null)
          PackingDetailInfoRowCopy(label: 'SSCC', value: operation.parentContainerId!)
        else
          const PackingDetailInfoRow(label: 'SSCC', value: 'Not specified'),
      ],
    );
  }
}
