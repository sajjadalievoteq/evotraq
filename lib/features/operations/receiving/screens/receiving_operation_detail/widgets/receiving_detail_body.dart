import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/utils/receiving_detail_helpers.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_comments_card.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_events_card.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_location_card.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_messages_card.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_shipped_items_card.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_processing_stats_card.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_production_card.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_reference_card.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_status_banner.dart';

/// Scrollable body content for Receiving operation detail.
class ReceivingDetailBody extends StatelessWidget {
  const ReceivingDetailBody({
    super.key,
    required this.operation,
    required this.sourceGlnDetails,
    required this.receivingGlnDetails,
    required this.showAllEpcs,
    required this.onShowAllEpcs,
  });

  final ReceivingResponse operation;
  final GLN? sourceGlnDetails;
  final GLN? receivingGlnDetails;
  final bool showAllEpcs;
  final VoidCallback onShowAllEpcs;

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
          ReceivingDetailStatusBanner(operation: operation),
          const SizedBox(height: 16),
          ReceivingDetailReferenceCard(operation: operation),
          ReceivingDetailLocationCard(
            operation: operation,
            sourceGlnDetails: sourceGlnDetails,
            receivingGlnDetails: receivingGlnDetails,
          ),
          if (ReceivingDetailHelpers.hasTransportDetails(operation)) ...[
            ReceivingDetailProductionCard(operation: operation),
          ],
          ReceivingDetailReceivedItemsCard(
            operation: operation,
            showAllEpcs: showAllEpcs,
            onShowAll: onShowAllEpcs,
          ),
          if (operation.eventIds != null && operation.eventIds!.isNotEmpty) ...[
            ReceivingDetailEventsCard(operation: operation),
          ],
          if (operation.messages != null && operation.messages!.isNotEmpty) ...[
            ReceivingDetailMessagesCard(operation: operation),
          ],
          if (operation.comments != null && operation.comments!.isNotEmpty) ...[
            ReceivingDetailCommentsCard(operation: operation),
          ],
          ReceivingDetailProcessingStatsCard(operation: operation),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
