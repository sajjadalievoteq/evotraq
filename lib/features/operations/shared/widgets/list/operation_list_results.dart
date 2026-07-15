import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/empty_state/app_empty_state.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_list/gs1_list_loading_shimmer.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_card_skeleton.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/list/operation_list_error_view.dart';

class OperationListResults<T> extends StatelessWidget {
  const OperationListResults({
    super.key,
    required this.scrollController,
    required this.isLoading,
    required this.errorMessage,
    required this.operations,
    required this.filteredOperations,
    required this.hasActiveFilters,
    required this.onRetry,
    required this.onRefresh,
    required this.onClearFilters,
    required this.itemBuilder,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.emptyIconAsset,
    this.hasMore = false,
    this.isLoadingMore = false,
    required this.onLoadMore,
  });

  final ScrollController scrollController;
  final bool isLoading;
  final String? errorMessage;
  final List<T> operations;
  final List<T> filteredOperations;
  final bool hasActiveFilters;
  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;
  final VoidCallback onClearFilters;
  final Widget Function(BuildContext context, T operation) itemBuilder;
  final String emptyTitle;
  final String emptySubtitle;
  final String? emptyIconAsset;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return AppShimmer(
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(context.horizontalPadding.left,0,context.horizontalPadding.left,0),
          itemCount: 6,
          itemBuilder: (context, _) => const OperationListCardSkeleton(),
        ),
      );
    }

    if (errorMessage != null && operations.isEmpty) {
      return OperationListErrorView(
        errorMessage: errorMessage!,
        onRetry: onRetry,
      );
    }

    if (filteredOperations.isEmpty) {
      return AppEmptyState(
        iconAsset: emptyIconAsset ?? NavIcons.packaging,
        title: emptyTitle,
        subtitle: emptySubtitle,
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
        if (notification.metrics.extentAfter < 400 && hasMore && !isLoadingMore) {
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
                return itemBuilder(context, filteredOperations[index]);
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
