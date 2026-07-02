import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/utils/return_receiving_detail_helpers.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_comments_card.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_events_card.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_location_card.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_messages_card.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_shipped_items_card.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_processing_stats_card.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_production_card.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_reference_card.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_status_banner.dart';

/// Scrollable body content for ReturnReceiving operation detail.
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
          ReturnReceivingDetailStatusBanner(operation: operation),
          const SizedBox(height: 16),
          ReturnReceivingDetailReferenceCard(operation: operation),
          ReturnReceivingDetailLocationCard(operation: operation),
          if (ReturnReceivingDetailHelpers.hasTransportDetails(operation)) ...[
            ReturnReceivingDetailProductionCard(operation: operation),
          ],
          ReturnReceivingDetailReceivedItemsCard(operation: operation),
          if (operation.eventIds != null && operation.eventIds!.isNotEmpty) ...[
            ReturnReceivingDetailEventsCard(operation: operation),
          ],
          if (operation.messages != null && operation.messages!.isNotEmpty) ...[
            ReturnReceivingDetailMessagesCard(operation: operation),
          ],
          if (operation.comments != null && operation.comments!.isNotEmpty) ...[
            ReturnReceivingDetailCommentsCard(operation: operation),
          ],
          ReturnReceivingDetailProcessingStatsCard(operation: operation),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
