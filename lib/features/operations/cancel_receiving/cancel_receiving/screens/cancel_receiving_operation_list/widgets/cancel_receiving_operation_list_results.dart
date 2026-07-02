import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_response_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_loading_shimmer.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/operation_list_item_skeleton.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/empty_list_view.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_list/widgets/cancel_receiving_operation_card.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_list/widgets/cancel_receiving_operation_list_error_view.dart';

/// List results area for shipping operation list screen.
class CancelReceivingOperationListResults extends StatelessWidget {
  const CancelReceivingOperationListResults({
    super.key,
    required this.scrollController,
    required this.isLoading,
    required this.errorMessage,
    required this.operations,
    required this.filteredOperations,
    required this.hasActiveFilters,
    required this.embedded,
    required this.selectedOperationId,
    required this.onRetry,
    required this.onRefresh,
    required this.onClearFilters,
    required this.onOperationTap,
    this.hasMore = false,
    this.isLoadingMore = false,
    required this.onLoadMore,
  });

  final ScrollController scrollController;
  final bool isLoading;
  final String? errorMessage;
  final List<CancelReceivingResponse> operations;
  final List<CancelReceivingResponse> filteredOperations;
  final bool hasActiveFilters;
  final bool embedded;
  final String? selectedOperationId;
  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;
  final VoidCallback onClearFilters;
  final ValueChanged<CancelReceivingResponse> onOperationTap;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return AppShimmer(
        child: ListView.builder(
          padding: EdgeInsets.all(context.horizontalPadding.left),
          itemCount: 6,
          itemBuilder: (context, _) => const OperationListItemSkeleton(),
        ),
      );
    }

    if (errorMessage != null) {
      return CancelReceivingOperationListErrorView(
        errorMessage: errorMessage!,
        onRetry: onRetry,
      );
    }

    if (filteredOperations.isEmpty) {
      return EmptyListView(
        iconAsset: AppAssets.iconPackage,
        title: 'No cancel receiving operations yet',
        subtitle:
            'Tap the + button to create your first cancel receiving operation.',
        filteredTitle: 'No operations match your search or filters.',
        filteredSubtitle:
            'Try a different search term, or clear your filters to see all operations.',
        hasItems: operations.isNotEmpty,
        hasActiveFilters: hasActiveFilters || operations.isNotEmpty,
        onClearFilters: onClearFilters,
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is! ScrollUpdateNotification &&
            notification is! OverscrollNotification) {
          return false;
        }

        if (notification.metrics.extentAfter < 400 &&
            hasMore &&
            !isLoadingMore) {
          onLoadMore();
        }
        return false;
      },
      child: Scrollbar(
        controller: scrollController,
        interactive: true,
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.builder(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            padding: context.horizontalPadding,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            cacheExtent: 400,
            itemCount: filteredOperations.length +
                ((hasMore && isLoadingMore) ? 1 : 0) +
                1,
            itemBuilder: (context, index) {
              if (index < filteredOperations.length) {
                final operation = filteredOperations[index];
                return CancelReceivingOperationCard(
                  operation: operation,
                  isSelected: embedded &&
                      operation.navigableOperationId != null &&
                      operation.navigableOperationId == selectedOperationId,
                  onTap: () => onOperationTap(operation),
                );
              }

              final loaderIndex = filteredOperations.length;
              final spacerIndex = filteredOperations.length +
                  ((hasMore && isLoadingMore) ? 1 : 0);

              if (index == loaderIndex && hasMore && isLoadingMore) {
                return const Gs1ListLoadMoreIndicator();
              }

              if (index == spacerIndex) {
                return const SizedBox(height: Constants.spacing);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
