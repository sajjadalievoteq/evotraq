import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_response_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/operations/cancel_receiving/cancel_receiving_operation_service.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_content.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// Screen to display shipping operation details.
class CancelReceivingOperationDetailScreen extends StatefulWidget {
  const CancelReceivingOperationDetailScreen({
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
  State<CancelReceivingOperationDetailScreen> createState() =>
      _CancelReceivingOperationDetailScreenState();
}

class _CancelReceivingOperationDetailScreenState
    extends State<CancelReceivingOperationDetailScreen> {
  CancelReceivingResponse? _operation;
  bool _isLoading = false;
  String? _errorMessage;
  GLN? _sourceGLNDetails;
  GLN? _receivingGLNDetails;

  @override
  void initState() {
    super.initState();
    _startLoadIfNeeded();
  }

  @override
  void didUpdateWidget(CancelReceivingOperationDetailScreen oldWidget) {
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
    _sourceGLNDetails = null;
    _receivingGLNDetails = null;
    _loadOperationDetails();
  }

  Future<void> _loadOperationDetails() async {
    final id = widget.operationId;
    if (id == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _operation = null;
      _sourceGLNDetails = null;
      _receivingGLNDetails = null;
    });

    try {
      final shippingService = getIt<CancelReceivingOperationService>();
      final operation = await shippingService.getCancelReceivingOperation(id);
      setState(() => _operation = operation);
      await _loadGLNDetails();
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.getUserFriendlyMessage();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to load this shipping operation. '
            'Check your connection and tap Retry. '
            'If the problem continues, the record may have been deleted or you may not have access to it.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadGLNDetails() async {
    if (_operation == null) return;

    try {
      final glnService = getIt<GLNService>();
      GLN? source;
      GLN? destination;
      if (_operation!.sourceGLN != null) {
        source = await glnService.getGLNByCode(_operation!.sourceGLN!);
      }
      if (_operation!.receivingGLN != null) {
        destination = await glnService.getGLNByCode(_operation!.receivingGLN!);
      }
      if (mounted) {
        setState(() {
          _sourceGLNDetails = source;
          _receivingGLNDetails = destination;
        });
      }
    } catch (_) {
      // GLN not found in master data — display code only.
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = CancelReceivingDetailContent(
      awaitingSelection: widget.awaitingSelection,
      listLoading: widget.listLoading,
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      operation: _operation,
      sourceGlnDetails: _sourceGLNDetails,
      receivingGlnDetails: _receivingGLNDetails,
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
          onPressed: () => context.go(Constants.opCancelReceivingRoute),
        ),
        title: Text(_operation?.cancelShippingReference ?? 'Cancel Receiving Detail'),
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
