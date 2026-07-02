import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_response_model.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_comments_card.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_events_card.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_location_card.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_messages_card.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_shipped_items_card.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_processing_stats_card.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_reference_card.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_status_banner.dart';

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
          CancelReceivingDetailStatusBanner(operation: operation),
          const SizedBox(height: 16),
          CancelReceivingDetailReferenceCard(operation: operation),
          CancelReceivingDetailLocationCard(operation: operation),
          CancelReceivingDetailShippedItemsCard(operation: operation),
          if (operation.eventIds != null && operation.eventIds!.isNotEmpty) ...[
            CancelReceivingDetailEventsCard(operation: operation),
          ],
          if (operation.messages != null && operation.messages!.isNotEmpty) ...[
            CancelReceivingDetailMessagesCard(operation: operation),
          ],
          if (operation.comments != null && operation.comments!.isNotEmpty) ...[
            CancelReceivingDetailCommentsCard(operation: operation),
          ],
          CancelReceivingDetailProcessingStatsCard(operation: operation),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
