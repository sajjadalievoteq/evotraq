import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_awaiting_selection.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_body.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_error_view.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_skeleton.dart';

/// Resolves which detail view to show based on loading/selection state.
class PackingDetailContent extends StatelessWidget {
  const PackingDetailContent({
    super.key,
    required this.awaitingSelection,
    required this.listLoading,
    required this.isLoading,
    required this.errorMessage,
    required this.operation,
    required this.locationGlnDetails,
    required this.showAllEpcs,
    required this.onShowAllEpcs,
    required this.onRetry,
  });

  final bool awaitingSelection;
  final bool listLoading;
  final bool isLoading;
  final String? errorMessage;
  final PackingResponse? operation;
  final GLN? locationGlnDetails;
  final bool showAllEpcs;
  final VoidCallback onShowAllEpcs;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (awaitingSelection) {
      return PackingDetailAwaitingSelection(listLoading: listLoading);
    }
    if (isLoading) return const PackingDetailSkeleton();
    if (errorMessage != null) {
      return PackingDetailErrorView(
        errorMessage: errorMessage!,
        onRetry: onRetry,
      );
    }
    if (operation == null) return const PackingDetailSkeleton();

    return PackingDetailBody(
      operation: operation!,
      locationGlnDetails: locationGlnDetails,
      showAllEpcs: showAllEpcs,
      onShowAllEpcs: onShowAllEpcs,
    );
  }
}
