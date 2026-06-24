import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_info_row_copy.dart';

/// Receiving location card for Receiving operation detail.
class ReceivingDetailLocationCard extends StatelessWidget {
  const ReceivingDetailLocationCard({
    super.key,
    required this.operation,
    required this.sourceGlnDetails,
    required this.receivingGlnDetails,
  });

  final ReceivingResponse operation;
  final GLN? sourceGlnDetails;
  final GLN? receivingGlnDetails;

  @override
  Widget build(BuildContext context) {
    return ReceivingDetailGroupCard(
      title: 'Receiving Locations',
      children: [
        if (operation.sourceGLN != null)
          ReceivingDetailInfoRowCopy(label: 'Ship From GLN', value: operation.sourceGLN!),
        if (sourceGlnDetails?.locationName.isNotEmpty == true)
          ReceivingDetailInfoRow(label: 'From Facility', value: sourceGlnDetails!.locationName),
        if (sourceGlnDetails?.city.isNotEmpty == true)
          ReceivingDetailInfoRow(label: 'From City', value: sourceGlnDetails!.city),
        const ReceivingDetailInfoRow(label: 'Direction', value: 'From -> To'),
        if (operation.receivingGLN != null)
          ReceivingDetailInfoRowCopy(
            label: 'Receiving GLN',
            value: operation.receivingGLN!,
          ),
        if (receivingGlnDetails?.locationName.isNotEmpty == true)
          ReceivingDetailInfoRow(
            label: 'Receiving Facility',
            value: receivingGlnDetails!.locationName,
          ),
        if (receivingGlnDetails?.city.isNotEmpty == true)
          ReceivingDetailInfoRow(
            label: 'Receiving City',
            value: receivingGlnDetails!.city,
          ),
      ],
    );
  }
}
