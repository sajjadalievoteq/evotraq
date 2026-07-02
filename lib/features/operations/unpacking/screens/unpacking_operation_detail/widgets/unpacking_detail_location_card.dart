import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_response_model.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_info_row_copy.dart';

/// Unpacking location card for unpacking operation detail.
class UnpackingDetailLocationCard extends StatelessWidget {
  const UnpackingDetailLocationCard({
    super.key,
    required this.operation,
  });

  final UnpackingResponse operation;

  @override
  Widget build(BuildContext context) {
    final locationGlnCode =
        operation.unpackingLocationGLN ?? operation.operationLocation?.glnCode;

    return UnpackingDetailGroupCard(
      title: 'Unpacking Location',
      children: [
        if (locationGlnCode != null)
          UnpackingDetailInfoRowCopy(label: 'GLN', value: locationGlnCode),
        if (operation.operationLocation?.locationName?.isNotEmpty == true)
          UnpackingDetailInfoRow(
            label: 'Facility',
            value: operation.operationLocation!.locationName!,
          ),
        if (operation.operationLocation?.city?.isNotEmpty == true)
          UnpackingDetailInfoRow(
            label: 'City',
            value: operation.operationLocation!.city!,
          ),
      ],
    );
  }
}
