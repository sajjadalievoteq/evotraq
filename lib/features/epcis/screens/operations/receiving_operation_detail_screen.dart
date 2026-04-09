import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/epcis/models/operations/receiving_models.dart';
import 'package:traqtrace_app/features/epcis/services/operations/receiving_operation_service.dart';
import 'package:traqtrace_app/features/gs1/models/gln_model.dart';
import 'package:traqtrace_app/features/gs1/services/gln_service.dart';
import 'package:intl/intl.dart';

/// Screen to display receiving operation details
class ReceivingOperationDetailScreen extends StatefulWidget {
  final String operationId;

  const ReceivingOperationDetailScreen({
    Key? key,
    required this.operationId,
  }) : super(key: key);

  @override
  State<ReceivingOperationDetailScreen> createState() =>
      _ReceivingOperationDetailScreenState();
}

class _ReceivingOperationDetailScreenState
    extends State<ReceivingOperationDetailScreen> {
  ReceivingResponse? _operation;
  bool _isLoading = true;
  String? _errorMessage;
  GLN? _receivingGLNDetails;
  GLN? _sourceGLNDetails;

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
      final receivingService = context.read<ReceivingOperationService>();
      final operation =
          await receivingService.getReceivingOperation(widget.operationId);
      setState(() {
        _operation = operation;
      });

      // Load GLN details
      await _loadGLNDetails();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load receiving operation: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadGLNDetails() async {
    if (_operation == null) return;

    try {
      final glnService = context.read<GLNService>();

      if (_operation!.receivingGLN != null) {
        try {
          final receivingGLN =
              await glnService.getGLNByCode(_operation!.receivingGLN!);
          setState(() => _receivingGLNDetails = receivingGLN);
        } catch (_) {
          // GLN not found in master data
        }
      }

      if (_operation!.sourceGLN != null) {
        try {
          final sourceGLN =
              await glnService.getGLNByCode(_operation!.sourceGLN!);
          setState(() => _sourceGLNDetails = sourceGLN);
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
          onPressed: () => context.go('/operations/receiving'),
        ),
        title: const Text('Receiving Details'),
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
            Text('Loading receiving details...'),
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
      return const Center(
        child: Text('Receiving operation not found'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusHeader(),
          const SizedBox(height: 24),
          _buildReferenceSection(),
          const SizedBox(height: 24),
          _buildLocationSection(),
          const SizedBox(height: 24),
          _buildShipmentDetailsSection(),
          const SizedBox(height: 24),
          _buildItemsSection(),
          if (_operation!.messages?.isNotEmpty ?? false) ...[
            const SizedBox(height: 24),
            _buildMessagesSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    final status = _operation!.status ?? ReceivingStatus.failed;
    final statusColor = _getStatusColor(status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(status),
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (_operation!.processedAt != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Processed',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy HH:mm')
                        .format(_operation!.processedAt!),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.confirmation_number, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Receiving Reference',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow(
              'Reference',
              _operation!.receivingReference ?? 'N/A',
              copyable: true,
            ),
            _buildInfoRow(
              'Operation ID',
              _operation!.receivingOperationId ?? 'N/A',
              copyable: true,
            ),
            if (_operation!.eventIds?.isNotEmpty ?? false)
              _buildInfoRow(
                'Event ID',
                _operation!.eventIds!.first,
                copyable: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
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
                  'Locations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),

            // Source Location (From)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flight_takeoff, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Source (From)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildGLNInfo(
                    _operation!.sourceGLN,
                    _sourceGLNDetails,
                  ),
                ],
              ),
            ),

            // Arrow
            Center(
              child: Column(
                children: [
                  Icon(Icons.arrow_downward, color: Colors.grey[400], size: 32),
                  Text(
                    'RECEIVING',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Receiving Location (To)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flight_land, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Receiving (To)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildGLNInfo(
                    _operation!.receivingGLN,
                    _receivingGLNDetails,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGLNInfo(String? glnCode, GLN? glnDetails) {
    if (glnCode == null) {
      return const Text(
        'Not specified',
        style: TextStyle(fontStyle: FontStyle.italic),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                glnCode,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: glnCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('GLN copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              tooltip: 'Copy GLN',
            ),
          ],
        ),
        if (glnDetails != null) ...[
          const SizedBox(height: 4),
          Text(
            glnDetails.locationName,
            style: const TextStyle(fontSize: 14),
          ),
          if (glnDetails.city.isNotEmpty)
            Text(
              '${glnDetails.city}, ${glnDetails.stateProvince}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildShipmentDetailsSection() {
    // Check if any shipment details are available
    final hasShipmentDetails = _operation!.purchaseOrderNumber != null ||
        _operation!.invoiceNumber != null ||
        _operation!.billOfLadingNumber != null ||
        _operation!.carrier != null ||
        _operation!.trackingNumber != null ||
        _operation!.comments != null;

    if (!hasShipmentDetails) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_shipping, color: Colors.indigo),
                const SizedBox(width: 8),
                const Text(
                  'Shipment Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            if (_operation!.purchaseOrderNumber != null)
              _buildInfoRow(
                'Purchase Order',
                _operation!.purchaseOrderNumber!,
                copyable: true,
              ),
            if (_operation!.invoiceNumber != null)
              _buildInfoRow(
                'Invoice Number',
                _operation!.invoiceNumber!,
                copyable: true,
              ),
            if (_operation!.billOfLadingNumber != null)
              _buildInfoRow(
                'Bill of Lading',
                _operation!.billOfLadingNumber!,
                copyable: true,
              ),
            if (_operation!.carrier != null)
              _buildInfoRow(
                'Carrier',
                _operation!.carrier!,
              ),
            if (_operation!.trackingNumber != null)
              _buildInfoRow(
                'Tracking Number',
                _operation!.trackingNumber!,
                copyable: true,
              ),
            if (_operation!.comments != null) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      'Notes',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(_operation!.comments!),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    final epcList = _operation!.epcList ?? [];
    final count = _operation!.processedEpcsCount ?? epcList.length;

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
                Text(
                  'Received Items ($count)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            if (epcList.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No item details available',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: epcList.length,
                itemBuilder: (context, index) {
                  final epc = epcList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            epc,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy, size: 18, color: Colors.grey[600]),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: epc));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('EPC copied to clipboard'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          tooltip: 'Copy EPC',
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.message, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Messages',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...(_operation!.messages ?? []).map((message) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(child: Text(message)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          if (copyable)
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$label copied to clipboard'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              tooltip: 'Copy $label',
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(ReceivingStatus status) {
    switch (status) {
      case ReceivingStatus.success:
        return Colors.green;
      case ReceivingStatus.partialSuccess:
        return Colors.orange;
      case ReceivingStatus.failed:
        return Colors.red;
      case ReceivingStatus.validationError:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(ReceivingStatus status) {
    switch (status) {
      case ReceivingStatus.success:
        return Icons.check_circle;
      case ReceivingStatus.partialSuccess:
        return Icons.pie_chart;
      case ReceivingStatus.failed:
        return Icons.error;
      case ReceivingStatus.validationError:
        return Icons.hourglass_empty;
    }
  }
}
