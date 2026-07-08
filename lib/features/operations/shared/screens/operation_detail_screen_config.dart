import 'package:flutter/material.dart';

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

  final Future<T> Function(String id) loader;

  final OperationDetailContentBuilder<T> contentBuilder;

  final String Function(T operation) titleBuilder;

  final String listRoute;

  final String defaultTitle;

  final String fallbackErrorMessage;

  final Widget? drawer;
}
