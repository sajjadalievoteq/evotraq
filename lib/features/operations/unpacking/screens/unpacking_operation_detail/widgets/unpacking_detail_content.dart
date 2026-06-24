import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_response_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_awaiting_selection.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_body.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_error_view.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_skeleton.dart';

/// Resolves which detail view to show based on loading/selection state.
class UnpackingDetailContent extends StatelessWidget {
  const UnpackingDetailContent({
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
  final UnpackingResponse? operation;
  final GLN? locationGlnDetails;
  final bool showAllEpcs;
  final VoidCallback onShowAllEpcs;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (awaitingSelection) {
      return UnpackingDetailAwaitingSelection(listLoading: listLoading);
    }
    if (isLoading) return const UnpackingDetailSkeleton();
    if (errorMessage != null) {
      return UnpackingDetailErrorView(
        errorMessage: errorMessage!,
        onRetry: onRetry,
      );
    }
    if (operation == null) return const UnpackingDetailSkeleton();

    return UnpackingDetailBody(
      operation: operation!,
      locationGlnDetails: locationGlnDetails,
      showAllEpcs: showAllEpcs,
      onShowAllEpcs: onShowAllEpcs,
    );
  }
}
