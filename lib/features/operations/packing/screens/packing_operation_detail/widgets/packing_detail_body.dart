import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/utils/packing_detail_helpers.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_comments_card.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_container_card.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_events_card.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_location_card.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_messages_card.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_packed_items_card.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_processing_stats_card.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_production_card.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_reference_card.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_status_banner.dart';

/// Scrollable body content for packing operation detail.
class PackingDetailBody extends StatelessWidget {
  const PackingDetailBody({
    super.key,
    required this.operation,
    required this.locationGlnDetails,
  });

  final PackingResponse operation;
  final GLN? locationGlnDetails;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(context.padding.top,context.padding.top, context.padding.top, 0),
      child: Column(

        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PackingDetailStatusBanner(operation: operation),
          const SizedBox(height: 16),
          PackingDetailReferenceCard(operation: operation),

          PackingDetailContainerCard(operation: operation),

          PackingDetailLocationCard(
            operation: operation,
            locationGlnDetails: locationGlnDetails,
          ),
          if (PackingDetailHelpers.hasProductionDetails(operation)) ...[

            PackingDetailProductionCard(operation: operation),
          ],

          PackingDetailPackedItemsCard(operation: operation),
          if (operation.eventIds != null && operation.eventIds!.isNotEmpty) ...[

            PackingDetailEventsCard(operation: operation),
          ],
          if (operation.messages != null && operation.messages!.isNotEmpty) ...[

            PackingDetailMessagesCard(operation: operation),
          ],
          if (operation.comments != null && operation.comments!.isNotEmpty) ...[

            PackingDetailCommentsCard(operation: operation),
          ],

          PackingDetailProcessingStatsCard(operation: operation),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
