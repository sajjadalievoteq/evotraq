import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_response_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_info_row_copy.dart';

/// Unpacking location card for unpacking operation detail.
class UnpackingDetailLocationCard extends StatelessWidget {
  const UnpackingDetailLocationCard({
    super.key,
    required this.operation,
    required this.locationGlnDetails,
  });

  final UnpackingResponse operation;
  final GLN? locationGlnDetails;

  @override
  Widget build(BuildContext context) {
    return UnpackingDetailGroupCard(
      title: 'Unpacking Location',
      children: [
        if (operation.unpackingLocationGLN != null)
          UnpackingDetailInfoRowCopy(label: 'GLN', value: operation.unpackingLocationGLN!),
        if (locationGlnDetails?.locationName.isNotEmpty == true)
          UnpackingDetailInfoRow(label: 'Facility', value: locationGlnDetails!.locationName),
        if (locationGlnDetails?.city.isNotEmpty == true)
          UnpackingDetailInfoRow(label: 'City', value: locationGlnDetails!.city),
      ],
    );
  }
}
