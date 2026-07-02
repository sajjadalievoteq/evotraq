import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_info_row_copy.dart';

/// Packing location card for packing operation detail.
class PackingDetailLocationCard extends StatelessWidget {
  const PackingDetailLocationCard({
    super.key,
    required this.operation,
  });

  final PackingResponse operation;

  @override
  Widget build(BuildContext context) {
    final locationGlnCode =
        operation.packingLocationGLN ?? operation.operationLocation?.glnCode;

    return PackingDetailGroupCard(
      title: 'Packing Location',
      children: [
        if (locationGlnCode != null)
          PackingDetailInfoRowCopy(label: 'GLN', value: locationGlnCode),
        if (operation.operationLocation?.locationName?.isNotEmpty == true)
          PackingDetailInfoRow(
            label: 'Facility',
            value: operation.operationLocation!.locationName!,
          ),
        if (operation.operationLocation?.city?.isNotEmpty == true)
          PackingDetailInfoRow(
            label: 'City',
            value: operation.operationLocation!.city!,
          ),
      ],
    );
  }
}
