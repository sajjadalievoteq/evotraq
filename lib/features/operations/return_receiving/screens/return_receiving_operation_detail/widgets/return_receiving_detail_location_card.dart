import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_response_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_info_row_copy.dart';

/// Return Receiving location card for Return Receiving operation detail.
class ReturnReceivingDetailLocationCard extends StatelessWidget {
  const ReturnReceivingDetailLocationCard({
    super.key,
    required this.operation,
    required this.sourceGlnDetails,
    required this.receivingGlnDetails,
  });

  final ReturnReceivingResponse operation;
  final GLN? sourceGlnDetails;
  final GLN? receivingGlnDetails;

  @override
  Widget build(BuildContext context) {
    return ReturnReceivingDetailGroupCard(
      title: 'Return Receiving Locations',
      children: [
        if (operation.sourceGLN != null)
          ReturnReceivingDetailInfoRowCopy(label: 'Returned From GLN', value: operation.sourceGLN!),
        if (sourceGlnDetails?.locationName.isNotEmpty == true)
          ReturnReceivingDetailInfoRow(label: 'From Facility', value: sourceGlnDetails!.locationName),
        if (sourceGlnDetails?.city.isNotEmpty == true)
          ReturnReceivingDetailInfoRow(label: 'From City', value: sourceGlnDetails!.city),
        const ReturnReceivingDetailInfoRow(label: 'Direction', value: 'From -> To'),
        if (operation.receivingGLN != null)
          ReturnReceivingDetailInfoRowCopy(
            label: 'Return Receiving GLN',
            value: operation.receivingGLN!,
          ),
        if (receivingGlnDetails?.locationName.isNotEmpty == true)
          ReturnReceivingDetailInfoRow(
            label: 'Return Receiving Facility',
            value: receivingGlnDetails!.locationName,
          ),
        if (receivingGlnDetails?.city.isNotEmpty == true)
          ReturnReceivingDetailInfoRow(
            label: 'Return Receiving City',
            value: receivingGlnDetails!.city,
          ),
      ],
    );
  }
}

