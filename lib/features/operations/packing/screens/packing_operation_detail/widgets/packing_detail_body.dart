import 'package:traqtrace_app/features/operations/shared/utils/operation_status_utils.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/utils/packing_detail_helpers.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_single_gln_location_card.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_packed_items_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_production_card.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_reference_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_comments_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_container_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_events_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_messages_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_processing_stats_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_status_banner.dart';

class PackingDetailBody extends StatelessWidget {
  const PackingDetailBody({
    super.key,
    required this.operation,
  });

  final PackingResponse operation;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(context.padding.top,context.padding.top, context.padding.top, 0),
      child: Column(

        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OperationDetailStatusBanner(
            title: operation.packingReference ?? 'Packing Operation',
            operationId: operation.packingOperationId,
            itemCount: operation.packedItemsCount,
          ),
          const SizedBox(height: 16),
          PackingDetailReferenceCard(operation: operation),

          OperationDetailContainerCard(sscc: operation.parentContainerId),

          OperationDetailSingleGlnLocationCard(
            cardTitle: 'Packing Location',
            glnLabel: 'GLN',
            gln: operation.packingLocationGLN ?? operation.operationLocation?.glnCode,
            facilityName: operation.operationLocation?.locationName,
            city: operation.operationLocation?.city,
          ),
          if (PackingDetailHelpers.hasProductionDetails(operation)) ...[

            OperationDetailProductionCard(
              title: 'Production Details',
              workOrderNumber: operation.workOrderNumber,
              batchNumber: operation.batchNumber,
              batchLabel: 'Batch Number',
              productionOrder: operation.productionOrder,
              lineLabel: 'Packing Line',
              lineValue: operation.packingLine,
            ),
          ],

          PackingDetailPackedItemsCard(operation: operation),
          if (operation.eventIds != null && operation.eventIds!.isNotEmpty) ...[

            OperationDetailEventsCard(eventIds: operation.eventIds!),
          ],
          if (operation.messages != null && operation.messages!.isNotEmpty) ...[

            OperationDetailMessagesCard(messages: operation.messages!),
          ],
          if (operation.comments != null && operation.comments!.isNotEmpty) ...[

            OperationDetailCommentsCard(comments: operation.comments!),
          ],

          OperationDetailProcessingStatsCard(
            statusLabel: OperationStatusUtils.detailLabel(operation.status),
            processingTimeMs: operation.processingTimeMs,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
