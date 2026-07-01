import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/operations/decommissioning/decommissioning_response_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/widgets/decommissioning_detail_comments_card.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/widgets/decommissioning_detail_events_card.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/widgets/decommissioning_detail_location_card.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/widgets/decommissioning_detail_messages_card.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/widgets/decommissioning_detail_decommissioned_items_card.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/widgets/decommissioning_detail_processing_stats_card.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/widgets/decommissioning_detail_reference_card.dart';
import 'package:traqtrace_app/features/operations/decommissioning/screens/decommissioning_operation_detail/widgets/decommissioning_detail_status_banner.dart';

class DecommissioningDetailBody extends StatelessWidget {
  const DecommissioningDetailBody({
    super.key,
    required this.operation,
    required this.locationGlnDetails,
  });

  final DecommissioningResponse operation;
  final GLN? locationGlnDetails;

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
          DecommissioningDetailStatusBanner(operation: operation),
          const SizedBox(height: 16),
          DecommissioningDetailReferenceCard(operation: operation),
          DecommissioningDetailLocationCard(
            operation: operation,
            locationGlnDetails: locationGlnDetails,
          ),
          DecommissioningDetailDecommissionedItemsCard(operation: operation),
          if (operation.eventIds != null && operation.eventIds!.isNotEmpty)
            DecommissioningDetailEventsCard(operation: operation),
          if (operation.messages != null && operation.messages!.isNotEmpty)
            DecommissioningDetailMessagesCard(operation: operation),
          if (operation.comments != null && operation.comments!.isNotEmpty)
            DecommissioningDetailCommentsCard(operation: operation),
          DecommissioningDetailProcessingStatsCard(operation: operation),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
