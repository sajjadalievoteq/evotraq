import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_response_model.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/utils/return_shipping_detail_helpers.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_comments_card.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_events_card.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_location_card.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_messages_card.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_shipped_items_card.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_processing_stats_card.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_production_card.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_reference_card.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_status_banner.dart';

/// Scrollable body content for shipping operation detail.
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
          ReturnShippingDetailStatusBanner(operation: operation),
          const SizedBox(height: 16),
          ReturnShippingDetailReferenceCard(operation: operation),
          ReturnShippingDetailLocationCard(operation: operation),
          if (ReturnShippingDetailHelpers.hasTransportDetails(operation)) ...[
            ReturnShippingDetailProductionCard(operation: operation),
          ],
          ReturnShippingDetailShippedItemsCard(operation: operation),
          if (operation.eventIds != null && operation.eventIds!.isNotEmpty) ...[
            ReturnShippingDetailEventsCard(operation: operation),
          ],
          if (operation.messages != null && operation.messages!.isNotEmpty) ...[
            ReturnShippingDetailMessagesCard(operation: operation),
          ],
          if (operation.comments != null && operation.comments!.isNotEmpty) ...[
            ReturnShippingDetailCommentsCard(operation: operation),
          ],
          ReturnShippingDetailProcessingStatsCard(operation: operation),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
