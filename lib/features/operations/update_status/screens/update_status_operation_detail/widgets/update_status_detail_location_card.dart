import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/text_utils.dart';
import 'package:traqtrace_app/data/models/operations/update_status/update_status_response_model.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation/utils/update_status_disposition.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row_copy.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row.dart';

class UpdateStatusDetailLocationCard extends StatelessWidget {
  const UpdateStatusDetailLocationCard({
    super.key,
    required this.operation,
  });

  final UpdateStatusResponse operation;

  @override
  Widget build(BuildContext context) {
    final locationGlnCode =
        operation.locationGLN ?? operation.operationLocation?.glnCode;

    return OperationDetailGroupCard(
      title: 'Location',
      children: [
        if (locationGlnCode != null)
          OperationDetailInfoRowCopy(
            label: 'Location GLN',
            value: locationGlnCode,
          ),
        if (operation.operationLocation?.locationName?.isNotEmpty == true)
          OperationDetailInfoRow(
            label: 'Facility',
            value: operation.operationLocation!.locationName!,
          ),
        if (operation.operationLocation?.city?.isNotEmpty == true)
          OperationDetailInfoRow(
            label: 'City',
            value: operation.operationLocation!.city!,
          ),
        if (operation.disposition != null)
          OperationDetailInfoRow(
            label: 'Status',
            value: TextUtils().capitalize(UpdateStatusDisposition.labelFor(operation.disposition)),
          ),
        if (operation.reason != null)
          OperationDetailInfoRow(
            label: 'Reason',
            value: operation.reason!,
          ),
      ],
    );
  }
}
