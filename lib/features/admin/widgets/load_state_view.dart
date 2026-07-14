import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/admin/widgets/dashboard_error_widget.dart';
import 'package:traqtrace_app/features/admin/widgets/load_state.dart';

/// Renders one metric group's [LoadState] independently of its siblings, so
/// a single failed/empty metric can show its own loading/error/empty state
/// without blanking the rest of the dashboard tab.
class LoadStateView<T> extends StatelessWidget {
  final LoadState<T> state;
  final Widget Function(BuildContext context, T data) builder;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final VoidCallback? onRetry;

  const LoadStateView({
    super.key,
    required this.state,
    required this.builder,
    this.loadingWidget,
    this.emptyWidget,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case LoadStatus.loading:
        return loadingWidget ?? const Center(child: CircularProgressIndicator());
      case LoadStatus.empty:
        return emptyWidget ??
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No data available', style: TextStyle(color: Colors.grey)),
              ),
            );
      case LoadStatus.error:
        return DashboardErrorWidget(
          message: state.errorMessage ?? 'An unknown error occurred',
          onRetry: onRetry,
        );
      case LoadStatus.success:
        return builder(context, state.data as T);
    }
  }
}
