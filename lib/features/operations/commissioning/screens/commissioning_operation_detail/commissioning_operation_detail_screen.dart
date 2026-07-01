import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sgtin/sgtin_service.dart';
import 'package:traqtrace_app/data/services/operations/commissioning/commissioning_operation_service.dart';
import 'package:traqtrace_app/features/operations/commissioning/screens/commissioning_operation_detail/widgets/commissioning_detail_content.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class CommissioningOperationDetailScreen extends StatefulWidget {
  const CommissioningOperationDetailScreen({
    super.key,
    this.batchId,
    this.operationId,
    this.embedded = false,
    this.awaitingSelection = false,
    this.listLoading = false,
  });

  final String? batchId;
  final String? operationId;
  final bool embedded;
  final bool awaitingSelection;
  final bool listLoading;

  String? get _resolvedId => batchId ?? operationId;

  @override
  State<CommissioningOperationDetailScreen> createState() =>
      _CommissioningOperationDetailScreenState();
}

class _CommissioningOperationDetailScreenState
    extends State<CommissioningOperationDetailScreen> {
  CommissioningBatch? _batch;
  List<CommissioningBatchItem> _items = [];
  Map<String, ItemStatus> _itemStatuses = {};
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (!widget.awaitingSelection && widget._resolvedId != null) {
      _load();
    }
  }

  @override
  void didUpdateWidget(CommissioningOperationDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._resolvedId != widget._resolvedId &&
        widget._resolvedId != null) {
      _load();
    }
  }

  Future<void> _load() async {
    final id = widget._resolvedId;
    if (id == null) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _batch = null;
      _items = [];
      _itemStatuses = {};
    });
    try {
      final service = getIt<CommissioningOperationService>();
      final results = await Future.wait([
        service.getBatch(id),
        service.getBatchItems(id),
      ]);
      final batch = results[0] as CommissioningBatch?;
      final items = (results[1] as List<CommissioningBatchItem>?) ?? [];
      setState(() {
        _batch = batch;
        _items = items;
      });
      // Fetch current SGTIN status for each successfully commissioned item.
      _fetchItemStatuses(items);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load operation: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchItemStatuses(List<CommissioningBatchItem> items) async {
    final sgtinService = getIt<SGTINService>();
    final successItems = items.where((i) => i.success && i.serialNumber.isNotEmpty);
    final futures = successItems.map((item) async {
      try {
        final sgtin = await sgtinService.getSGTINBySerialNumber(item.serialNumber);
        return MapEntry(item.serialNumber, sgtin.status);
      } catch (_) {
        return null;
      }
    });
    final entries = await Future.wait(futures);
    if (!mounted) return;
    setState(() {
      _itemStatuses = Map.fromEntries(
        entries.whereType<MapEntry<String, ItemStatus>>(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = CommissioningDetailContent(
      awaitingSelection: widget.awaitingSelection,
      listLoading: widget.listLoading,
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      batch: _batch,
      items: _items,
      itemStatuses: _itemStatuses,
      onRetry: _load,
    );

    if (widget.embedded) return content;

    return Scaffold(
      appBar: TraqAppBar(
        context,
        leading: IconButton(
          icon: TraqIcon(AppAssets.iconChevronL),
          onPressed: () => context.go('/operations/commissioning'),
        ),
        title: const Text('Commissioning Details'),
        actions: [
          IconButton(onPressed: _load, icon: TraqIcon(AppAssets.iconRefresh)),
        ],
      ),
      drawer: const AppDrawer(),
      body: content,
    );
  }
}
