import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_info_row_copy.dart';

/// Shared location card for operations with a single operation-site GLN.
class OperationDetailSingleGlnLocationCard extends StatelessWidget {
  const OperationDetailSingleGlnLocationCard({
    super.key,
    required this.cardTitle,
    required this.gln,
    required this.glnLabel,
    this.facilityName,
    this.city,
    this.extraChildren = const [],
  });

  final String cardTitle;
  final String? gln;
  final String glnLabel;
  final String? facilityName;
  final String? city;
  final List<Widget> extraChildren;

  @override
  Widget build(BuildContext context) {
    return OperationDetailGroupCard(
      title: cardTitle,
      children: [
        if (gln != null) OperationDetailInfoRowCopy(label: glnLabel, value: gln!),
        if (facilityName?.isNotEmpty == true)
          OperationDetailInfoRow(label: 'Facility', value: facilityName!),
        if (city?.isNotEmpty == true)
          OperationDetailInfoRow(label: 'City', value: city!),
        ...extraChildren,
      ],
    );
  }
}
