import 'package:flutter/material.dart';

/// Builds the detail pane for a loaded or in-progress operation.
typedef OperationDetailContentBuilder<T> = Widget Function(
  BuildContext context, {
  required bool awaitingSelection,
  required bool listLoading,
  required bool isLoading,
  required String? errorMessage,
  required T? operation,
  required VoidCallback onRetry,
  ValueChanged<T>? onOperationUpdated,
});

/// Configuration object for [GenericOperationDetailScreen].
class OperationDetailScreenConfig<T> {
  const OperationDetailScreenConfig({
    required this.loader,
    required this.contentBuilder,
    required this.titleBuilder,
    required this.listRoute,
    required this.defaultTitle,
    required this.fallbackErrorMessage,
    this.drawer,
  });

  /// Async function that loads the operation by ID.
  final Future<T> Function(String id) loader;

  /// Builds the detail pane from loading/selection/error/data state.
  final OperationDetailContentBuilder<T> contentBuilder;

  /// Extracts the app bar title from the loaded model.
  final String Function(T operation) titleBuilder;

  /// GoRouter route to navigate back to the list screen.
  final String listRoute;

  /// App bar title shown while loading.
  final String defaultTitle;

  /// Message shown when loading fails for a non-[ApiException] reason.
  final String fallbackErrorMessage;

  /// Optional navigation drawer (e.g. commissioning standalone detail route).
  final Widget? drawer;
}
