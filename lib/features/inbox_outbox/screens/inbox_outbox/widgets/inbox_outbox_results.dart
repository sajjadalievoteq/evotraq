import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/data/models/inbox_outbox/inbox_outbox_list_filter.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_metadata.dart';
import 'package:traqtrace_app/features/inbox_outbox/screens/inbox_outbox/utils/inbox_outbox_empty_state_copy.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_card.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_results.dart';

class InboxOutboxResults extends StatelessWidget {
  const InboxOutboxResults({
    super.key,
    required this.scrollController,
    required this.operations,
    required this.isLoading,
    required this.errorMessage,
    required this.filter,
    required this.onRetry,
    required this.onRefresh,
    required this.onClearFilters,
    required this.emptyIconAsset,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.embedded,
    required this.selectedOperationId,
    required this.onSelectOperation,
  });

  final ScrollController scrollController;
  final List<Operation> operations;
  final bool isLoading;
  final String? errorMessage;
  final InboxOutboxListFilter filter;
  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;
  final VoidCallback onClearFilters;
  final String emptyIconAsset;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final bool embedded;
  final String? selectedOperationId;
  final ValueChanged<String>? onSelectOperation;

  @override
  Widget build(BuildContext context) {
    return OperationListResults<Operation>(
      scrollController: scrollController,
      isLoading: isLoading,
      errorMessage: errorMessage,
      operations: operations,
      filteredOperations: operations,
      hasActiveFilters: filter != InboxOutboxListFilter.all,
      onRetry: onRetry,
      onRefresh: onRefresh,
      onClearFilters: onClearFilters,
      emptyTitle: inboxOutboxEmptyTitle(filter),
      emptySubtitle: inboxOutboxEmptySubtitle(filter),
      emptyIconAsset: emptyIconAsset,
      hasMore: hasMore,
      isLoadingMore: isLoadingMore,
      onLoadMore: onLoadMore,
      itemBuilder: (context, operation) => OperationListCard(
        isInboxOutbox: true,
        operation: operation,
        isSelected: embedded &&
            operation.navigableOperationId != null &&
            operation.navigableOperationId == selectedOperationId,
        onTap: () {
          final id = operation.navigableOperationId;
          if (id == null) return;
          if (embedded && onSelectOperation != null) {
            onSelectOperation!(id);
          } else {
            context.go('${Constants.opShippingRoute}/$id');
          }
        },
      ),
    );
  }
}
