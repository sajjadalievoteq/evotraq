import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_info_row_copy.dart';

/// CancelReceiving location card for shipping operation detail.
class CancelReceivingDetailLocationCard extends StatelessWidget {
  const CancelReceivingDetailLocationCard({
    super.key,
    required this.operation,
  });

  final CancelReceivingResponse operation;

  @override
  Widget build(BuildContext context) {
    final sourceGlnCode =
        operation.sourceGLN ?? operation.sourceLocation?.glnCode;
    final receivingGlnCode =
        operation.receivingGLN ?? operation.receivingLocation?.glnCode;

    return CancelReceivingDetailGroupCard(
      title: 'Cancel Receiving Locations',
      children: [
        if (sourceGlnCode != null)
          CancelReceivingDetailInfoRowCopy(
            label: 'Sender (Ship-From) GLN',
            value: sourceGlnCode,
          ),
        if (operation.sourceLocation?.locationName?.isNotEmpty == true)
          CancelReceivingDetailInfoRow(
            label: 'From Facility',
            value: operation.sourceLocation!.locationName!,
          ),
        if (operation.sourceLocation?.city?.isNotEmpty == true)
          CancelReceivingDetailInfoRow(
            label: 'From City',
            value: operation.sourceLocation!.city!,
          ),
        const CancelReceivingDetailInfoRow(label: 'Direction', value: 'From -> To'),
        if (receivingGlnCode != null)
          CancelReceivingDetailInfoRowCopy(
            label: 'Receive-At GLN',
            value: receivingGlnCode,
          ),
        if (operation.receivingLocation?.locationName?.isNotEmpty == true)
          CancelReceivingDetailInfoRow(
            label: 'To Facility',
            value: operation.receivingLocation!.locationName!,
          ),
        if (operation.receivingLocation?.city?.isNotEmpty == true)
          CancelReceivingDetailInfoRow(
            label: 'To City',
            value: operation.receivingLocation!.city!,
          ),
      ],
    );
  }
}
