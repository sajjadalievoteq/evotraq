import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/core/widgets/traq_app_bar.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/data/services/operations/commissioning/commissioning_operation_service.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/shared/widgets/custom_button_widget.dart';

import '../../../../../core/config/app_assets.dart';

class CommissioningOperationDetailScreen extends StatefulWidget {
  final String? batchId;
  final bool embedded;

  final String? operationId;

  final bool awaitingSelection;

  final bool listLoading;

  const CommissioningOperationDetailScreen({
    Key? key,
    this.batchId,
    this.operationId,
    this.embedded = false,
    this.awaitingSelection = false,
    this.listLoading = false,
  }) : super(key: key);

  String? get _resolvedId => batchId ?? operationId;

  @override
  State<CommissioningOperationDetailScreen> createState() =>
      _CommissioningOperationDetailScreenState();
}

class _CommissioningOperationDetailScreenState
    extends State<CommissioningOperationDetailScreen> {
  CommissioningBatch? _batch;
  List<CommissioningBatchItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  static const int _initialItemDisplayCount = 50;

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
    });
    try {
      final service = getIt<CommissioningOperationService>();
      final results = await Future.wait([
        service.getBatch(id),
        service.getBatchItems(id),
      ]);
      setState(() {
        _batch = results[0] as CommissioningBatch?;
        _items = (results[1] as List<CommissioningBatchItem>?) ?? [];
      });
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load operation: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _buildContent();
    }
    return Scaffold(
      appBar: TraqAppBar(
        context,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/operations/commissioning'),
        ),
        title: const Text('Commissioning Details'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      drawer: const AppDrawer(),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (widget.awaitingSelection) {
      return widget.listLoading ? _buildSkeleton() : _buildPlaceholder();
    }
    if (_isLoading) return _buildSkeleton();
    if (_errorMessage != null) return _buildError();
    if (_batch == null) return _buildPlaceholder();
    return _buildDetail();
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.play_for_work_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Select an operation to view details',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          CustomButtonWidget(onTap: _load, title: 'Retry'),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(context.padding.left, 0, context.padding.left, context.padding.left),
        child: Column(
          children: [
            _skelBox(100),
            const SizedBox(height: 12),
            _skelBox(160),
            const SizedBox(height: 12),
            _skelBox(180),
            const SizedBox(height: 12),
            _skelBox(140),
            const SizedBox(height: 12),
            _skelBox(120),
          ],
        ),
      ),
    );
  }

  Widget _skelBox(double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppShimmer.defaultBaseColor(context),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildDetail() {
    final b = _batch!;
    return SingleChildScrollView(
      padding:context.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusBanner(b),
          const SizedBox(height: 14),

          _buildCard(
            title: 'Reference Details',
            children: [
              _rowCopy('Operation ID', b.batchId),
              if (b.commissioningReference != null)
                _row('Reference', b.commissioningReference!),
              if (b.epcisEventId != null)
                _rowCopy('EPCIS Event ID', b.epcisEventId!),
              if (b.createdAt != null)
                _row(
                  'Created At',
                  DateFormat('MMM dd, yyyy HH:mm:ss').format(b.createdAt!),
                ),
              if (b.completedAt != null)
                _row(
                  'Completed At',
                  DateFormat('MMM dd, yyyy HH:mm:ss').format(b.completedAt!),
                ),
              if (b.createdBy != null) _row('Created By', b.createdBy!),
              if (b.operatorId != null) _row('Operator ID', b.operatorId!),
            ],
          ),
          const SizedBox(height: 12),

          _buildCard(
            title: 'Product Details',
            children: [
              if (b.gtinCode != null) _rowCopy('GTIN', b.gtinCode!),
              if (b.batchLotNumber != null)
                _row('Lot / Batch Number', b.batchLotNumber!),
              if (b.productionDate != null)
                _row(
                  'Production Date',
                  DateFormat('MMM dd, yyyy').format(b.productionDate!),
                ),
              if (b.expiryDate != null)
                _row(
                  'Expiry Date',
                  DateFormat('MMM dd, yyyy').format(b.expiryDate!),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (b.commissioningLocationGLN != null) ...[
            _buildCard(
              title: 'Location',
              children: [
                _rowCopy('Location GLN', b.commissioningLocationGLN!),
              ],
            ),
            const SizedBox(height: 12),
          ],

          _buildProcessingStatsCard(b),

          if (_items.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSerialNumbersCard(),
          ],
        ],
      ),
    );
  }

  bool _showAllItems = false;

  Widget _buildSerialNumbersCard() {
    final successItems = _items.where((i) => i.success).toList();
    final failedItems = _items.where((i) => !i.success).toList();
    final displayItems = _showAllItems
        ? _items
        : _items.take(_initialItemDisplayCount).toList();

    return _buildCard(
      title: 'Serial Numbers (${_items.length})',
      children: [
        if (failedItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 14, color: Colors.green[700]),
                const SizedBox(width: 4),
                Text('${successItems.length} succeeded',
                    style: TextStyle(fontSize: 12, color: Colors.green[700])),
                const SizedBox(width: 12),
                Icon(Icons.cancel, size: 14, color: Colors.red[700]),
                const SizedBox(width: 4),
                Text('${failedItems.length} failed',
                    style: TextStyle(fontSize: 12, color: Colors.red[700])),
              ],
            ),
          ),
        ...displayItems.map((item) => _buildItemRow(item)),
        if (!_showAllItems && _items.length > _initialItemDisplayCount)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: () => setState(() => _showAllItems = true),
              icon: const Icon(Icons.expand_more, size: 18),
              label: Text(
                'Show all ${_items.length} items',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildItemRow(CommissioningBatchItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            item.success ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: item.success ? Colors.green[600] : Colors.red[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.serialNumber,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.epcUri != null)
                  Text(
                    item.epcUri!,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    overflow: TextOverflow.ellipsis,
                  ),
                if (!item.success && item.errorMessage != null)
                  Text(
                    item.errorMessage!,
                    style: TextStyle(fontSize: 11, color: Colors.red[600]),
                  ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: item.serialNumber));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied: ${item.serialNumber}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.copy, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(CommissioningBatch b) {
    final statusColor = _statusColor(b.status);
    return Card(
      elevation: 2,

      color: context.colors.surface,
      child: DecoratedBox(
          decoration: BoxDecoration(
              color: context.colors.primary,
              image: DecorationImage(
                image: AssetImage(AppAssets.traqBackgroundPng),
                fit: BoxFit.cover,
                opacity: 0.2,
              )),

        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
            Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(b.status), color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _statusLabel(b.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _countBadge(
                      '${b.totalCommissioned} Commissioned',
                      Colors.green,
                      Icons.check_circle,
                    ),
                    if (b.totalFailed > 0) ...[
                      const SizedBox(height: 4),
                      _countBadge(
                        '${b.totalFailed} Failed',
                        Colors.red,
                        Icons.error,
                      ),
                    ],
                    if (b.totalRequested > 0) ...[
                      const SizedBox(height: 4),
                      _countBadge(
                        '${b.totalRequested} Requested',
                        Colors.grey,
                        Icons.pending,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),]
        ),
      )
    );
  }

  Widget _countBadge(String text, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingStatsCard(CommissioningBatch b) {
    final total = b.totalRequested > 0
        ? b.totalRequested
        : b.totalCommissioned + b.totalFailed;
    final successRate = total > 0 ? b.totalCommissioned / total : 0.0;

    return _buildCard(
      title: 'Processing Stats',
      children: [
        _row('Total Requested', '$total'),
        _row('Total Commissioned', '${b.totalCommissioned}'),
        if (b.totalFailed > 0)
          _row('Total Failed', '${b.totalFailed}',
              valueColor: Colors.red[700]),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(
                'Success Rate',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: successRate.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.red[100],
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(successRate * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required List<Widget> children,
  }) {
    return Gs1GroupCard(
      title: title,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SgtinInfoRow(label, value, valueColor: valueColor),
    );
  }

  Widget _rowCopy(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SgtinInfoRow(label, value, monospace: true),
          ),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied: $value'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.copy, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(CommissioningBatchStatus s) {
    switch (s) {
      case CommissioningBatchStatus.success:
        return Colors.green;
      case CommissioningBatchStatus.partialSuccess:
        return Colors.orange;
      case CommissioningBatchStatus.failed:
        return Colors.red;
      case CommissioningBatchStatus.pending:
        return Colors.blue;
      case CommissioningBatchStatus.inProgress:
        return Colors.teal;
    }
  }

  IconData _statusIcon(CommissioningBatchStatus s) {
    switch (s) {
      case CommissioningBatchStatus.success:
        return Icons.check_circle;
      case CommissioningBatchStatus.partialSuccess:
        return Icons.warning;
      case CommissioningBatchStatus.failed:
        return Icons.error;
      case CommissioningBatchStatus.pending:
        return Icons.schedule;
      case CommissioningBatchStatus.inProgress:
        return Icons.sync;
    }
  }

  String _statusLabel(CommissioningBatchStatus s) {
    switch (s) {
      case CommissioningBatchStatus.success:
        return 'SUCCESS';
      case CommissioningBatchStatus.partialSuccess:
        return 'PARTIAL SUCCESS';
      case CommissioningBatchStatus.failed:
        return 'FAILED';
      case CommissioningBatchStatus.pending:
        return 'PENDING';
      case CommissioningBatchStatus.inProgress:
        return 'IN PROGRESS';
    }
  }
}
