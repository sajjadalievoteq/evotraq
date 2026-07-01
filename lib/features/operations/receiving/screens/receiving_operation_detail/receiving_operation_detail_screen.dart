import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/operations/receiving/receiving_operation_service.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/features/epcis/validators/epcis_gln_validators.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_content.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// Screen to display Receiving operation details.
class ReceivingOperationDetailScreen extends StatefulWidget {
  const ReceivingOperationDetailScreen({
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
  State<ReceivingOperationDetailScreen> createState() =>
      _ReceivingOperationDetailScreenState();
}

class _ReceivingOperationDetailScreenState
    extends State<ReceivingOperationDetailScreen> {
  ReceivingResponse? _operation;
  bool _isLoading = false;
  String? _errorMessage;
  GLN? _sourceGLNDetails;
  GLN? _receivingGlnDetails;

  @override
  void initState() {
    super.initState();
    _startLoadIfNeeded();
  }

  @override
  void didUpdateWidget(ReceivingOperationDetailScreen oldWidget) {
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
    _receivingGlnDetails = null;
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
      _receivingGlnDetails = null;
    });

    try {
      final receivingService = getIt<ReceivingOperationService>();
      final operation = await receivingService.getReceivingOperation(id);
      setState(() => _operation = operation);
      await _loadGLNDetails();
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.getUserFriendlyMessage();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to load this Receiving operation. '
            'Check your connection and tap Retry. '
            'If the problem continues, the record may have been deleted or you may not have access to it.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onOperationUpdated(ReceivingResponse updated) {
    setState(() => _operation = updated);
    _loadGLNDetails();
  }

  Future<void> _loadGLNDetails() async {
    if (_operation == null) return;

    try {
      final glnService = getIt<GLNService>();
      GLN? source;
      GLN? destination;
      final sourceCode = _operation!.sourceGLN != null
          ? EpcisGlnValidators.parseGlnToCode(_operation!.sourceGLN!)
          : null;
      final receivingCode = _operation!.receivingGLN != null
          ? EpcisGlnValidators.parseGlnToCode(_operation!.receivingGLN!)
          : null;
      if (sourceCode != null && sourceCode.isNotEmpty) {
        source = await glnService.getGLNByCode(sourceCode);
      }
      if (receivingCode != null && receivingCode.isNotEmpty) {
        destination = await glnService.getGLNByCode(receivingCode);
      }
      if (mounted) {
        setState(() {
          _sourceGLNDetails = source;
          _receivingGlnDetails = destination;
        });
      }
    } catch (_) {
      // GLN not found in master data — display code only.
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = ReceivingDetailContent(
      awaitingSelection: widget.awaitingSelection,
      listLoading: widget.listLoading,
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      operation: _operation,
      sourceGlnDetails: _sourceGLNDetails,
      receivingGlnDetails: _receivingGlnDetails,
      onRetry: _loadOperationDetails,
      onOperationUpdated: _onOperationUpdated,
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
          onPressed: () => context.go(Constants.opReceivingRoute),
        ),
        title: Text(_operation?.receivingReference ?? 'Receiving Detail'),
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
