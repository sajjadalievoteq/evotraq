import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_response_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_info_row_copy.dart';

/// ReturnShipping location card for shipping operation detail.
class ReturnShippingDetailLocationCard extends StatelessWidget {
  const ReturnShippingDetailLocationCard({
    super.key,
    required this.operation,
    required this.sourceGlnDetails,
    required this.destinationGlnDetails,
  });

  final ReturnShippingResponse operation;
  final GLN? sourceGlnDetails;
  final GLN? destinationGlnDetails;

  @override
  Widget build(BuildContext context) {
    return ReturnShippingDetailGroupCard(
      title: 'Return Shipping Locations',
      children: [
        if (operation.sourceGLN != null)
          ReturnShippingDetailInfoRowCopy(label: 'Ship From GLN', value: operation.sourceGLN!),
        if (sourceGlnDetails?.locationName.isNotEmpty == true)
          ReturnShippingDetailInfoRow(label: 'From Facility', value: sourceGlnDetails!.locationName),
        if (sourceGlnDetails?.city.isNotEmpty == true)
          ReturnShippingDetailInfoRow(label: 'From City', value: sourceGlnDetails!.city),
        const ReturnShippingDetailInfoRow(label: 'Direction', value: 'From -> To'),
        if (operation.destinationGLN != null)
          ReturnShippingDetailInfoRowCopy(label: 'Ship To GLN', value: operation.destinationGLN!),
        if (destinationGlnDetails?.locationName.isNotEmpty == true)
          ReturnShippingDetailInfoRow(
            label: 'To Facility',
            value: destinationGlnDetails!.locationName,
          ),
        if (destinationGlnDetails?.city.isNotEmpty == true)
          ReturnShippingDetailInfoRow(label: 'To City', value: destinationGlnDetails!.city),
      ],
    );
  }
}
