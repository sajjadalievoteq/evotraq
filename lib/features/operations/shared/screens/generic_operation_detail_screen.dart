import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operation_detail_cubit.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operation_detail_state.dart';
import 'package:traqtrace_app/features/operations/shared/screens/operation_detail_screen_config.dart';

class GenericOperationDetailScreen<T> extends StatefulWidget {
  const GenericOperationDetailScreen({
    super.key,
    required this.config,
    this.operationId,
    this.embedded = false,
    this.awaitingSelection = false,
    this.listLoading = false,
  });

  final OperationDetailScreenConfig<T> config;
  final String? operationId;
  final bool embedded;
  final bool awaitingSelection;
  final bool listLoading;

  @override
  State<GenericOperationDetailScreen<T>> createState() =>
      _GenericOperationDetailScreenState<T>();
}

class _GenericOperationDetailScreenState<T>
    extends State<GenericOperationDetailScreen<T>> {
  late final OperationDetailCubit<T> _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget.config.createCubit(widget.config.fallbackErrorMessage);
    _startLoadIfNeeded();
  }

  @override
  void didUpdateWidget(GenericOperationDetailScreen<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final idChanged = oldWidget.operationId != widget.operationId;
    final selectionOpened =
        oldWidget.awaitingSelection && !widget.awaitingSelection;
    if ((idChanged || selectionOpened) &&
        widget.operationId != null &&
        !widget.awaitingSelection) {
      _startLoadIfNeeded(force: true);
    }
  }

  void _startLoadIfNeeded({bool force = false}) {
    if (widget.operationId == null || widget.awaitingSelection) return;
    if (!force && _cubit.state.isLoading) return;
    _load();
  }

  Future<void> _load() async {
    final id = widget.operationId;
    if (id == null) return;
    await _cubit.load(id);
  }

  void _onOperationUpdated(T updated) {
    _cubit.setOperation(updated);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OperationDetailCubit<T>>.value(
      value: _cubit,
      child: BlocBuilder<OperationDetailCubit<T>, OperationDetailState<T>>(
        builder: (context, detailState) {
          final content = widget.config.contentBuilder(
            context,
            awaitingSelection: widget.awaitingSelection,
            listLoading: widget.listLoading,
            isLoading: detailState.isLoading,
            errorMessage: detailState.errorMessage,
            operation: detailState.operation,
            onRetry: _load,
            onOperationUpdated: _onOperationUpdated,
          );

          if (widget.embedded) return content;

          if (detailState.isLoading &&
              detailState.operation == null &&
              detailState.errorMessage == null) {
            return Scaffold(
              appBar: TraqAppBar(context, title: const Text('Loading…')),
              drawer: widget.config.drawer,
              body: content,
            );
          }

          if (detailState.errorMessage != null) {
            return Scaffold(
              appBar: TraqAppBar(context, title: const Text('Error')),
              drawer: widget.config.drawer,
              body: content,
            );
          }

          return Scaffold(
            drawer: widget.config.drawer,
            appBar: TraqAppBar(
              context,
              leading: IconButton(
                icon: TraqIcon(AppAssets.iconChevronL),
                onPressed: () => context.go(widget.config.listRoute),
              ),
              title: Text(
                detailState.operation != null
                    ? widget.config.titleBuilder(detailState.operation as T)
                    : widget.config.defaultTitle,
              ),
              actions: [
                IconButton(
                  icon: TraqIcon(AppAssets.iconRefresh),
                  onPressed: _load,
                ),
              ],
            ),
            body: content,
          );
        },
      ),
    );
  }
}
