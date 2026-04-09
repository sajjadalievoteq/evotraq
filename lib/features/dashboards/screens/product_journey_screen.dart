import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/dashboards/models/product_journey_models.dart';
import 'package:traqtrace_app/features/dashboards/services/product_journey_service.dart';

/// Dashboard screen showing the complete journey of a product through the supply chain
class ProductJourneyScreen extends StatefulWidget {
  final String? initialEpc;

  const ProductJourneyScreen({Key? key, this.initialEpc}) : super(key: key);

  @override
  State<ProductJourneyScreen> createState() => _ProductJourneyScreenState();
}

class _ProductJourneyScreenState extends State<ProductJourneyScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  ProductJourney? _journey;
  List<ProductSearchResult> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialEpc != null && widget.initialEpc!.isNotEmpty) {
      _searchController.text = widget.initialEpc!;
      _loadJourney(widget.initialEpc!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadJourney(String identifier) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchResults = [];
    });

    try {
      final service = getIt<ProductJourneyService>();
      final journey = await service.getJourneyByEpc(identifier);

      setState(() {
        _journey = journey;
        if (journey == null) {
          _errorMessage = 'No journey data found for this identifier';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load journey: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchProducts(String query) async {
    if (query.length < 3) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final service = getIt<ProductJourneyService>();
      final results = await service.searchProducts(query);
      setState(() => _searchResults = results);
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _selectSearchResult(ProductSearchResult result) {
    _searchController.text = result.displayName;
    setState(() => _searchResults = []);
    _loadJourney(result.identifier);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Product Journey Tracker'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_journey != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _loadJourney(_journey!.identifier),
              tooltip: 'Refresh',
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Search Section
          _buildSearchSection(),

          // Content
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Enter Serial Number, SGTIN, or SSCC...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults = [];
                          _journey = null;
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: (value) => _searchProducts(value),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _loadJourney(value);
              }
            },
          ),

          // Search Results Dropdown
          if (_searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getTypeColor(result.type),
                      child: Text(
                        result.type[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(result.displayName),
                    subtitle: Text(result.description ?? result.type),
                    onTap: () => _selectSearchResult(result),
                  );
                },
              ),
            ),

          if (_isSearching)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading product journey...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.orange[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_journey == null) {
      return _buildEmptyState();
    }

    return _buildJourneyView();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'Track Product Journey',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a serial number, SGTIN, or SSCC to view\nthe complete supply chain journey',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildHintChip('Serial Number', Icons.qr_code),
              _buildHintChip('SGTIN URI', Icons.link),
              _buildHintChip('SSCC', Icons.inventory_2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHintChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.grey[600]),
      label: Text(label),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildJourneyView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Info Card
          if (_journey!.productInfo != null) _buildProductInfoCard(),
          const SizedBox(height: 16),

          // Journey Summary Card
          _buildJourneySummaryCard(),
          const SizedBox(height: 24),

          // Timeline Header
          Row(
            children: [
              const Icon(Icons.timeline, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Journey Timeline',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              Text(
                '${_journey!.totalSteps} events',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Timeline
          _buildTimeline(),
        ],
      ),
    );
  }

  Widget _buildProductInfoCard() {
    final info = _journey!.productInfo!;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: Colors.blue,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.description ?? 'Product',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (info.gtin != null)
                        Text(
                          'GTIN: ${info.gtin}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (info.batchLotNumber != null ||
                info.manufacturingDate != null ||
                info.expiryDate != null) ...[
              const Divider(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (info.batchLotNumber != null)
                    _buildInfoTag(
                      'Batch',
                      info.batchLotNumber!,
                      Icons.batch_prediction,
                      Colors.purple,
                    ),
                  if (info.manufacturingDate != null)
                    _buildInfoTag(
                      'Mfg Date',
                      DateFormat(
                        'MMM dd, yyyy',
                      ).format(info.manufacturingDate!),
                      Icons.factory,
                      Colors.green,
                    ),
                  if (info.expiryDate != null)
                    _buildInfoTag(
                      'Expiry',
                      DateFormat('MMM dd, yyyy').format(info.expiryDate!),
                      Icons.event,
                      Colors.red,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneySummaryCard() {
    return Card(
      color: Colors.blue[50],
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(
              Icons.event_note,
              '${_journey!.totalSteps}',
              'Events',
              Colors.blue,
            ),
            _buildSummaryItem(
              Icons.location_on,
              '${_journey!.locationsVisited}',
              'Locations',
              Colors.green,
            ),
            _buildSummaryItem(
              Icons.timer,
              _formatDuration(_journey!.journeyDuration),
              'Duration',
              Colors.orange,
            ),
            _buildSummaryItem(
              Icons.check_circle,
              _journey!.currentDisposition ?? 'Active',
              'Status',
              Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildTimeline() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _journey!.steps.length,
      itemBuilder: (context, index) {
        final step = _journey!.steps[index];
        final isFirst = index == 0;
        final isLast = index == _journey!.steps.length - 1;

        return TimelineTile(
          alignment: TimelineAlign.manual,
          lineXY: 0.1,
          isFirst: isFirst,
          isLast: isLast,
          indicatorStyle: IndicatorStyle(
            width: 32,
            height: 32,
            indicator: Container(
              decoration: BoxDecoration(
                color: _getStepColor(step.businessStep),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStepIcon(step.businessStep),
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          beforeLineStyle: LineStyle(
            color: index > 0
                ? _getStepColor(
                    _journey!.steps[index - 1].businessStep,
                  ).withOpacity(0.5)
                : Colors.grey.withOpacity(0.5),
            thickness: 3,
          ),
          afterLineStyle: LineStyle(
            color: _getStepColor(step.businessStep).withOpacity(0.5),
            thickness: 3,
          ),
          endChild: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 24, top: 8),
            child: _buildTimelineCard(step, index),
          ),
        );
      },
    );
  }

  Widget _buildTimelineCard(JourneyStep step, int index) {
    final isFirst = index == 0;
    final isLast = index == _journey!.steps.length - 1;

    return Card(
      elevation: isLast ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isLast
            ? BorderSide(color: _getStepColor(step.businessStep), width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _showStepDetails(step),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStepColor(step.businessStep),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      step.businessStepLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isFirst)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'START',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (isLast)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'CURRENT',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    DateFormat('MMM dd, HH:mm').format(step.eventTime),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Location Row
              if (step.locationName != null || step.locationGLN != null)
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        step.locationName ?? step.locationGLN ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

              if (step.locationAddress != null &&
                  step.locationAddress!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    step.locationAddress!,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ),

              // Disposition
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    'Status: ${step.dispositionLabel}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  if (step.action != null) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        step.action!,
                        style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStepDetails(JourneyStep step) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getStepColor(
                            step.businessStep,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getStepIcon(step.businessStep),
                          color: _getStepColor(step.businessStep),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.businessStepLabel,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              step.eventType,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow('Event ID', step.eventId, copyable: true),
                  _buildDetailRow(
                    'Event Time',
                    DateFormat('MMM dd, yyyy HH:mm:ss').format(step.eventTime),
                  ),
                  if (step.recordTime != null)
                    _buildDetailRow(
                      'Record Time',
                      DateFormat(
                        'MMM dd, yyyy HH:mm:ss',
                      ).format(step.recordTime!),
                    ),
                  _buildDetailRow('Business Step', step.businessStep),
                  _buildDetailRow('Disposition', step.disposition),
                  if (step.action != null)
                    _buildDetailRow('Action', step.action!),
                  if (step.locationGLN != null)
                    _buildDetailRow(
                      'Location GLN',
                      step.locationGLN!,
                      copyable: true,
                    ),
                  if (step.locationName != null)
                    _buildDetailRow('Location Name', step.locationName!),
                  if (step.locationAddress != null)
                    _buildDetailRow('Address', step.locationAddress!),
                  if (step.parentId != null)
                    _buildDetailRow(
                      'Parent (SSCC)',
                      step.parentId!,
                      copyable: true,
                    ),

                  // View Event Button
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to the correct event detail page based on event type
                        final route = _getEventDetailRoute(
                          step.eventType,
                          step.eventId,
                        );
                        context.go(route);
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('View Full Event Details'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
                if (copyable)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied: $value'),
                          duration: const Duration(seconds: 1),
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

  Color _getStepColor(String businessStep) {
    final step = businessStep.toLowerCase();
    if (step.contains('commissioning')) return Colors.green;
    if (step.contains('packing')) return Colors.orange;
    if (step.contains('shipping')) return Colors.blue;
    if (step.contains('receiving')) return Colors.purple;
    if (step.contains('decommissioning')) return Colors.red;
    if (step.contains('destroying')) return Colors.red[900]!;
    if (step.contains('inspecting')) return Colors.teal;
    if (step.contains('storing')) return Colors.brown;
    if (step.contains('picking')) return Colors.indigo;
    return Colors.grey;
  }

  IconData _getStepIcon(String businessStep) {
    final step = businessStep.toLowerCase();
    if (step.contains('commissioning')) return Icons.play_for_work;
    if (step.contains('packing')) return Icons.inventory_2;
    if (step.contains('shipping')) return Icons.local_shipping;
    if (step.contains('receiving')) return Icons.move_to_inbox;
    if (step.contains('decommissioning')) return Icons.remove_circle;
    if (step.contains('destroying')) return Icons.delete_forever;
    if (step.contains('inspecting')) return Icons.search;
    if (step.contains('storing')) return Icons.warehouse;
    if (step.contains('picking')) return Icons.shopping_cart;
    return Icons.event;
  }

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'SGTIN':
        return Colors.blue;
      case 'SSCC':
        return Colors.purple;
      case 'GTIN':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return 'N/A';
    if (duration.inDays > 0) return '${duration.inDays}d';
    if (duration.inHours > 0) return '${duration.inHours}h';
    if (duration.inMinutes > 0) return '${duration.inMinutes}m';
    return '<1m';
  }

  String _getEventDetailRoute(String eventType, String eventId) {
    switch (eventType.toLowerCase()) {
      case 'objectevent':
        return '/epcis/object-events/$eventId';
      case 'aggregationevent':
        return '/epcis/aggregation-events/$eventId';
      case 'transactionevent':
        return '/epcis/transaction-events/$eventId';
      case 'transformationevent':
        return '/epcis/transformation-events/$eventId';
      default:
        return '/epcis/object-events/$eventId';
    }
  }
}
