import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/data/models/operations/unpacking/unpacking_response_model.dart';
import 'package:traqtrace_app/data/services/operations/unpacking/unpacking_operation_service.dart';
import 'package:traqtrace_app/features/operations/unpacking/screens/unpacking_operation_detail/widgets/unpacking_detail_content.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// Screen to display unpacking operation details.
class UnpackingOperationDetailScreen extends StatefulWidget {
  const UnpackingOperationDetailScreen({
    super.key,
    this.operationId,
    this.embedded = false,
    this.awaitingSelection = false,
    this.listLoading = false,
  });

  final String? operationId;
  final bool embedded;
  final bool awaitingSelection;
  final bool listLoading;

  @override
  State<UnpackingOperationDetailScreen> createState() =>
      _UnpackingOperationDetailScreenState();
}

class _UnpackingOperationDetailScreenState
    extends State<UnpackingOperationDetailScreen> {
  UnpackingResponse? _operation;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startLoadIfNeeded();
  }

  @override
  void didUpdateWidget(UnpackingOperationDetailScreen oldWidget) {
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
    _loadOperationDetails();
  }

  Future<void> _loadOperationDetails() async {
    final id = widget.operationId;
    if (id == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _operation = null;
    });

    try {
      final service = getIt<UnpackingOperationService>();
      final operation = await service.getUnpackingOperation(id);
      setState(() => _operation = operation);
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.getUserFriendlyMessage();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to load this unpacking operation. '
            'Check your connection and tap Retry. '
            'If the problem continues, the record may have been deleted or you may not have access to it.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = UnpackingDetailContent(
      awaitingSelection: widget.awaitingSelection,
      listLoading: widget.listLoading,
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      operation: _operation,
      onRetry: _loadOperationDetails,
    );

    if (widget.embedded) return content;

    if (_isLoading && _operation == null && _errorMessage == null) {
      return Scaffold(
        appBar: TraqAppBar(context, title: const Text('Loading…')),
        body: content,
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: TraqAppBar(context, title: const Text('Error')),
        body: content,
      );
    }

    return Scaffold(
      appBar: TraqAppBar(
        context,
        leading: IconButton(
          icon: TraqIcon(AppAssets.iconChevronL),
          onPressed: () => context.go(Constants.opUnpackingRoute),
        ),
        title: Text(_operation?.unpackingReference ?? 'Unpacking Detail'),
        actions: [
          IconButton(
            icon: TraqIcon(AppAssets.iconRefresh),
            onPressed: _loadOperationDetails,
          ),
        ],
      ),
      body: content,
    );
  }
}
