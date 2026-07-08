import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
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
  T? _operation;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
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
    if (!force && _isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    _operation = null;
    _load();
  }

  Future<void> _load() async {
    final id = widget.operationId;
    if (id == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _operation = null;
    });

    try {
      final result = await widget.config.loader(id);
      if (mounted) setState(() => _operation = result);
    } on ApiException catch (e) {
      if (mounted) setState(() => _errorMessage = e.getUserFriendlyMessage());
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = widget.config.fallbackErrorMessage);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onOperationUpdated(T updated) {
    setState(() => _operation = updated);
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.config.contentBuilder(
      context,
      awaitingSelection: widget.awaitingSelection,
      listLoading: widget.listLoading,
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      operation: _operation,
      onRetry: _load,
      onOperationUpdated: _onOperationUpdated,
    );

    if (widget.embedded) return content;

    if (_isLoading && _operation == null && _errorMessage == null) {
      return Scaffold(
        appBar: TraqAppBar(context, title: const Text('Loading…')),
        drawer: widget.config.drawer,
        body: content,
      );
    }

    if (_errorMessage != null) {
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
          _operation != null
              ? widget.config.titleBuilder(_operation as T)
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
  }
}
