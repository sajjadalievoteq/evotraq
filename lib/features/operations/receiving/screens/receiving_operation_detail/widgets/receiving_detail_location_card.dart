import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/utils/receiving_detail_helpers.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_info_row_copy.dart';

/// Receiving location card for Receiving operation detail.
class ReceivingDetailLocationCard extends StatelessWidget {
  const ReceivingDetailLocationCard({
    super.key,
    required this.operation,
  });

  final ReceivingResponse operation;

  @override
  Widget build(BuildContext context) {
    final sourceGlnCode =
        operation.sourceGLN ?? operation.sourceLocation?.glnCode;
    final receivingGlnCode = ReceivingDetailHelpers.receivingGlnCode(operation);

    return ReceivingDetailGroupCard(
      title: 'Receiving Locations',
      children: [
        if (sourceGlnCode != null)
          ReceivingDetailInfoRowCopy(label: 'Ship From GLN', value: sourceGlnCode),
        if (operation.sourceLocation?.locationName?.isNotEmpty == true)
          ReceivingDetailInfoRow(
            label: 'From Facility',
            value: operation.sourceLocation!.locationName!,
          ),
        if (operation.sourceLocation?.city?.isNotEmpty == true)
          ReceivingDetailInfoRow(
            label: 'From City',
            value: operation.sourceLocation!.city!,
          ),
        const ReceivingDetailInfoRow(label: 'Direction', value: 'From -> To'),
        if (receivingGlnCode != null)
          ReceivingDetailInfoRowCopy(
            label: 'Receiving GLN',
            value: receivingGlnCode,
          ),
        if (operation.receivingLocation?.locationName?.isNotEmpty == true)
          ReceivingDetailInfoRow(
            label: 'Receiving Facility',
            value: operation.receivingLocation!.locationName!,
          ),
        if (operation.receivingLocation?.city?.isNotEmpty == true)
          ReceivingDetailInfoRow(
            label: 'Receiving City',
            value: operation.receivingLocation!.city!,
          ),
      ],
    );
  }
}
