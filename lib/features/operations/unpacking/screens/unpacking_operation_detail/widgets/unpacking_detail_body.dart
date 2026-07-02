import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_response_model.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/utils/unpacking_detail_helpers.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_comments_card.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_container_card.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_events_card.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_location_card.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_messages_card.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_unpacked_items_card.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_processing_stats_card.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_production_card.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_reference_card.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_status_banner.dart';

/// Scrollable body content for unpacking operation detail.
class UnpackingDetailBody extends StatelessWidget {
  const UnpackingDetailBody({
    super.key,
    required this.operation,
  });

  final UnpackingResponse operation;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(context.padding.top,context.padding.top, context.padding.top, 0),
      child: Column(

        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UnpackingDetailStatusBanner(operation: operation),
          const SizedBox(height: 16),
          UnpackingDetailReferenceCard(operation: operation),

          UnpackingDetailContainerCard(operation: operation),

          UnpackingDetailLocationCard(operation: operation),
          if (UnpackingDetailHelpers.hasProductionDetails(operation)) ...[

            UnpackingDetailProductionCard(operation: operation),
          ],

          UnpackingDetailUnpackedItemsCard(operation: operation),
          if (operation.eventIds != null && operation.eventIds!.isNotEmpty) ...[

            UnpackingDetailEventsCard(operation: operation),
          ],
          if (operation.messages != null && operation.messages!.isNotEmpty) ...[

            UnpackingDetailMessagesCard(operation: operation),
          ],
          if (operation.comments != null && operation.comments!.isNotEmpty) ...[

            UnpackingDetailCommentsCard(operation: operation),
          ],

          UnpackingDetailProcessingStatsCard(operation: operation),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
