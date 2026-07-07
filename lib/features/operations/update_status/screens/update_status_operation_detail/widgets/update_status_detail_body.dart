import 'package:traqtrace_app/features/operations/shared/utils/operation_status_utils.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/operations/update_status/update_status_response_model.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_comments_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_events_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_messages_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_processing_stats_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/detail/operation_detail_status_banner.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation_detail/widgets/update_status_detail_location_card.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation_detail/widgets/update_status_detail_updated_items_card.dart';
import 'package:traqtrace_app/features/operations/update_status/screens/update_status_operation_detail/widgets/update_status_detail_reference_card.dart';

class UpdateStatusDetailBody extends StatelessWidget {
  const UpdateStatusDetailBody({
    super.key,
    required this.operation,
  });

  final UpdateStatusResponse operation;

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
            title: operation.decommissioningReference ?? 'Update Status Operation',
            operationId: operation.decommissioningOperationId,
            itemCount: operation.itemCount,
          ),
          const SizedBox(height: 16),
          UpdateStatusDetailReferenceCard(operation: operation),
          UpdateStatusDetailLocationCard(operation: operation),
          UpdateStatusDetailUpdatedItemsCard(operation: operation),
          if (operation.eventIds != null && operation.eventIds!.isNotEmpty)
            OperationDetailEventsCard(eventIds: operation.eventIds!),
          if (operation.messages != null && operation.messages!.isNotEmpty)
            OperationDetailMessagesCard(messages: operation.messages!),
          if (operation.comments != null && operation.comments!.isNotEmpty)
            OperationDetailCommentsCard(comments: operation.comments!),
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
