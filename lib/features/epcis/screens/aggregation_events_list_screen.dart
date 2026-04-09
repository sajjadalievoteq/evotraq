import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/epcis/models/aggregation_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/aggregation_events_cubit.dart';
import 'package:traqtrace_app/shared/widgets/app_loading_indicator.dart';

/// Screen for displaying a list of Aggregation Events
class AggregationEventsListScreen extends StatefulWidget {
  /// Constructor
  const AggregationEventsListScreen({Key? key}) : super(key: key);

  @override
  State<AggregationEventsListScreen> createState() => _AggregationEventsListScreenState();
}

class _AggregationEventsListScreenState extends State<AggregationEventsListScreen> {
  int _currentPage = 0;
  final int _pageSize = 10;
  
  String? _filterAction;
  String? _filterBizStep;
  String? _filterDisposition;
  String? _filterLocationGLN;
  String? _filterParentEPC;
  String? _filterChildEPC;
  DateTimeRange? _filterDateRange;
  
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    
    // Load initial data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAggregationEvents();
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<AggregationEventsCubit>().state;
      
      // Check if we can load more pages
      if (_currentPage < state.totalPages - 1 && !state.loading) {
        _currentPage++;
        _loadAggregationEvents(loadMore: true);
      }
    }
  }
  
  Future<void> _loadAggregationEvents({bool loadMore = false}) async {
    if (!loadMore) {
      _currentPage = 0;
    }
    
    final cubit = context.read<AggregationEventsCubit>();
    
    // Apply filters if any are set
    if (_filterParentEPC != null && _filterAction != null) {
      await cubit.loadAggregationEvents(
        parentEPC: _filterParentEPC,
        action: _filterAction,
        loadMore: loadMore,
      );
    } else if (_filterChildEPC != null && _filterAction != null) {
      await cubit.loadAggregationEvents(
        childEPC: _filterChildEPC,
        action: _filterAction,
        loadMore: loadMore,
      );
    } else if (_filterParentEPC != null) {
      await cubit.loadAggregationEvents(
        parentEPC: _filterParentEPC,
        loadMore: loadMore,
      );
    } else if (_filterChildEPC != null) {
      await cubit.loadAggregationEvents(
        childEPC: _filterChildEPC,
        loadMore: loadMore,
      );
    } else if (_filterAction != null) {
      await cubit.loadAggregationEvents(
        action: _filterAction,
        loadMore: loadMore,
      );
    } else if (_filterLocationGLN != null && _filterDateRange != null) {
      await cubit.loadAggregationEvents(
        locationGLN: _filterLocationGLN,
        startTime: _filterDateRange!.start,
        endTime: _filterDateRange!.end,
        loadMore: loadMore,
      );
    } else {
      // Load all aggregation events with pagination
      await cubit.loadAggregationEvents(
        page: _currentPage,
        size: _pageSize,
        loadMore: loadMore,
      );
    }
  }
  
  Future<void> _refreshData() async {
    await _loadAggregationEvents();
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? action = _filterAction;
        String? bizStep = _filterBizStep;
        String? disposition = _filterDisposition;
        String? locationGLN = _filterLocationGLN;
        String? parentEPC = _filterParentEPC;
        String? childEPC = _filterChildEPC;
        DateTimeRange? dateRange = _filterDateRange;
        
        return AlertDialog(
          title: const Text('Filter Aggregation Events'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Action',
                  ),
                  value: action,
                  items: ['ADD', 'OBSERVE', 'DELETE', null]
                      .map((a) => DropdownMenuItem(
                            value: a,
                            child: Text(a ?? 'All'),
                          ))
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
                    hintText: 'e.g. packing, shipping',
                  ),
                  onChanged: (value) {
                    bizStep = value.isNotEmpty ? value : null;
                  },
                  controller: TextEditingController(text: bizStep),
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Disposition',
                    hintText: 'e.g. in_progress, in_transit',
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
                    labelText: 'Parent EPC',
                    hintText: 'Enter parent EPC',
                  ),
                  onChanged: (value) {
                    parentEPC = value.isNotEmpty ? value : null;
                  },
                  controller: TextEditingController(text: parentEPC),
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Child EPC',
                    hintText: 'Enter child EPC',
                  ),
                  onChanged: (value) {
                    childEPC = value.isNotEmpty ? value : null;
                  },
                  controller: TextEditingController(text: childEPC),
                ),
                ListTile(
                  title: const Text('Date Range'),
                  subtitle: dateRange != null
                      ? Text(
                          '${DateFormat('yyyy-MM-dd').format(dateRange.start)} to ${DateFormat('yyyy-MM-dd').format(dateRange.end)}')
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
                  _filterParentEPC = parentEPC;
                  _filterChildEPC = childEPC;
                  _filterDateRange = dateRange;
                });
                Navigator.pop(context);
                _loadAggregationEvents();
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
                  _filterParentEPC = null;
                  _filterChildEPC = null;
                  _filterDateRange = null;
                });
                Navigator.pop(context);
                _loadAggregationEvents();
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }    void _navigateToEventDetails(AggregationEvent event) {
    // Use eventId instead of id for navigation since that's what the backend expects
    context.push('/epcis/aggregation-events/${event.eventId}', extra: event).then((result) {
      if (result == true) {
        _refreshData();
      }
    });
  }
    void _navigateToCreateEvent() {
    // Use GoRouter for consistent navigation across the app
    context.push('/epcis/aggregation-events/new').then((result) {
      if (result == true) {
        _refreshData();
      }
    });
  }
  
  /// Show a dialog with the hierarchical view of an aggregation event
  void _showHierarchyView(BuildContext context, AggregationEvent event) {
    final cubit = context.read<AggregationEventsCubit>();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Aggregation Hierarchy'),
              content: FutureBuilder(
                future: event.parentID.isNotEmpty
                    ? cubit.loadAggregationEventsByParentEPC(event.parentID).then((events) => 
                        events.expand((e) => e.childEPCs).toList())
                    : Future.value(<String>[]),
                builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return SizedBox(
                      height: 200,
                      child: Center(child: Text('Error: ${snapshot.error}')),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: Text('No hierarchy data available')),
                    );
                  } else {
                    final contents = snapshot.data!;
                    return SizedBox(
                      width: 600,
                      height: 400,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text('Parent ID: ${event.parentID}'),
                              subtitle: Text('Action: ${event.action}'),
                            ),
                            const Divider(),
                            const Text('Child EPCs:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: contents.length,
                              itemBuilder: (context, index) {
                                final childEpc = contents[index];
                                return ListTile(
                                  title: Text(childEpc),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.search),
                                    onPressed: () {
                                      // Close this dialog and search for events with this child EPC
                                      Navigator.pop(context);
                                      setState(() {
                                        _filterChildEPC = childEpc;
                                        _currentPage = 0;
                                      });
                                      _loadAggregationEvents();
                                    },
                                  ),
                                );
                              },
                            ),
                            if (event.action == 'ADD') ...[
                              const Divider(),
                              const Text('Aggregation Details:',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              ListTile(
                                title: Text(
                                    'Business Step: ${event.businessStep ?? 'Not specified'}'),
                              ),
                              ListTile(
                                title: Text(
                                    'Disposition: ${event.disposition ?? 'Not specified'}'),
                              ),
                              ListTile(
                                title: Text(
                                    'Location: ${event.businessLocation?.locationName ?? event.readPoint?.locationName ?? 'Not specified'}'),
                                subtitle: Text(
                                    'GLN: ${event.businessLocation?.glnCode ?? event.readPoint?.glnCode ?? 'Not specified'}'),
                              ),
                              ListTile(
                                title: Text(
                                    'Event Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(event.eventTime)}'),
                                subtitle: Text('Timezone: ${event.eventTimeZone}'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {    return Scaffold(
      appBar: AppBar(
        title: const Text('Aggregation Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreateEvent,
            tooltip: 'Create Aggregation Event',          ),
        ],
      ),      drawer: const AppDrawer(),
      body: BlocBuilder<AggregationEventsCubit, AggregationEventsState>(
        builder: (context, state) {
          if (state.loading && state.aggregationEvents.isEmpty) {
            return const Center(child: AppLoadingIndicator());
          }
          
          if (state.error != null && state.aggregationEvents.isEmpty) {
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
                    'Error loading aggregation events',
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
          
          if (state.aggregationEvents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_tree,
                    size: 48.0,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'No Aggregation Events Found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8.0),
                  if (_filterAction != null || _filterBizStep != null || _filterDisposition != null || _filterLocationGLN != null || _filterParentEPC != null || _filterChildEPC != null || _filterDateRange != null)
                    Text(
                      'Try adjusting your filters',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _navigateToCreateEvent,
                    child: const Text('Create Aggregation Event'),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.aggregationEvents.length + (state.loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.aggregationEvents.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: AppLoadingIndicator()),
                  );
                }
                
                final event = state.aggregationEvents[index];
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ExpansionTile(
                    title: Text(
                      'Aggregation: ${event.action}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,                      children: [
                        Text('Parent: ${event.parentID}'),
                        Text('Time: ${DateFormat.yMd().add_Hms().format(event.eventTime)}'),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [                            Text('Business Step: ${event.businessStep}'),
                            Text('Disposition: ${event.disposition}'),
                            if (event.childEPCs.isNotEmpty) ...[
                              const SizedBox(height: 8.0),
                              const Text('Child EPCs:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ...event.childEPCs.take(5).map((epc) => Text('• $epc')).toList(),
                              if (event.childEPCs.length > 5)
                                Text('... and ${event.childEPCs.length - 5} more'),
                            ],
                            const SizedBox(height: 16.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => _navigateToEventDetails(event),
                                  child: const Text('View Details'),
                                ),
                                TextButton(
                                  onPressed: () => _showHierarchyView(context, event),
                                  child: const Text('Quick View'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.push(
                                      '/epcis/aggregation-events/hierarchy/${event.parentID}',
                                      extra: {'epc': event.parentID, 'isParent': true}
                                    );
                                  },
                                  child: const Text('Full Hierarchy'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateEvent,
        tooltip: 'Create Aggregation Event',
        child: const Icon(Icons.add),
      ),
    );
  }
}
