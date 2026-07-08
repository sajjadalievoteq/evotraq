import 'package:traqtrace_app/features/operations/shared/utils/operation_status_utils.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/utils/receiving_detail_helpers.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_two_gln_location_card.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_shipped_items_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_transport_card.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_reference_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_comments_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_events_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_messages_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_processing_stats_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_status_banner.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/pharma_return_detail_buttons.dart';

class ReceivingDetailBody extends StatelessWidget {
  const ReceivingDetailBody({
    super.key,
    required this.operation,
    this.onOperationUpdated,
  });

  final ReceivingResponse operation;
  final ValueChanged<ReceivingResponse>? onOperationUpdated;

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
            title: operation.receivingReference ?? 'Receiving Operation',
            operationId: operation.receivingOperationId,
            itemCount: operation.processedEpcsCount,
          ),
          const SizedBox(height: 16),
          ReceivingDetailReferenceCard(operation: operation),
          OperationDetailTwoGlnLocationCard(
            cardTitle: 'Receiving Locations',
            sourceGlnLabel: 'Ship From GLN',
            destinationGlnLabel: 'Receiving GLN',
            sourceGln: operation.sourceGLN ?? operation.sourceLocation?.glnCode,
            destinationGln: ReceivingDetailHelpers.receivingGlnCode(operation),
            sourceLocationName: operation.sourceLocation?.locationName,
            sourceCity: operation.sourceLocation?.city,
            destinationLocationName: operation.receivingLocation?.locationName,
            destinationCity: operation.receivingLocation?.city,
          ),
          if (ReceivingDetailHelpers.hasTransportDetails(operation)) ...[
            OperationDetailTransportCard(
              title: 'Shipment Group Details',
              carrier: operation.carrier,
              trackingNumber: operation.trackingNumber,
              billOfLadingNumber: operation.billOfLadingNumber,
              purchaseOrderNumber: operation.purchaseOrderNumber,
              despatchAdviceNumber: operation.despatchAdviceNumber,
              receivingAdviceNumber: operation.receivingAdviceNumber,
              receivingAdviceLabel: 'Receiving Advice (RECADV)',
            ),
          ],
          ReceivingDetailReceivedItemsCard(operation: operation),
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
          AcceptGoodsButton(
            operation: operation,
            onAccepted: onOperationUpdated,
          ),
          InitiateReturnShippingButton(operation: operation),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
