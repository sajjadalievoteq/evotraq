import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_list/widgets/commissioning_list_item_skeleton.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_list/widgets/commissioning_operation_list_card.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_list/widgets/commissioning_operation_list_empty_view.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_list/widgets/commissioning_operation_list_error_view.dart';

class CommissioningOperationListResults extends StatelessWidget {
  const CommissioningOperationListResults({
    super.key,
    required this.isLoading,
    required this.isLoadingMore,
    required this.errorMessage,
    required this.operations,
    required this.filteredOperations,
    required this.hasActiveFilters,
    required this.embedded,
    required this.selectedBatchId,
    required this.scrollController,
    required this.onRetry,
    required this.onRefresh,
    required this.onClearFilters,
    required this.onOperationTap,
  });

  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final List<CommissioningBatch> operations;
  final List<CommissioningBatch> filteredOperations;
  final bool hasActiveFilters;
  final bool embedded;
  final String? selectedBatchId;
  final ScrollController scrollController;
  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;
  final VoidCallback onClearFilters;
  final ValueChanged<CommissioningBatch> onOperationTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return AppShimmer(
        child: ListView.builder(
          padding: EdgeInsets.all(context.horizontalPadding.left),
          itemCount: 6,
          itemBuilder: (context, _) => const CommissioningListItemSkeleton(),
        ),
      );
    }

    if (errorMessage != null) {
      return CommissioningOperationListErrorView(
        errorMessage: errorMessage!,
        onRetry: onRetry,
      );
    }

    if (filteredOperations.isEmpty && !isLoadingMore) {
      return CommissioningOperationListEmptyView(
        hasOperations: operations.isNotEmpty,
        hasActiveFilters: hasActiveFilters,
        onClearFilters: onClearFilters,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        padding: context.horizontalPadding,
        itemCount: filteredOperations.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filteredOperations.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final op = filteredOperations[index];
          return CommissioningOperationListCard(
            operation: op,
            isSelected: embedded && op.batchId == selectedBatchId,
            onTap: () => onOperationTap(op),
          );
        },
      ),
    );
  }
}
