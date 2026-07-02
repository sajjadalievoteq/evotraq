import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_info_row_copy.dart';

/// Return Receiving location card for Return Receiving operation detail.
class ReturnReceivingDetailLocationCard extends StatelessWidget {
  const ReturnReceivingDetailLocationCard({
    super.key,
    required this.operation,
  });

  final ReturnReceivingResponse operation;

  @override
  Widget build(BuildContext context) {
    final sourceGlnCode =
        operation.sourceGLN ?? operation.sourceLocation?.glnCode;
    final receivingGlnCode =
        operation.receivingGLN ?? operation.receivingLocation?.glnCode;

    return ReturnReceivingDetailGroupCard(
      title: 'Return Receiving Locations',
      children: [
        if (sourceGlnCode != null)
          ReturnReceivingDetailInfoRowCopy(
            label: 'Returned From GLN',
            value: sourceGlnCode,
          ),
        if (operation.sourceLocation?.locationName?.isNotEmpty == true)
          ReturnReceivingDetailInfoRow(
            label: 'From Facility',
            value: operation.sourceLocation!.locationName!,
          ),
        if (operation.sourceLocation?.city?.isNotEmpty == true)
          ReturnReceivingDetailInfoRow(
            label: 'From City',
            value: operation.sourceLocation!.city!,
          ),
        const ReturnReceivingDetailInfoRow(label: 'Direction', value: 'From -> To'),
        if (receivingGlnCode != null)
          ReturnReceivingDetailInfoRowCopy(
            label: 'Return Receiving GLN',
            value: receivingGlnCode,
          ),
        if (operation.receivingLocation?.locationName?.isNotEmpty == true)
          ReturnReceivingDetailInfoRow(
            label: 'Return Receiving Facility',
            value: operation.receivingLocation!.locationName!,
          ),
        if (operation.receivingLocation?.city?.isNotEmpty == true)
          ReturnReceivingDetailInfoRow(
            label: 'Return Receiving City',
            value: operation.receivingLocation!.city!,
          ),
      ],
    );
  }
}
