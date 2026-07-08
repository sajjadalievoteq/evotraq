import 'package:traqtrace_app/features/operations/shared/utils/operation_status_utils.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/utils/return_receiving_detail_helpers.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_two_gln_location_card.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_shipped_items_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_transport_card.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_reference_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_comments_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_events_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_messages_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_processing_stats_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_status_banner.dart';

class ReturnReceivingDetailBody extends StatelessWidget {
  const ReturnReceivingDetailBody({
    super.key,
    required this.operation,
  });

  final ReturnReceivingResponse operation;

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
            title: operation.returnReceivingReference ?? 'Return Receiving Operation',
            operationId: operation.returnReceivingOperationId,
            itemCount: operation.processedEpcsCount,
          ),
          const SizedBox(height: 16),
          ReturnReceivingDetailReferenceCard(operation: operation),
          OperationDetailTwoGlnLocationCard(
            cardTitle: 'Return Receiving Locations',
            sourceGlnLabel: 'Returned From GLN',
            destinationGlnLabel: 'Return Receiving GLN',
            sourceGln: operation.sourceGLN ?? operation.sourceLocation?.glnCode,
            destinationGln:
                operation.receivingGLN ?? operation.receivingLocation?.glnCode,
            sourceLocationName: operation.sourceLocation?.locationName,
            sourceCity: operation.sourceLocation?.city,
            destinationLocationName: operation.receivingLocation?.locationName,
            destinationCity: operation.receivingLocation?.city,
          ),
          if (ReturnReceivingDetailHelpers.hasTransportDetails(operation)) ...[
            OperationDetailTransportCard(
              title: 'Shipment Group Details',
              carrier: operation.carrier,
              trackingNumber: operation.trackingNumber,
              billOfLadingNumber: operation.billOfLadingNumber,
              purchaseOrderNumber: operation.purchaseOrderNumber,
              despatchAdviceNumber: operation.despatchAdviceNumber,
              gincNumber: operation.gincNumber,
              receivingAdviceNumber: operation.receivingAdviceNumber,
              receivingAdviceLabel: 'Return Receiving Advice (RECADV)',
            ),
          ],
          ReturnReceivingDetailReceivedItemsCard(operation: operation),
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
