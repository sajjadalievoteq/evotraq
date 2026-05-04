// ignore_for_file: unnecessary_non_null_assertion

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/epcis/cubit/shipping_operation_cubit.dart';
import 'package:traqtrace_app/features/epcis/models/operations/shipping_models.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:intl/intl.dart';

/// Screen to display shipping operation details
class ShippingOperationDetailScreen extends StatefulWidget {
  final String operationId;

  const ShippingOperationDetailScreen({Key? key, required this.operationId})
    : super(key: key);

  @override
  State<ShippingOperationDetailScreen> createState() =>
      _ShippingOperationDetailScreenState();
}

class _ShippingOperationDetailScreenState
    extends State<ShippingOperationDetailScreen> {
  GLN? _sourceGLNDetails;
  GLN? _destinationGLNDetails;

  @override
  void initState() {
    super.initState();
    context.read<ShippingOperationCubit>().getOperation(widget.operationId);
  }

  Future<void> _loadGLNDetails(ShippingResponse operation) async {
    setState(() {
      _sourceGLNDetails = null;
      _destinationGLNDetails = null;
    });

    try {
      final glnService = getIt<GLNService>();

      if (operation.sourceGLN != null) {
        try {
          final sourceGLN = await glnService.getGLNByCode(operation.sourceGLN!);
          setState(() => _sourceGLNDetails = sourceGLN);
        } catch (_) {
          // GLN not found in master data
        }
      }

      if (operation.destinationGLN != null) {
        try {
          final destGLN = await glnService.getGLNByCode(
            operation.destinationGLN!,
          );
          setState(() => _destinationGLNDetails = destGLN);
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
    return BlocListener<ShippingOperationCubit, ShippingOperationState>(
      listenWhen: (previous, current) =>
          previous.selectedOperation?.shippingOperationId !=
          current.selectedOperation?.shippingOperationId,
      listener: (context, state) {
        final operation = state.selectedOperation;
        if (operation != null) {
          _loadGLNDetails(operation);
        }
      },
      child: BlocBuilder<ShippingOperationCubit, ShippingOperationState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/operations/shipping'),
              ),
              title: const Text('Shipping Details'),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  onPressed: () => context
                      .read<ShippingOperationCubit>()
                      .getOperation(widget.operationId),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            drawer: const AppDrawer(),
            body: _buildBody(state),
          );
        },
      ),
    );
  }

  Widget _buildBody(ShippingOperationState state) {
    if (state.loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading shipping details...'),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load shipping operation: ${state.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context
                  .read<ShippingOperationCubit>()
                  .getOperation(widget.operationId),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final operation = state.selectedOperation;
    if (operation == null) {
      return const Center(child: Text('Shipping operation not found'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusHeader(operation),
          const SizedBox(height: 24),
          _buildReferenceSection(operation),
          const SizedBox(height: 24),
          _buildLocationSection(operation),
          const SizedBox(height: 24),
          _buildItemsSection(operation),
          if (operation.messages?.isNotEmpty ?? false) ...[
            const SizedBox(height: 24),
            _buildMessagesSection(operation),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusHeader(ShippingResponse operation) {
    final status = operation.status ?? ShippingStatus.failed;
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
                  Icon(_getStatusIcon(status), color: Colors.white, size: 20),
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
            if (operation.processedAt != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Processed',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    DateFormat(
                      'MMM dd, yyyy HH:mm',
                    ).format(operation.processedAt!),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceSection(ShippingResponse operation) {
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
                  'Shipping Reference',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow(
              'Reference',
              operation.shippingReference ?? 'N/A',
              copyable: true,
            ),
            _buildInfoRow(
              'Operation ID',
              operation.shippingOperationId ?? 'N/A',
              copyable: true,
            ),
            if (operation.eventIds?.isNotEmpty ?? false)
              _buildInfoRow(
                'Event ID',
                operation.eventIds!.first,
                copyable: true,
              ),
            if (operation.comments != null &&
                operation.comments!.isNotEmpty) ...[
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
                      child: Text(operation.comments!),
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

  Widget _buildLocationSection(ShippingResponse operation) {
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),

            // Source Location
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
                      Icon(Icons.flight_takeoff, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Source (From)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildGLNInfo(operation.sourceGLN, _sourceGLNDetails),
                ],
              ),
            ),

            // Arrow
            Center(
              child: Column(
                children: [
                  Icon(Icons.arrow_downward, color: Colors.grey[400], size: 32),
                  Text(
                    'SHIPPING',
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

            // Destination Location
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
                      Icon(Icons.flight_land, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Destination (To)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildGLNInfo(
                    operation.destinationGLN,
                    _destinationGLNDetails,
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
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () => _copyToClipboard(glnCode),
              tooltip: 'Copy GLN',
            ),
          ],
        ),
        if (glnDetails != null) ...[
          const SizedBox(height: 4),
          Text(
            glnDetails.locationName ?? 'Unknown Location',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          if (glnDetails.addressLine1 != null) ...[
            const SizedBox(height: 2),
            Text(
              [
                glnDetails.addressLine1,
                glnDetails.city,
                glnDetails.country,
              ].where((s) => s != null).join(', '),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
          if (glnDetails.locationType != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                glnDetails.locationType!.name.replaceAll('_', ' '),
                style: TextStyle(fontSize: 11, color: Colors.blue[800]),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildItemsSection(ShippingResponse operation) {
    final epcList = operation.epcList ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Shipped Items (${epcList.length})',
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
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No EPCs found',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: epcList.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final epc = epcList[index];
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),
                    leading: Icon(
                      Icons.qr_code_2,
                      color: Colors.purple[400],
                      size: 24,
                    ),
                    title: Text(
                      _formatEpc(epc),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      _getEpcType(epc),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () => _copyToClipboard(epc),
                      tooltip: 'Copy EPC',
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _formatEpc(String epc) {
    // Shorten long EPCs for display
    if (epc.length > 60) {
      return '${epc.substring(0, 30)}...${epc.substring(epc.length - 25)}';
    }
    return epc;
  }

  String _getEpcType(String epc) {
    if (epc.contains('sgtin')) {
      return 'SGTIN (Serialized Item)';
    } else if (epc.contains('sscc')) {
      return 'SSCC (Shipping Container)';
    } else if (epc.contains('gtin')) {
      return 'GTIN (Product)';
    } else if (epc.contains('gln')) {
      return 'GLN (Location)';
    }
    return 'EPC';
  }

  Widget _buildMetadataSection(ShippingResponse operation) {
    final metadata = operation.metadata ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Event Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            if (metadata.containsKey('event_type'))
              _buildInfoRow('Event Type', metadata['event_type'].toString()),
            if (metadata.containsKey('business_step'))
              _buildInfoRow(
                'Business Step',
                _formatBusinessStep(metadata['business_step'].toString()),
              ),
            if (metadata.containsKey('disposition'))
              _buildInfoRow(
                'Disposition',
                _formatDisposition(metadata['disposition'].toString()),
              ),
            if (metadata.containsKey('action'))
              _buildInfoRow('Action', metadata['action'].toString()),
            if (metadata.containsKey('epc_count'))
              _buildInfoRow('EPC Count', metadata['epc_count'].toString()),
            if (operation.processingTimeMs != null)
              _buildInfoRow(
                'Processing Time',
                '${operation.processingTimeMs} ms',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesSection(ShippingResponse operation) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  operation.hasErrors ? Icons.warning : Icons.message,
                  color: operation.hasErrors ? Colors.orange : Colors.blue,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Messages',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            ...(operation.messages ?? []).map(
              (message) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      operation.hasErrors
                          ? Icons.error_outline
                          : Icons.info_outline,
                      size: 18,
                      color: operation.hasErrors ? Colors.orange : Colors.blue,
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

  Widget _buildInfoRow(String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () => _copyToClipboard(value),
              tooltip: 'Copy',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.only(left: 8),
            ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getStatusColor(ShippingStatus status) {
    switch (status) {
      case ShippingStatus.success:
        return Colors.green;
      case ShippingStatus.partialSuccess:
        return Colors.orange;
      case ShippingStatus.failed:
        return Colors.red;
      case ShippingStatus.validationError:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(ShippingStatus status) {
    switch (status) {
      case ShippingStatus.success:
        return Icons.check_circle;
      case ShippingStatus.partialSuccess:
        return Icons.warning;
      case ShippingStatus.failed:
        return Icons.error;
      case ShippingStatus.validationError:
        return Icons.error_outline;
    }
  }

  String _formatBusinessStep(String step) {
    // urn:epcglobal:cbv:bizstep:shipping -> Shipping
    final parts = step.split(':');
    if (parts.isNotEmpty) {
      final lastPart = parts.last;
      return lastPart[0].toUpperCase() + lastPart.substring(1);
    }
    return step;
  }

  String _formatDisposition(String disposition) {
    // urn:epcglobal:cbv:disp:in_transit -> In Transit
    final parts = disposition.split(':');
    if (parts.isNotEmpty) {
      final lastPart = parts.last;
      return lastPart
          .split('_')
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join(' ');
    }
    return disposition;
  }
}
