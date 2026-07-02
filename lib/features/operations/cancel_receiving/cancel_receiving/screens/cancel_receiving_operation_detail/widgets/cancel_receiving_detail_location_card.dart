import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_response_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_info_row_copy.dart';

/// CancelReceiving location card for shipping operation detail.
class CancelReceivingDetailLocationCard extends StatelessWidget {
  const CancelReceivingDetailLocationCard({
    super.key,
    required this.operation,
    required this.sourceGlnDetails,
    required this.receivingGlnDetails,
  });

  final CancelReceivingResponse operation;
  final GLN? sourceGlnDetails;
  final GLN? receivingGlnDetails;

  @override
  Widget build(BuildContext context) {
    return CancelReceivingDetailGroupCard(
      title: 'Cancel Receiving Locations',
      children: [
        if (operation.sourceGLN != null)
          CancelReceivingDetailInfoRowCopy(label: 'Ship From GLN', value: operation.sourceGLN!),
        if (sourceGlnDetails?.locationName.isNotEmpty == true)
          CancelReceivingDetailInfoRow(label: 'From Facility', value: sourceGlnDetails!.locationName),
        if (sourceGlnDetails?.city.isNotEmpty == true)
          CancelReceivingDetailInfoRow(label: 'From City', value: sourceGlnDetails!.city),
        const CancelReceivingDetailInfoRow(label: 'Direction', value: 'From -> To'),
        if (operation.receivingGLN != null)
          CancelReceivingDetailInfoRowCopy(label: 'Ship To GLN', value: operation.receivingGLN!),
        if (receivingGlnDetails?.locationName.isNotEmpty == true)
          CancelReceivingDetailInfoRow(
            label: 'To Facility',
            value: receivingGlnDetails!.locationName,
          ),
        if (receivingGlnDetails?.city.isNotEmpty == true)
          CancelReceivingDetailInfoRow(label: 'To City', value: receivingGlnDetails!.city),
      ],
    );
  }
}
