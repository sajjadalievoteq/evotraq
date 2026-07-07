import 'package:traqtrace_app/features/operations/shared/utils/operation_status_utils.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_two_gln_location_card.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_shipped_items_card.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_reference_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_comments_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_events_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_messages_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_processing_stats_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_status_banner.dart';

/// Scrollable body content for shipping operation detail.
class CancelReceivingDetailBody extends StatelessWidget {
  const CancelReceivingDetailBody({
    super.key,
    required this.operation,
  });

  final CancelReceivingResponse operation;

  @override
  Widget build(BuildContext context) {
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
            title: operation.cancelReceivingReference ?? 'Cancel Receiving Operation',
            operationId: operation.cancelReceivingOperationId,
            itemCount: operation.shippedItemsCount,
          ),
          const SizedBox(height: 16),
          CancelReceivingDetailReferenceCard(operation: operation),
          OperationDetailTwoGlnLocationCard(
            cardTitle: 'Cancel Receiving Locations',
            sourceGlnLabel: 'Sender (Ship-From) GLN',
            destinationGlnLabel: 'Receive-At GLN',
            sourceGln: operation.sourceGLN ?? operation.sourceLocation?.glnCode,
            destinationGln:
                operation.receivingGLN ?? operation.receivingLocation?.glnCode,
            sourceLocationName: operation.sourceLocation?.locationName,
            sourceCity: operation.sourceLocation?.city,
            destinationLocationName: operation.receivingLocation?.locationName,
            destinationCity: operation.receivingLocation?.city,
          ),
          CancelReceivingDetailShippedItemsCard(operation: operation),
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
