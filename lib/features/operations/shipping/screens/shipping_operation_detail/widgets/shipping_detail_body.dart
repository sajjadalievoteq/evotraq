import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/utils/shipping_detail_helpers.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_comments_card.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_events_card.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_location_card.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_messages_card.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_shipped_items_card.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_processing_stats_card.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_production_card.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_reference_card.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_status_banner.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/pharma_return_detail_buttons.dart';

/// Scrollable body content for shipping operation detail.
class ShippingDetailBody extends StatelessWidget {
  const ShippingDetailBody({
    super.key,
    required this.operation,
    required this.sourceGlnDetails,
    required this.destinationGlnDetails,
  });

  final ShippingResponse operation;
  final GLN? sourceGlnDetails;
  final GLN? destinationGlnDetails;

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
          ShippingDetailStatusBanner(operation: operation),
          const SizedBox(height: 16),
          ShippingDetailReferenceCard(operation: operation),
          ShippingDetailLocationCard(
            operation: operation,
            sourceGlnDetails: sourceGlnDetails,
            destinationGlnDetails: destinationGlnDetails,
          ),
          if (ShippingDetailHelpers.hasTransportDetails(operation)) ...[
            ShippingDetailProductionCard(operation: operation),
          ],
          ShippingDetailShippedItemsCard(operation: operation),
          if (operation.eventIds != null && operation.eventIds!.isNotEmpty) ...[
            ShippingDetailEventsCard(operation: operation),
          ],
          if (operation.messages != null && operation.messages!.isNotEmpty) ...[
            ShippingDetailMessagesCard(operation: operation),
          ],
          if (operation.comments != null && operation.comments!.isNotEmpty) ...[
            ShippingDetailCommentsCard(operation: operation),
          ],
          ShippingDetailProcessingStatsCard(operation: operation),
          AcceptReturnButton(operation: operation),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
