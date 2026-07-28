import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operation_detail_cubit.dart';

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
    required this.createCubit,
    required this.contentBuilder,
    required this.titleBuilder,
    required this.listRoute,
    required this.defaultTitle,
    required this.fallbackErrorMessage,
    this.drawer,
  });

  final OperationDetailCubit<T> Function(String fallbackErrorMessage) createCubit;

  final OperationDetailContentBuilder<T> contentBuilder;

  final String Function(T operation) titleBuilder;

  final String listRoute;

  final String defaultTitle;

  final String fallbackErrorMessage;

  final Widget? drawer;
}
