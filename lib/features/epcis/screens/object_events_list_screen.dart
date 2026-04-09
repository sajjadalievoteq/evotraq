import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/epcis/models/object_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/object_events_cubit.dart';
import 'package:traqtrace_app/shared/widgets/app_loading_indicator.dart';

/// Screen for displaying a list of Object Events
class ObjectEventsListScreen extends StatefulWidget {
  /// Constructor
  const ObjectEventsListScreen({Key? key}) : super(key: key);

  @override
  State<ObjectEventsListScreen> createState() => _ObjectEventsListScreenState();
}

class _ObjectEventsListScreenState extends State<ObjectEventsListScreen> {
  int _currentPage = 0;
  final int _pageSize = 10;

  String? _filterAction;
  String? _filterBizStep;
  String? _filterDisposition;
  String? _filterLocationGLN;
  String? _filterEPC;
  DateTimeRange? _filterDateRange;

  // New Phase 3.1 features
  bool _showStatistics = false;
  Map<String, dynamic>? _eventStatistics;
  bool _showAdvancedSearch = false;

  // Selection functionality
  bool _isSelectionMode = false;
  Set<String> _selectedEventIds = <String>{};

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Load initial data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadObjectEvents();
      _loadEventStatistics(); // Load statistics on startup
    });

    // Add scroll listener for pagination
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<ObjectEventsCubit>().state;

      // Check if we can load more pages
      if (_currentPage < state.totalPages - 1 && !state.loading) {
        _currentPage++;
        _loadObjectEvents(isLoadMore: true);
      }
    }
  }

  Future<void> _loadObjectEvents({bool isLoadMore = false}) async {
    if (!isLoadMore) {
      _currentPage = 0;
    }

    final cubit = context.read<ObjectEventsCubit>();

    // Apply filters if any are set
    if (_filterEPC != null) {
      await cubit.findEventsByEPC(_filterEPC!);
    } else if (_filterBizStep != null && _filterEPC != null) {
      await cubit.findEventsByBusinessStepAndEPC(_filterBizStep!, _filterEPC!);
    } else {
      // Otherwise load paginated list
      await cubit.loadObjectEvents(
        page: _currentPage,
        size: _pageSize,
        append: isLoadMore, // Append to existing list when loading more
      );
    }
  }

  Future<void> _refreshData() async {
    await _loadObjectEvents();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? action = _filterAction;
        String? bizStep = _filterBizStep;
        String? disposition = _filterDisposition;
        String? locationGLN = _filterLocationGLN;
        String? epc = _filterEPC;
        DateTimeRange? dateRange = _filterDateRange;

        return AlertDialog(
          title: const Text('Filter Object Events'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Action'),
                  value: action,
                  items: ['ADD', 'OBSERVE', 'DELETE', null]
                      .map(
                        (a) =>
                            DropdownMenuItem(value: a, child: Text(a ?? 'All')),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == 'All') {
                      action = null;
                    } else {
                      action = value;
                    }
                  },
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Business Step',
                    hintText: 'e.g. shipping, receiving',
                  ),
                  onChanged: (value) {
                    bizStep = value.isNotEmpty ? value : null;
                  },
                  controller: TextEditingController(text: bizStep),
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Disposition',
                    hintText: 'e.g. in_transit, in_progress',
                  ),
                  onChanged: (value) {
                    disposition = value.isNotEmpty ? value : null;
                  },
                  controller: TextEditingController(text: disposition),
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Location GLN',
                    hintText: 'Enter GLN code',
                  ),
                  onChanged: (value) {
                    locationGLN = value.isNotEmpty ? value : null;
                  },
                  controller: TextEditingController(text: locationGLN),
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'EPC',
                    hintText: 'Enter EPC code',
                  ),
                  onChanged: (value) {
                    epc = value.isNotEmpty ? value : null;
                  },
                  controller: TextEditingController(text: epc),
                ),
                ListTile(
                  title: const Text('Date Range'),
                  subtitle: dateRange != null
                      ? Text(
                          '${DateFormat('yyyy-MM-dd').format(dateRange.start)} to ${DateFormat('yyyy-MM-dd').format(dateRange.end)}',
                        )
                      : const Text('No date range selected'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final result = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange: dateRange,
                    );
                    if (result != null) {
                      dateRange = result;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _filterAction = action;
                  _filterBizStep = bizStep;
                  _filterDisposition = disposition;
                  _filterLocationGLN = locationGLN;
                  _filterEPC = epc;
                  _filterDateRange = dateRange;
                });
                Navigator.pop(context);
                _loadObjectEvents();
              },
              child: const Text('Apply'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _filterAction = null;
                  _filterBizStep = null;
                  _filterDisposition = null;
                  _filterLocationGLN = null;
                  _filterEPC = null;
                  _filterDateRange = null;
                });
                Navigator.pop(context);
                _loadObjectEvents();
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToEventDetails(ObjectEvent event) {
    // Create a new clean ObjectEvent from the JSON representation
    // This ensures all nested objects are properly recreated and type-safe
    final Map<String, dynamic> eventJson = event.toJson();
    final ObjectEvent cleanEvent = ObjectEvent.fromJson(eventJson);

    // Navigate with the clean event
    context.push('/epcis/object-events/${event.id}', extra: cleanEvent).then((
      result,
    ) {
      if (result == true) {
        _refreshData();
      }
    });
  }

  void _navigateToCreateEvent() {
    // Use GoRouter for consistent navigation across the app
    // Add a brief haptic feedback to confirm the action
    HapticFeedback.mediumImpact();

    // Navigate to create event screen
    context.push('/epcis/object-events/new').then((result) {
      if (result == true) {
        _refreshData();
      }
    });
  }

  void _navigateToBatchImport() {
    // Use GoRouter for consistent navigation across the app
    // Add a brief haptic feedback to confirm the action
    HapticFeedback.mediumImpact();

    // Navigate to batch import screen
    context.push('/epcis/object-events/batch-import').then((result) {
      if (result == true) {
        _refreshData();
      }
    });
  }

  Future<void> _loadEventStatistics() async {
    try {
      final cubit = context.read<ObjectEventsCubit>();
      final stats = await cubit.getEventStatistics(
        startTime: _filterDateRange?.start,
        endTime: _filterDateRange?.end,
      );
      setState(() {
        _eventStatistics = stats;
      });
    } catch (e) {
      // Handle error silently for now
    }
  }

  void _showStatisticsDialog() {
    if (_eventStatistics == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.analytics, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Event Statistics'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Events',
                        '${_eventStatistics!['totalEvents'] ?? 0}',
                        Icons.event_note,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Recent (24h)',
                        '${_eventStatistics!['recentEvents'] ?? 0}',
                        Icons.schedule,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Actions Breakdown
                _buildStatSection(
                  'Actions Breakdown',
                  _eventStatistics!['actionCounts'] ?? {},
                  Icons.play_arrow,
                ),
                const SizedBox(height: 16),

                // Business Steps
                _buildStatSection(
                  'Business Steps',
                  _eventStatistics!['businessStepCounts'] ?? {},
                  Icons.business,
                ),
                const SizedBox(height: 16),

                // Dispositions
                _buildStatSection(
                  'Dispositions',
                  _eventStatistics!['dispositionCounts'] ?? {},
                  Icons.inventory,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadEventStatistics(); // Refresh statistics
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildStatSection(
    String title,
    Map<String, dynamic> stats,
    IconData icon,
  ) {
    if (stats.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(left: 24),
            child: Text(
              'No data available',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
        const SizedBox(height: 8),
        ...stats.entries
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _formatStatKey(entry.key),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${entry.value}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  String _formatStatKey(String key) {
    // Convert technical keys to user-friendly labels
    switch (key.toLowerCase()) {
      case 'add':
        return 'Add Events';
      case 'observe':
        return 'Observe Events';
      case 'delete':
        return 'Delete Events';
      case 'commissioning':
        return 'Commissioning';
      case 'shipping':
        return 'Shipping';
      case 'receiving':
        return 'Receiving';
      case 'packing':
        return 'Packing';
      case 'unpacking':
        return 'Unpacking';
      case 'in_transit':
        return 'In Transit';
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      default:
        return key
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (word) => word.isNotEmpty
                  ? word[0].toUpperCase() + word.substring(1)
                  : word,
            )
            .join(' ');
    }
  }

  void _showAdvancedSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advanced Search'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Search by Multiple EPCs'),
                subtitle: const Text('Find events for multiple EPC codes'),
                onTap: () => _showMultiEPCSearchDialog(),
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Search by EPC Class'),
                subtitle: const Text('Find events by product class'),
                onTap: () => _showEPCClassSearchDialog(),
              ),
              ListTile(
                leading: const Icon(Icons.inventory),
                title: const Text('Search by ILMD'),
                subtitle: const Text('Find events by item-level master data'),
                onTap: () => _showILMDSearchDialog(),
              ),
              ListTile(
                leading: const Icon(Icons.scale),
                title: const Text('Search by Quantity Range'),
                subtitle: const Text('Find events within quantity range'),
                onTap: () => _showQuantitySearchDialog(),
              ),
              ListTile(
                leading: const Icon(Icons.sensors),
                title: const Text('Events with Sensor Data'),
                subtitle: const Text(
                  'Find events containing sensor information',
                ),
                onTap: () => _searchEventsWithSensorData(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMultiEPCSearchDialog() {
    Navigator.pop(context); // Close advanced search dialog
    final TextEditingController epcsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Multiple EPCs'),
        content: TextField(
          controller: epcsController,
          decoration: const InputDecoration(
            labelText: 'EPCs (comma-separated)',
            hintText: 'Enter multiple EPC codes separated by commas',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final epcs = epcsController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();

              if (epcs.isNotEmpty) {
                Navigator.pop(context);
                final cubit = context.read<ObjectEventsCubit>();
                await cubit.findEventsByMultipleEPCs(epcs);
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showEPCClassSearchDialog() {
    Navigator.pop(context); // Close advanced search dialog
    final TextEditingController classController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search by EPC Class'),
        content: TextField(
          controller: classController,
          decoration: const InputDecoration(
            labelText: 'EPC Class',
            hintText: 'e.g., urn:epc:class:lgtin:0614141.012345.400',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (classController.text.isNotEmpty) {
                Navigator.pop(context);
                final cubit = context.read<ObjectEventsCubit>();
                await cubit.findEventsByEPCClass(classController.text);
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showILMDSearchDialog() {
    Navigator.pop(context); // Close advanced search dialog
    final TextEditingController propertyController = TextEditingController();
    final TextEditingController valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search by ILMD'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: propertyController,
              decoration: const InputDecoration(
                labelText: 'Property',
                hintText: 'e.g., lotNumber, expirationDate',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Value',
                hintText: 'Expected value for the property',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (propertyController.text.isNotEmpty &&
                  valueController.text.isNotEmpty) {
                Navigator.pop(context);
                final cubit = context.read<ObjectEventsCubit>();
                await cubit.findEventsByILMD(
                  propertyController.text,
                  valueController.text,
                );
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showQuantitySearchDialog() {
    Navigator.pop(context); // Close advanced search dialog
    final TextEditingController classController = TextEditingController();
    final TextEditingController minController = TextEditingController();
    final TextEditingController maxController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search by Quantity Range'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: classController,
              decoration: const InputDecoration(
                labelText: 'EPC Class',
                hintText: 'EPC class for quantity search',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: minController,
              decoration: const InputDecoration(
                labelText: 'Minimum Quantity',
                hintText: 'Enter minimum quantity',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: maxController,
              decoration: const InputDecoration(
                labelText: 'Maximum Quantity',
                hintText: 'Enter maximum quantity',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (classController.text.isNotEmpty &&
                  minController.text.isNotEmpty &&
                  maxController.text.isNotEmpty) {
                final minQuantity = double.tryParse(minController.text);
                final maxQuantity = double.tryParse(maxController.text);

                if (minQuantity != null && maxQuantity != null) {
                  Navigator.pop(context);
                  final cubit = context.read<ObjectEventsCubit>();
                  await cubit.findEventsByQuantity(
                    classController.text,
                    minQuantity,
                    maxQuantity,
                  );
                }
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _searchEventsWithSensorData() async {
    Navigator.pop(context); // Close advanced search dialog
    final cubit = context.read<ObjectEventsCubit>();
    await cubit.findEventsWithSensorData({});
  }

  void _showValidationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.checklist),
              title: const Text('Validate Selected Events'),
              subtitle: Text(
                _selectedEventIds.isEmpty
                    ? 'No events selected'
                    : '${_selectedEventIds.length} event(s) selected',
              ),
              onTap: _selectedEventIds.isEmpty
                  ? null
                  : () {
                      Navigator.pop(context);
                      _validateSelectedEvents();
                    },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.playlist_add_check),
              title: const Text('Validate All Events'),
              subtitle: const Text('Validate all events in the list'),
              onTap: () {
                Navigator.pop(context);
                _validateAllEvents();
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                _isSelectionMode
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
              ),
              title: Text(
                _isSelectionMode
                    ? 'Exit Selection Mode'
                    : 'Enable Selection Mode',
              ),
              subtitle: const Text(
                'Toggle selection mode to select specific events',
              ),
              onTap: () {
                setState(() {
                  _isSelectionMode = !_isSelectionMode;
                  if (!_isSelectionMode) {
                    _selectedEventIds.clear();
                  }
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _validateSelectedEvents() async {
    if (_selectedEventIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No events selected for validation')),
      );
      return;
    }

    final cubit = context.read<ObjectEventsCubit>();
    final events = cubit.state.events;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Validating ${_selectedEventIds.length} event(s)...'),
          ],
        ),
      ),
    );

    try {
      Map<String, dynamic> results = {};
      int successCount = 0;
      int failCount = 0;

      for (String eventId in _selectedEventIds) {
        final event = events.firstWhere((e) => e.id == eventId);
        try {
          final result = await cubit.validateEvent(event);
          results[eventId] = {'status': 'success', 'result': result};
          successCount++;
        } catch (e) {
          results[eventId] = {'status': 'error', 'error': e.toString()};
          failCount++;
        }
      }

      Navigator.pop(context); // Close loading dialog

      _showValidationResults(results, successCount, failCount);
    } catch (e) {
      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Validation failed: $e')));
    }
  }

  void _validateAllEvents() async {
    final cubit = context.read<ObjectEventsCubit>();
    final events = cubit.state.events;

    if (events.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No events to validate')));
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Validating ${events.length} event(s)...'),
          ],
        ),
      ),
    );

    try {
      Map<String, dynamic> results = {};
      int successCount = 0;
      int failCount = 0;

      for (ObjectEvent event in events) {
        try {
          final result = await cubit.validateEvent(event);
          results[event.id!] = {'status': 'success', 'result': result};
          successCount++;
        } catch (e) {
          results[event.id!] = {'status': 'error', 'error': e.toString()};
          failCount++;
        }
      }

      Navigator.pop(context); // Close loading dialog

      _showValidationResults(results, successCount, failCount);
    } catch (e) {
      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Validation failed: $e')));
    }
  }

  void _showValidationResults(
    Map<String, dynamic> results,
    int successCount,
    int failCount,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation Results'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          successCount.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        const Text('Success'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          failCount.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                        const Text('Failed'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          (successCount + failCount).toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('Total'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Detailed Results:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              // Detailed results list
              Expanded(
                child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final eventId = results.keys.elementAt(index);
                    final result = results[eventId];
                    final isSuccess = result['status'] == 'success';

                    return Card(
                      child: ListTile(
                        leading: Icon(
                          isSuccess ? Icons.check_circle : Icons.error,
                          color: isSuccess ? Colors.green : Colors.red,
                        ),
                        title: Text('Event: $eventId'),
                        subtitle: Text(
                          isSuccess
                              ? 'Validation successful'
                              : 'Error: ${result['error']}',
                        ),
                        isThreeLine: !isSuccess,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedEventIds.length} selected')
            : const Text('Object Events'),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedEventIds.clear();
                  });
                },
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _showStatisticsDialog,
            tooltip: 'View Statistics',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showAdvancedSearchDialog,
            tooltip: 'Advanced Search',
          ),
          IconButton(
            icon: const Icon(Icons.check_circle),
            onPressed: _showValidationDialog,
            tooltip: 'Validation Tools',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _navigateToBatchImport,
            tooltip: 'Batch Import',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreateEvent,
            tooltip: 'Create Object Event',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: GestureDetector(
        onLongPress: () {
          // Show a quick help tooltip about GS1 Object Events when long-pressed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Create GS1 EPCIS Object Event to track product movement, commissioning, or decommissioning',
              ),
              duration: Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: FloatingActionButton(
          onPressed: _navigateToCreateEvent,
          tooltip: 'Create GS1 Object Event',
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 8.0,
          // Make the FAB slightly larger for better visibility
          child: const Icon(Icons.add, size: 28.0),
        ),
      ),
      body: BlocBuilder<ObjectEventsCubit, ObjectEventsState>(
        builder: (context, state) {
          if (state.loading && state.events.isEmpty) {
            return const Center(child: AppLoadingIndicator());
          }

          if (state.error != null && state.events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48.0,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Error loading object events',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    state.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (state.events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note, size: 48.0, color: Colors.grey[400]),
                  const SizedBox(height: 16.0),
                  Text(
                    'No Object Events Found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8.0),
                  if (_filterAction != null ||
                      _filterBizStep != null ||
                      _filterDisposition != null ||
                      _filterLocationGLN != null ||
                      _filterEPC != null ||
                      _filterDateRange != null)
                    Text(
                      'Try adjusting your filters',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _navigateToCreateEvent,
                    child: const Text('Create Object Event'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.events.length + (state.loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.events.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: AppLoadingIndicator()),
                  );
                }

                final event = state.events[index];
                final isSelected = _selectedEventIds.contains(event.id);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ListTile(
                    leading: _isSelectionMode
                        ? Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedEventIds.add(event.id!);
                                } else {
                                  _selectedEventIds.remove(event.id!);
                                }
                              });
                            },
                          )
                        : null,
                    title: Text(
                      'Object Event: ${event.action}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4.0),
                        Text('Business Step: ${event.businessStep}'),
                        Text('Disposition: ${event.disposition}'),
                        Text(
                          'Time: ${DateFormat.yMd().add_Hms().format(event.eventTime)}',
                        ),
                        if (event.epcList != null && event.epcList!.isNotEmpty)
                          Text(
                            'EPCs: ${event.epcList!.take(3).join(", ")}${event.epcList!.length > 3 ? "... (${event.epcList!.length - 3} more)" : ""}',
                          ),
                        if (event.epcClass != null)
                          Text('EPC Class: ${event.epcClass}'),
                        if (event.sourceList != null &&
                            event.sourceList!.isNotEmpty)
                          Text(
                            'Sources: ${event.sourceList!.take(2).map((s) => s.type).join(", ")}${event.sourceList!.length > 2 ? "... (${event.sourceList!.length - 2} more)" : ""}',
                          ),
                        if (event.destinationList != null &&
                            event.destinationList!.isNotEmpty)
                          Text(
                            'Destinations: ${event.destinationList!.take(2).map((d) => d.type).join(", ")}${event.destinationList!.length > 2 ? "... (${event.destinationList!.length - 2} more)" : ""}',
                          ),
                      ],
                    ),
                    onTap: _isSelectionMode
                        ? () {
                            setState(() {
                              if (isSelected) {
                                _selectedEventIds.remove(event.id!);
                              } else {
                                _selectedEventIds.add(event.id!);
                              }
                            });
                          }
                        : () => _navigateToEventDetails(event),
                    trailing: _isSelectionMode
                        ? null
                        : const Icon(Icons.chevron_right),
                    selected: _isSelectionMode && isSelected,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
