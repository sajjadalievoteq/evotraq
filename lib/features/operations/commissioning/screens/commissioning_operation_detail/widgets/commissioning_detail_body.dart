import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_location_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_product_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_reference_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_serial_numbers_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/utils/commissioning_batch_status_utils.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_events_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_processing_stats_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_status_banner.dart';

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
    final itemCount = batch.totalCommissioned > 0
        ? batch.totalCommissioned
        : (batch.totalRequested > 0 ? batch.totalRequested : null);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        context.padding.top,
        context.padding.top,
        context.padding.top,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OperationDetailStatusBanner(
            title: batch.commissioningReference ?? 'Commissioning Operation',
            operationId: batch.batchId,
            itemCount: itemCount,
            itemCountLabel: 'Commissioned',
          ),
          const SizedBox(height: 16),
          CommissioningDetailReferenceCard(batch: batch),
          CommissioningDetailProductCard(batch: batch),
          CommissioningDetailLocationCard(batch: batch),
          if (items.isNotEmpty)
            CommissioningDetailSerialNumbersCard(
              items: items,
              itemStatuses: itemStatuses,
            ),
          if (batch.epcisEventId != null && batch.epcisEventId!.isNotEmpty) ...[
            OperationDetailEventsCard(eventIds: [batch.epcisEventId!]),
          ],
          OperationDetailProcessingStatsCard(
            statusLabel: CommissioningBatchStatusUtils.detailLabel(batch.status),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
