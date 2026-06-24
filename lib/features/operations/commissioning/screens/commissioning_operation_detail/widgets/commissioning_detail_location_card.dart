import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_group_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_info_row_copy.dart';

class CommissioningDetailLocationCard extends StatelessWidget {
  const CommissioningDetailLocationCard({
    super.key,
    required this.batch,
  });

  final CommissioningBatch batch;

  @override
  Widget build(BuildContext context) {
    final gln = batch.commissioningLocationGLN;
    if (gln == null) return const SizedBox.shrink();

    return CommissioningDetailGroupCard(
      title: 'Location',
      children: [
        CommissioningDetailInfoRowCopy(label: 'Location GLN', value: gln),
      ],
    );
  }
}
