import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/epcis/models/aggregation_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/aggregation_events_cubit.dart';
import 'package:traqtrace_app/shared/widgets/app_loading_indicator.dart';
import 'package:intl/intl.dart';

/// Screen for viewing and verifying the hierarchical relationship 
/// of aggregation events for a specific EPC
class AggregationEventHierarchyScreen extends StatefulWidget {
  /// The EPC to view hierarchy for (could be a parent or child EPC)
  final String epc;
  
  /// Whether this EPC is a parent or child
  final bool isParent;
  
  /// Constructor
  const AggregationEventHierarchyScreen({
    Key? key, 
    required this.epc,
    this.isParent = true,
  }) : super(key: key);

  @override
  State<AggregationEventHierarchyScreen> createState() => _AggregationEventHierarchyScreenState();
}

class _AggregationEventHierarchyScreenState extends State<AggregationEventHierarchyScreen> {
  bool _loading = false;
  String? _error;
  List<String> _hierarchyContents = [];
  List<AggregationEvent> _historyEvents = [];
  bool _isVerified = false;
  bool _isVerifying = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }
  
  Future<void> _loadData() async {
    final cubit = context.read<AggregationEventsCubit>();
    
    setState(() {
      _loading = true;
      _error = null;
    });
    
    try {
      // Load container contents or current parent based on whether this is a parent or child
      if (widget.isParent) {
        _hierarchyContents = await cubit.loadContainerContents(widget.epc);
      } else {
        try {
          // If this is a child, find its current parent
          final parentEvent = await cubit.findCurrentParentOfChild(widget.epc);
          if (parentEvent != null) {
            _hierarchyContents = [parentEvent.parentID];
          }
        } catch (e) {
          // Handle case where child is not in any container
          _hierarchyContents = [];
        }
      }
      
      // Load history
      if (widget.isParent) {
        await cubit.trackParentHistory(widget.epc);
        _historyEvents = cubit.state.aggregationEvents;
      } else {
        await cubit.trackChildHistory(widget.epc);
        _historyEvents = cubit.state.aggregationEvents;
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
  
  /// Verify hierarchy integrity by querying the backend
  Future<void> _verifyHierarchy() async {
    setState(() {
      _isVerifying = true;
    });
    
    try {
      // Call the backend verification endpoint through the provider
      final cubit = context.read<AggregationEventsCubit>();
      _isVerified = await cubit.verifyHierarchy(widget.epc);
      
      // Show result in a dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(_isVerified ? 'Verification Successful' : 'Verification Failed'),
            content: Text(
              _isVerified 
                ? 'The hierarchy integrity for ${widget.epc} has been verified. All parent-child relationships are consistent.'
                : 'Failed to verify hierarchy integrity. There may be missing or inconsistent events in the history.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verifying hierarchy: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
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
        title: Text('${widget.isParent ? 'Container' : 'Item'} Hierarchy'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _loading 
        ? const Center(child: AppLoadingIndicator()) 
        : _buildContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isVerifying ? null : _verifyHierarchy,
        label: _isVerifying 
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            )
          : const Text('Verify Hierarchy'),
        icon: const Icon(Icons.verified),
      ),
    );
  }
  
  Widget _buildContent() {
    if (_error != null) {
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
              'Error loading hierarchy data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // EPC information card
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isParent ? 'Container EPC:' : 'Item EPC:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.epc,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.isParent
                        ? 'This container currently contains ${_hierarchyContents.length} items.'
                        : _hierarchyContents.isNotEmpty
                            ? 'This item is currently contained in:'
                            : 'This item is not currently in any container.',
                  ),
                  if (_isVerified) ...[
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Icon(
                          Icons.verified,
                          color: Colors.green,
                          size: 16.0,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          'Hierarchy Verified',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Current hierarchy section
          Text(
            widget.isParent ? 'Current Contents:' : 'Current Container:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8.0),
          
          if (_hierarchyContents.isEmpty)
            Card(
              child: ListTile(
                leading: Icon(widget.isParent ? Icons.inventory : Icons.inventory_2),
                title: Text(widget.isParent
                    ? 'This container is currently empty'
                    : 'This item is not currently in any container'),
              ),
            )
          else
            Card(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _hierarchyContents.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(widget.isParent ? Icons.inventory_2 : Icons.inventory),
                    title: Text(_hierarchyContents[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        // Navigate to the hierarchy view for this EPC
                        context.push('/epcis/aggregation-events/hierarchy/${_hierarchyContents[index]}', 
                          extra: {'epc': _hierarchyContents[index], 'isParent': !widget.isParent});
                      },
                    ),
                  );
                },
              ),
            ),
          
          const SizedBox(height: 24.0),
          
          // History section
          Text(
            'Event History:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8.0),
          
          if (_historyEvents.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.history),
                title: Text('No event history found'),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _historyEvents.length,
              itemBuilder: (context, index) {
                final event = _historyEvents[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ExpansionTile(
                    leading: _getActionIcon(event.action),
                    title: Text('${event.action} Event'),
                    subtitle: Text(DateFormat.yMd().add_Hms().format(event.eventTime)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Parent: ${event.parentID}'),
                            Text('Business Step: ${event.businessStep}'),
                            Text('Disposition: ${event.disposition}'),
                            const SizedBox(height: 8.0),
                            const Text('Child EPCs:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            ...event.childEPCs
                                .take(5)
                                .map((epc) => Text('• $epc'))
                                .toList(),
                            if (event.childEPCs.length > 5)
                              Text(
                                '... and ${event.childEPCs.length - 5} more',
                                style: TextStyle(
                                    color: Theme.of(context).disabledColor),
                              ),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    context.push('/epcis/aggregation-events/${event.eventId}');
                                  },
                                  child: const Text('View Full Details'),
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
        ],
      ),
    );
  }
  
  Icon _getActionIcon(String action) {
    switch (action) {
      case 'ADD':
        return const Icon(Icons.add_circle, color: Colors.green);
      case 'DELETE':
        return const Icon(Icons.remove_circle, color: Colors.red);
      case 'OBSERVE':
        return const Icon(Icons.visibility, color: Colors.blue);
      default:
        return const Icon(Icons.event);
    }
  }
}
