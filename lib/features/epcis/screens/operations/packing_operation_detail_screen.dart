import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/epcis/models/operations/packing_models.dart';
import 'package:traqtrace_app/data/services/packing_operation_service.dart';
import 'package:traqtrace_app/features/gs1/models/gln_model.dart';
import 'package:traqtrace_app/data/services/gln_service.dart';
import 'package:intl/intl.dart';

/// Screen to display packing operation details
class PackingOperationDetailScreen extends StatefulWidget {
  final String operationId;

  const PackingOperationDetailScreen({Key? key, required this.operationId})
    : super(key: key);

  @override
  State<PackingOperationDetailScreen> createState() =>
      _PackingOperationDetailScreenState();
}

class _PackingOperationDetailScreenState
    extends State<PackingOperationDetailScreen> {
  PackingResponse? _operation;
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
      final packingService = getIt<PackingOperationService>();
      final operation = await packingService.getPackingOperation(
        widget.operationId,
      );
      setState(() {
        _operation = operation;
      });

      // Load GLN details
      await _loadGLNDetails();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load packing operation: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadGLNDetails() async {
    if (_operation == null) return;

    try {
      final glnService = getIt<GLNService>();

      if (_operation!.packingLocationGLN != null) {
        try {
          final locationGLN = await glnService.getGLNByCode(
            _operation!.packingLocationGLN!,
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
          onPressed: () => context.go('/operations/packing'),
        ),
        title: const Text('Packing Details'),
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
            Text('Loading packing details...'),
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
      return const Center(child: Text('No packing operation found'));
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

          // Container Details Card
          _buildContainerCard(),
          const SizedBox(height: 16),

          // Location Card
          _buildLocationCard(),
          const SizedBox(height: 16),

          // Work Order / Production Details
          if (_operation!.workOrderNumber != null ||
              _operation!.batchNumber != null ||
              _operation!.productionOrder != null ||
              _operation!.packingLine != null) ...[
            _buildProductionCard(),
            const SizedBox(height: 16),
          ],

          // Comments Card
          if (_operation!.comments != null &&
              _operation!.comments!.isNotEmpty) ...[
            _buildCommentsCard(),
            const SizedBox(height: 16),
          ],

          // Packed Items Card
          _buildPackedItemsCard(),
          const SizedBox(height: 16),

          // Processing Info Card
          _buildProcessingInfoCard(),
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
                color: _getStatusColor(
                  _operation!.status ?? PackingStatus.failed,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(_operation!.status ?? PackingStatus.failed),
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    (_operation!.status?.name ?? 'unknown').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              'ID: ${_operation!.packingOperationId ?? 'N/A'}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
            _buildDetailRow(
              'Packing Reference',
              _operation!.packingReference ?? 'N/A',
            ),
            if (_operation!.processedAt != null)
              _buildDetailRow(
                'Processed At',
                DateFormat(
                  'MMM dd, yyyy HH:mm:ss',
                ).format(_operation!.processedAt!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainerCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2, color: Colors.brown),
                const SizedBox(width: 8),
                const Text(
                  'Container Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            _buildDetailRowWithCopy(
              'Parent Container ID',
              _operation!.parentContainerId ?? 'N/A',
            ),
            _buildDetailRow(
              'Packed Items Count',
              '${_operation!.packedItemsCount ?? 0}',
            ),
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
              'Packing Location GLN',
              _operation!.packingLocationGLN,
              _locationGLNDetails,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.precision_manufacturing, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Production Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            if (_operation!.workOrderNumber != null)
              _buildDetailRow('Work Order', _operation!.workOrderNumber!),
            if (_operation!.batchNumber != null)
              _buildDetailRow('Batch Number', _operation!.batchNumber!),
            if (_operation!.productionOrder != null)
              _buildDetailRow('Production Order', _operation!.productionOrder!),
            if (_operation!.packingLine != null)
              _buildDetailRow('Packing Line', _operation!.packingLine!),
            if (_operation!.operatorId != null)
              _buildDetailRow('Operator ID', _operation!.operatorId!),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notes, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Comments / Notes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            Text(
              _operation!.comments ?? '',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackedItemsCard() {
    final items = _operation!.childEpcList ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.list_alt, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'Packed Items (${items.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No items found'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final epc = items[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.teal[100],
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.teal[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      epc,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: epc));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('EPC copied to clipboard'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  );
                },
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
                const Icon(Icons.info_outline, color: Colors.grey),
                const SizedBox(width: 8),
                const Text(
                  'Processing Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            if (_operation!.processingTimeMs != null)
              _buildDetailRow(
                'Processing Time',
                '${_operation!.processingTimeMs} ms',
              ),
            if (_operation!.eventIds != null &&
                _operation!.eventIds!.isNotEmpty)
              _buildDetailRow('Event IDs', _operation!.eventIds!.join(', ')),
            if (_operation!.messages != null &&
                _operation!.messages!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Messages:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  ..._operation!.messages!.map(
                    (msg) => Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Text('• $msg'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
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
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                if (value != 'N/A')
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 150,
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      glnCode ?? 'N/A',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (glnDetails != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        glnDetails.locationName,
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                      Text(
                        '${glnDetails.addressLine1}, ${glnDetails.city}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PackingStatus status) {
    switch (status) {
      case PackingStatus.success:
        return Colors.green;
      case PackingStatus.partialSuccess:
        return Colors.orange;
      case PackingStatus.failed:
        return Colors.red;
      case PackingStatus.validationError:
        return Colors.red[700]!;
    }
  }

  IconData _getStatusIcon(PackingStatus status) {
    switch (status) {
      case PackingStatus.success:
        return Icons.check_circle;
      case PackingStatus.partialSuccess:
        return Icons.warning;
      case PackingStatus.failed:
        return Icons.error;
      case PackingStatus.validationError:
        return Icons.error_outline;
    }
  }
}
