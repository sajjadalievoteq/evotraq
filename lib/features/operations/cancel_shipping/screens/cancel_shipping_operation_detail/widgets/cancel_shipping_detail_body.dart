import 'package:traqtrace_app/features/operations/shared/utils/operation_status_utils.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_two_gln_location_card.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/widgets/cancel_shipping_detail_shipped_items_card.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/widgets/cancel_shipping_detail_reference_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_comments_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_events_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_messages_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_processing_stats_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_status_banner.dart';

class CancelShippingDetailBody extends StatelessWidget {
  const CancelShippingDetailBody({
    super.key,
    required this.operation,
  });

  final CancelShippingResponse operation;

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
            title: operation.cancelShippingReference ?? 'Cancel Shipping Operation',
            operationId: operation.cancelShippingOperationId,
            itemCount: operation.shippedItemsCount,
          ),
          const SizedBox(height: 16),
          CancelShippingDetailReferenceCard(operation: operation),
          OperationDetailTwoGlnLocationCard(
            cardTitle: 'Cancel Shipping Locations',
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
          CancelShippingDetailShippedItemsCard(operation: operation),
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
