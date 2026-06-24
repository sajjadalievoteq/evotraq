import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_awaiting_selection.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_body.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_error_view.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_skeleton.dart';

/// Resolves which detail view to show based on loading/selection state.
class ShippingDetailContent extends StatelessWidget {
  const ShippingDetailContent({
    super.key,
    required this.awaitingSelection,
    required this.listLoading,
    required this.isLoading,
    required this.errorMessage,
    required this.operation,
    required this.sourceGlnDetails,
    required this.destinationGlnDetails,
    required this.showAllEpcs,
    required this.onShowAllEpcs,
    required this.onRetry,
  });

  final bool awaitingSelection;
  final bool listLoading;
  final bool isLoading;
  final String? errorMessage;
  final ShippingResponse? operation;
  final GLN? sourceGlnDetails;
  final GLN? destinationGlnDetails;
  final bool showAllEpcs;
  final VoidCallback onShowAllEpcs;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (awaitingSelection) {
      return ShippingDetailAwaitingSelection(listLoading: listLoading);
    }
    if (isLoading) return const ShippingDetailSkeleton();
    if (errorMessage != null) {
      return ShippingDetailErrorView(
        errorMessage: errorMessage!,
        onRetry: onRetry,
      );
    }
    if (operation == null) return const ShippingDetailSkeleton();

    return ShippingDetailBody(
      operation: operation!,
      sourceGlnDetails: sourceGlnDetails,
      destinationGlnDetails: destinationGlnDetails,
      showAllEpcs: showAllEpcs,
      onShowAllEpcs: onShowAllEpcs,
    );
  }
}
