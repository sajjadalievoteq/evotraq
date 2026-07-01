import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_location_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_processing_stats_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_product_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_reference_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_serial_numbers_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_status_banner.dart';

class CommissioningDetailBody extends StatelessWidget {
  const CommissioningDetailBody({
    super.key,
    required this.batch,
    required this.items,
    required this.itemStatuses,
  });

  final CommissioningBatch batch;
  final List<CommissioningBatchItem> items;
  final Map<String, ItemStatus> itemStatuses;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommissioningDetailStatusBanner(batch: batch),
          const SizedBox(height: 14),
          CommissioningDetailReferenceCard(batch: batch),
          const SizedBox(height: 12),
          CommissioningDetailProductCard(batch: batch),
          const SizedBox(height: 12),
          CommissioningDetailLocationCard(batch: batch),
          if (batch.commissioningLocationGLN != null)
            const SizedBox(height: 12),
          CommissioningDetailProcessingStatsCard(batch: batch),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 12),
            CommissioningDetailSerialNumbersCard(items: items, itemStatuses: itemStatuses),
          ],
        ],
      ),
    );
  }
}
