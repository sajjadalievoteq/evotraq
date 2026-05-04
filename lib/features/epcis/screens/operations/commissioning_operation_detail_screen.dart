import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/epcis/models/operations/commissioning_models.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:intl/intl.dart';

import 'package:traqtrace_app/data/services/commissioning_operation_service.dart';

/// Screen to display commissioning operation details
class CommissioningOperationDetailScreen extends StatefulWidget {
  final String operationId;

  const CommissioningOperationDetailScreen({
    Key? key,
    required this.operationId,
  }) : super(key: key);

  @override
  State<CommissioningOperationDetailScreen> createState() =>
      _CommissioningOperationDetailScreenState();
}

class _CommissioningOperationDetailScreenState
    extends State<CommissioningOperationDetailScreen> {
  CommissioningResponse? _operation;
  bool _isLoading = true;
  String? _errorMessage;
  GLN? _locationGLNDetails;

  @override
  void initState() {
    super.initState();
    _loadOperationDetails();
  }

  Future<void> _loadOperationDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final commissioningService = getIt<CommissioningOperationService>();
      final operation = await commissioningService.getCommissioningOperation(
        widget.operationId,
      );
      setState(() {
        _operation = operation;
      });

      // Load GLN details
      await _loadGLNDetails();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load commissioning operation: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadGLNDetails() async {
    if (_operation == null) return;

    try {
      final glnService = getIt<GLNService>();

      if (_operation!.commissioningLocationGLN != null) {
        try {
          final locationGLN = await glnService.getGLNByCode(
            _operation!.commissioningLocationGLN!,
          );
          setState(() => _locationGLNDetails = locationGLN);
        } catch (_) {
          // GLN not found in master data
        }
      }
    } catch (_) {
      // Ignore GLN lookup errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/operations/commissioning'),
        ),
        title: const Text('Commissioning Details'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadOperationDetails,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading commissioning details...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
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
            ElevatedButton(
              onPressed: _loadOperationDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_operation == null) {
      return const Center(child: Text('No commissioning operation found'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          _buildStatusCard(),
          const SizedBox(height: 16),

          // Reference Details Card
          _buildReferenceCard(),
          const SizedBox(height: 16),

          // Product Details Card
          _buildProductCard(),
          const SizedBox(height: 16),

          // Dates Card (Production, Expiry, Best Before)
          if (_hasDates()) _buildDatesCard(),
          if (_hasDates()) const SizedBox(height: 16),

          // Location Card
          _buildLocationCard(),
          const SizedBox(height: 16),

          // Processing Info Card
          _buildProcessingInfoCard(),
          const SizedBox(height: 16),

          // Commissioned Items Card
          _buildCommissionedItemsCard(),
          const SizedBox(height: 16),

          // Messages Card
          if (_operation!.messages != null && _operation!.messages!.isNotEmpty)
            _buildMessagesCard(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(_operation!.status),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(_operation!.status),
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusLabel(_operation!.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_operation!.commissionedCount ?? 0} Commissioned',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                if (_operation!.failedCount != null &&
                    _operation!.failedCount! > 0)
                  Text(
                    '${_operation!.failedCount} Failed',
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tag, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Reference Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            _buildDetailRowWithCopy(
              'Operation ID',
              _operation!.commissioningOperationId ?? 'N/A',
            ),
            if (_operation!.commissioningReference != null)
              _buildDetailRow('Reference', _operation!.commissioningReference!),
            if (_operation!.eventTime != null)
              _buildDetailRow(
                'Event Time',
                DateFormat(
                  'MMM dd, yyyy HH:mm:ss',
                ).format(_operation!.eventTime!),
              ),
            if (_operation!.processedAt != null)
              _buildDetailRow(
                'Record Time',
                DateFormat(
                  'MMM dd, yyyy HH:mm:ss',
                ).format(_operation!.processedAt!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Product Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            if (_operation!.itemDescription != null)
              _buildDetailRow('Description', _operation!.itemDescription!),
            if (_operation!.gtinCode != null)
              _buildDetailRowWithCopy('GTIN', _operation!.gtinCode!),
            if (_operation!.batchLotNumber != null)
              _buildDetailRow('Batch/Lot Number', _operation!.batchLotNumber!),
            if (_operation!.businessStep != null)
              _buildDetailRow(
                'Business Step',
                _formatBusinessStep(_operation!.businessStep!),
              ),
            if (_operation!.disposition != null)
              _buildDetailRow(
                'Disposition',
                _formatDisposition(_operation!.disposition!),
              ),
            if (_operation!.action != null)
              _buildDetailRow('Action', _operation!.action!),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Location Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            _buildGLNDetailRow(
              'Commissioning Location',
              _operation!.commissioningLocationGLN,
              _locationGLNDetails,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Processing Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            _buildDetailRow(
              'Items Commissioned',
              '${_operation!.commissionedCount ?? 0}',
            ),
            if (_operation!.failedCount != null && _operation!.failedCount! > 0)
              _buildDetailRow('Items Failed', '${_operation!.failedCount}'),
            if (_operation!.processingTimeMs != null)
              _buildDetailRow(
                'Processing Time',
                '${_operation!.processingTimeMs} ms',
              ),
            if (_operation!.eventIds != null &&
                _operation!.eventIds!.isNotEmpty)
              _buildDetailRow(
                'Events Generated',
                '${_operation!.eventIds!.length}',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommissionedItemsCard() {
    final itemCount =
        _operation!.itemResults?.length ??
        _operation!.epcList?.length ??
        _operation!.createdSgtinIds?.length ??
        0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.qr_code_2, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'Commissioned Items ($itemCount)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            if (_operation!.itemResults != null &&
                _operation!.itemResults!.isNotEmpty)
              ..._operation!.itemResults!.map(
                (item) => _buildItemResultTile(item),
              )
            else if (_operation!.epcList != null &&
                _operation!.epcList!.isNotEmpty)
              ..._operation!.epcList!.asMap().entries.map(
                (entry) => _buildEpcListTile(entry.key, entry.value),
              )
            else if (_operation!.createdSgtinIds != null &&
                _operation!.createdSgtinIds!.isNotEmpty)
              ..._operation!.createdSgtinIds!.asMap().entries.map(
                (entry) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 16,
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  title: Text(entry.value),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () => _copyToClipboard(entry.value),
                  ),
                ),
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No item details available'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEpcListTile(int index, String epcUri) {
    // Extract serial number from EPC URI
    String displaySerial = epcUri;
    if (epcUri.contains('sgtin:')) {
      final parts = epcUri.split('.');
      if (parts.length >= 3) {
        displaySerial = parts.last;
      }
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.green,
        radius: 16,
        child: Text(
          '${index + 1}',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      title: Text(displaySerial),
      subtitle: Text(
        epcUri,
        style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.copy, size: 18),
        onPressed: () => _copyToClipboard(epcUri),
      ),
    );
  }

  Widget _buildItemResultTile(CommissioningItemResult item) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: item.success ? Colors.green : Colors.red,
        radius: 16,
        child: Icon(
          item.success ? Icons.check : Icons.close,
          color: Colors.white,
          size: 16,
        ),
      ),
      title: Text(item.serialNumber),
      subtitle: item.success
          ? (item.epcUri != null
                ? Text(item.epcUri!, style: const TextStyle(fontSize: 12))
                : null)
          : Text(
              item.errorMessage ?? 'Unknown error',
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
      trailing: item.success
          ? IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () =>
                  _copyToClipboard(item.epcUri ?? item.serialNumber),
            )
          : null,
    );
  }

  Widget _buildMessagesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.message, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Messages',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            ..._operation!.messages!.map(
              (message) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(message)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasDates() {
    return _operation!.productionDate != null ||
        _operation!.expiryDate != null ||
        _operation!.bestBeforeDate != null;
  }

  Widget _buildDatesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.indigo),
                const SizedBox(width: 8),
                const Text(
                  'Dates',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            if (_operation!.productionDate != null)
              _buildDetailRow(
                'Manufacturing Date',
                DateFormat('MMM dd, yyyy').format(_operation!.productionDate!),
              ),
            if (_operation!.expiryDate != null)
              _buildDetailRow(
                'Expiry Date',
                DateFormat('MMM dd, yyyy').format(_operation!.expiryDate!),
              ),
            if (_operation!.bestBeforeDate != null)
              _buildDetailRow(
                'Best Before Date',
                DateFormat('MMM dd, yyyy').format(_operation!.bestBeforeDate!),
              ),
          ],
        ),
      ),
    );
  }

  String _formatBusinessStep(String bizStep) {
    // Format urn:epcglobal:cbv:bizstep:commissioning to just "Commissioning"
    if (bizStep.contains(':')) {
      final parts = bizStep.split(':');
      final name = parts.last;
      return name[0].toUpperCase() + name.substring(1);
    }
    return bizStep;
  }

  String _formatDisposition(String disposition) {
    // Format urn:epcglobal:cbv:disp:active to just "Active"
    if (disposition.contains(':')) {
      final parts = disposition.split(':');
      final name = parts.last;
      return name[0].toUpperCase() + name.substring(1);
    }
    return disposition;
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithCopy(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () => _copyToClipboard(value),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGLNDetailRow(String label, String? glnCode, GLN? glnDetails) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 4),
          if (glnCode != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    glnCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () => _copyToClipboard(glnCode),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            if (glnDetails != null) ...[
              const SizedBox(height: 4),
              Text(
                glnDetails.locationName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${glnDetails.addressLine1}, ${glnDetails.city}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ] else
            const Text('N/A'),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $text'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getStatusColor(CommissioningStatus? status) {
    if (status == null) return Colors.grey;
    switch (status) {
      case CommissioningStatus.success:
        return Colors.green;
      case CommissioningStatus.partialSuccess:
        return Colors.orange;
      case CommissioningStatus.failed:
        return Colors.red;
      case CommissioningStatus.validationError:
        return Colors.red[700]!;
    }
  }

  IconData _getStatusIcon(CommissioningStatus? status) {
    if (status == null) return Icons.help_outline;
    switch (status) {
      case CommissioningStatus.success:
        return Icons.check_circle;
      case CommissioningStatus.partialSuccess:
        return Icons.warning;
      case CommissioningStatus.failed:
        return Icons.error;
      case CommissioningStatus.validationError:
        return Icons.error_outline;
    }
  }

  String _getStatusLabel(CommissioningStatus? status) {
    if (status == null) return 'Unknown';
    switch (status) {
      case CommissioningStatus.success:
        return 'SUCCESS';
      case CommissioningStatus.partialSuccess:
        return 'PARTIAL';
      case CommissioningStatus.failed:
        return 'FAILED';
      case CommissioningStatus.validationError:
        return 'INVALID';
    }
  }
}
