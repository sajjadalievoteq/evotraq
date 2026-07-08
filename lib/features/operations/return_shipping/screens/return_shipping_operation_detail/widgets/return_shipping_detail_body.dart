import 'package:traqtrace_app/features/operations/shared/utils/operation_status_utils.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/utils/return_shipping_detail_helpers.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_two_gln_location_card.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_shipped_items_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_transport_card.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_reference_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_comments_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_events_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_messages_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_processing_stats_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_status_banner.dart';

class ReturnShippingDetailBody extends StatelessWidget {
  const ReturnShippingDetailBody({
    super.key,
    required this.operation,
  });

  final ReturnShippingResponse operation;

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
            title: operation.returnReference ?? 'Return Shipping Operation',
            operationId: operation.returnShippingOperationId,
            itemCount: operation.shippedItemsCount,
          ),
          const SizedBox(height: 16),
          ReturnShippingDetailReferenceCard(operation: operation),
          OperationDetailTwoGlnLocationCard(
            cardTitle: 'Return Shipping Locations',
            sourceGlnLabel: 'Ship From GLN',
            destinationGlnLabel: 'Ship To GLN',
            sourceGln: operation.sourceGLN ?? operation.sourceLocation?.glnCode,
            destinationGln:
                operation.destinationGLN ?? operation.destinationLocation?.glnCode,
            sourceLocationName: operation.sourceLocation?.locationName,
            sourceCity: operation.sourceLocation?.city,
            destinationLocationName: operation.destinationLocation?.locationName,
            destinationCity: operation.destinationLocation?.city,
          ),
          if (ReturnShippingDetailHelpers.hasTransportDetails(operation)) ...[
            OperationDetailTransportCard(
              title: 'Shipment Group Details',
              carrier: operation.carrier,
              trackingNumber: operation.trackingNumber,
              billOfLadingNumber: operation.billOfLadingNumber,
              purchaseOrderNumber: operation.purchaseOrderNumber,
              despatchAdviceNumber: operation.despatchAdviceNumber,
              gincNumber: operation.gincNumber,
            ),
          ],
          ReturnShippingDetailShippedItemsCard(operation: operation),
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
