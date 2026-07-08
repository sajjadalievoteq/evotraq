import 'package:traqtrace_app/features/operations/shared/utils/operation_status_utils.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_response_model.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/utils/unpacking_detail_helpers.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_single_gln_location_card.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_unpacked_items_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_production_card.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_reference_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_comments_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_container_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_events_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_messages_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_processing_stats_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_status_banner.dart';

class UnpackingDetailBody extends StatelessWidget {
  const UnpackingDetailBody({
    super.key,
    required this.operation,
  });

  final UnpackingResponse operation;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(context.padding.top,context.padding.top, context.padding.top, 0),
      child: Column(

        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OperationDetailStatusBanner(
            title: operation.unpackingReference ?? 'Unpacking Operation',
            operationId: operation.unpackingOperationId,
            itemCount: operation.unpackedItemsCount,
          ),
          const SizedBox(height: 16),
          UnpackingDetailReferenceCard(operation: operation),

          OperationDetailContainerCard(sscc: operation.parentContainerId),

          OperationDetailSingleGlnLocationCard(
            cardTitle: 'Unpacking Location',
            glnLabel: 'GLN',
            gln: operation.unpackingLocationGLN ?? operation.operationLocation?.glnCode,
            facilityName: operation.operationLocation?.locationName,
            city: operation.operationLocation?.city,
          ),
          if (UnpackingDetailHelpers.hasProductionDetails(operation)) ...[

            OperationDetailProductionCard(
              title: 'Production Details',
              workOrderNumber: operation.workOrderNumber,
              batchNumber: operation.batchNumber,
              batchLabel: 'Batch Number',
              productionOrder: operation.productionOrder,
              lineLabel: 'Unpacking Line',
              lineValue: operation.unpackingLine,
            ),
          ],

          UnpackingDetailUnpackedItemsCard(operation: operation),
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
