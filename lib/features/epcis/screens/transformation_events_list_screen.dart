import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/epcis/models/transformation_event.dart';
import 'package:traqtrace_app/features/epcis/providers/transformation_events_provider.dart';
import 'package:traqtrace_app/features/epcis/widgets/transformation_events_help.dart';
import 'package:traqtrace_app/shared/widgets/app_loading_indicator.dart';

/// Screen for displaying a list of Transformation Events
class TransformationEventsListScreen extends StatefulWidget {
  /// Constructor
  const TransformationEventsListScreen({Key? key}) : super(key: key);

  @override
  State<TransformationEventsListScreen> createState() => _TransformationEventsListScreenState();
}

class _TransformationEventsListScreenState extends State<TransformationEventsListScreen> {
  String? _filterTransformationId;
  String? _filterBizStep;
  String? _filterDisposition;
  String? _filterLocationGLN;
  String? _filterInputEPC;
  String? _filterOutputEPC;
  DateTimeRange? _filterDateRange;
  
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    
    // Load initial data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransformationEvents();
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _loadTransformationEvents() async {
    final provider = Provider.of<TransformationEventsProvider>(context, listen: false);
    
    // Apply filters if any are set
    if (_filterTransformationId != null) {
      await provider.findByTransformationId(_filterTransformationId!);
    } else if (_filterInputEPC != null) {
      await provider.findByInputEPC(_filterInputEPC!);
    } else if (_filterOutputEPC != null) {
      await provider.findByOutputEPC(_filterOutputEPC!);
    } else {
      // Otherwise load all transformation events
      await provider.loadTransformationEvents();
    }
  }
  
  Future<void> _refreshData() async {
    await _loadTransformationEvents();
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? transformationId = _filterTransformationId;
        String? bizStep = _filterBizStep;
        String? disposition = _filterDisposition;
        String? locationGLN = _filterLocationGLN;
        String? inputEPC = _filterInputEPC;
        String? outputEPC = _filterOutputEPC;
        DateTimeRange? dateRange = _filterDateRange;
        
        return AlertDialog(
          title: const Text('Filter Transformation Events'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Transformation ID',
                  ),
                  onChanged: (value) => transformationId = value.isEmpty ? null : value,
                  controller: TextEditingController(text: _filterTransformationId ?? ''),
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Input EPC',
                  ),
                  onChanged: (value) => inputEPC = value.isEmpty ? null : value,
                  controller: TextEditingController(text: _filterInputEPC ?? ''),
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Output EPC',
                  ),
                  onChanged: (value) => outputEPC = value.isEmpty ? null : value,
                  controller: TextEditingController(text: _filterOutputEPC ?? ''),
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
                  _filterTransformationId = transformationId;
                  _filterBizStep = bizStep;
                  _filterDisposition = disposition;
                  _filterLocationGLN = locationGLN;
                  _filterInputEPC = inputEPC;
                  _filterOutputEPC = outputEPC;
                  _filterDateRange = dateRange;
                });
                Navigator.pop(context);
                _loadTransformationEvents();
              },
              child: const Text('Apply'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _filterTransformationId = null;
                  _filterBizStep = null;
                  _filterDisposition = null;
                  _filterLocationGLN = null;
                  _filterInputEPC = null;
                  _filterOutputEPC = null;
                  _filterDateRange = null;
                });
                Navigator.pop(context);
                _loadTransformationEvents();
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }
  
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => const Dialog(
        insetPadding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: TransformationEventsHelp(),
        ),
      ),
    );
  }  void _navigateToEventDetails(TransformationEvent event) {
    // Only pass the ID, not the event object, so form will load fresh data from API
    if (event.id != null) {
      context.push('/epcis/transformation-events/${event.id}', extra: event.id).then((result) {
        if (result == true) {
          _refreshData();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event ID is missing')),
      );
    }
  }

  void _navigateToCreateEvent() {
    context.push('/epcis/transformation-events/new').then((result) {
      if (result == true) {
        _refreshData();
      }
    });
  }
  
  // Show tracking dialog for EPCs
  Future<void> _showTrackEPCDialog() async {
    final TextEditingController epcController = TextEditingController();
    bool isSearching = false;
    List<TransformationEvent>? results;
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Track EPC Transformations'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: epcController,
                      decoration: const InputDecoration(
                        labelText: 'Enter EPC to track',
                        hintText: 'e.g., urn:epc:id:sgtin:...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isSearching)
                      const Center(child: CircularProgressIndicator())
                    else if (results != null)
                      results!.isEmpty
                        ? const Text('No transformation events found for this EPC')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Found ${results!.length} transformation events:',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ...results!.map((event) {
                                return Card(
                                  child: ListTile(
                                    title: Text('ID: ${event.transformationID}'),
                                    subtitle: Text(
                                      'Date: ${DateFormat.yMMMd().format(event.eventTime)}\n'
                                      'Input EPCs: ${event.inputEPCList.length}\n'
                                      'Output EPCs: ${event.outputEPCList.length}'
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _viewEventDetails(event);
                                    },
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Track'),
                  onPressed: () async {
                    if (epcController.text.isEmpty) return;
                    
                    setState(() {
                      isSearching = true;
                      results = null;
                    });
                    
                    try {
                      final provider = Provider.of<TransformationEventsProvider>(
                        context, 
                        listen: false
                      );
                      
                      // Use the track API endpoint
                      final events = await provider.trackTransformationsByEPC(
                        epcController.text.trim()
                      );
                      
                      setState(() {
                        isSearching = false;
                        results = events;
                      });
                    } catch (e) {
                      setState(() {
                        isSearching = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error tracking EPC: $e')),
                      );
                    }
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }

  // Show input-output relationship tracking dialog
  Future<void> _showInputOutputTrackingDialog() async {
    final TextEditingController inputEpcController = TextEditingController();
    final TextEditingController outputEpcController = TextEditingController();
    bool isSearching = false;
    List<TransformationEvent>? results;
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Track Input-Output Relationship'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: inputEpcController,
                      decoration: const InputDecoration(
                        labelText: 'Input EPC',
                        hintText: 'e.g., urn:epc:id:sgtin:...',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: outputEpcController,
                      decoration: const InputDecoration(
                        labelText: 'Output EPC',
                        hintText: 'e.g., urn:epc:id:sgtin:...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isSearching)
                      const Center(child: CircularProgressIndicator())
                    else if (results != null)
                      results!.isEmpty
                        ? const Text('No transformation relationship found')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Found ${results!.length} linking transformation events:',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ...results!.map((event) {
                                return Card(
                                  child: ListTile(
                                    title: Text('ID: ${event.transformationID}'),
                                    subtitle: Text(
                                      'Date: ${DateFormat.yMMMd().format(event.eventTime)}\n'
                                      'Step: ${event.businessStep ?? "N/A"}'
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _viewEventDetails(event);
                                    },
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Find Relationship'),
                  onPressed: () async {
                    if (inputEpcController.text.isEmpty || 
                        outputEpcController.text.isEmpty) return;
                    
                    setState(() {
                      isSearching = true;
                      results = null;
                    });
                    
                    try {
                      final provider = Provider.of<TransformationEventsProvider>(
                        context, 
                        listen: false
                      );
                      
                      // Use the input-output API endpoint directly
                      final events = await provider.findTransformationsByInputOutput(
                        inputEpcController.text.trim(),
                        outputEpcController.text.trim()
                      );
                      
                      setState(() {
                        isSearching = false;
                        results = events;
                      });
                    } catch (e) {
                      setState(() {
                        isSearching = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error finding relationship: $e')),
                      );
                    }
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }

  // View event details
  void _viewEventDetails(TransformationEvent event) {
    // Navigate to event details or show a detailed dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transformation ID: ${event.transformationID}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Event ID: ${event.eventId}'),
              Text('Event Time: ${DateFormat.yMMMd().add_Hms().format(event.eventTime)}'),
              Text('Business Step: ${event.businessStep ?? "N/A"}'),
              Text('Disposition: ${event.disposition ?? "N/A"}'),
              Text('Business Location: ${event.readPoint != null ? event.readPoint.toString() : "N/A"}'),
              const Divider(),
              Text('Input EPCs (${event.inputEPCList.length}):'),
              ...event.inputEPCList.map((epc) => Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text('• $epc', style: const TextStyle(fontSize: 12)),
              )),
              const SizedBox(height: 8),
              Text('Output EPCs (${event.outputEPCList.length}):'),
              ...event.outputEPCList.map((epc) => Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text('• $epc', style: const TextStyle(fontSize: 12)),
              )),
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
        title: const Text('Transformation Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: 'Help',
          ),
          IconButton(
            icon: const Icon(Icons.track_changes),
            onPressed: _showTrackEPCDialog,
            tooltip: 'Track EPC',
          ),
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            onPressed: _showInputOutputTrackingDialog,
            tooltip: 'Track Input-Output',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreateEvent,
            tooltip: 'Create Transformation Event',          
          ),
        ],
      ),      drawer: const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildQuickInfoCard(),
          Expanded(
            child: _buildEventsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateEvent,
        tooltip: 'Create Transformation Event',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickInfoCard() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.transform, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  'GS1 Transformation Events',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Track product transformations such as manufacturing, repackaging, or assembly processes.',
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: _showHelpDialog,
              child: const Text('Learn More'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    return Consumer<TransformationEventsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.transformationEvents.isEmpty) {
          return const Center(child: AppLoadingIndicator());
        }
        
        if (provider.errorMessage != null && provider.transformationEvents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text('Error: ${provider.errorMessage}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshData,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }
        
        if (provider.transformationEvents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.transform, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No transformation events found'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _navigateToCreateEvent,
                  child: const Text('Create First Event'),
                ),
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.separated(
            controller: _scrollController,
            itemCount: provider.transformationEvents.length + (provider.isLoading ? 1 : 0),
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index == provider.transformationEvents.length) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: AppLoadingIndicator(),
                ));
              }
              
              final event = provider.transformationEvents[index];
              return _buildEventItem(event);
            },
          ),
        );
      },
    );
  }

  Widget _buildEventItem(TransformationEvent event) {
    final inputCount = event.inputEPCList.length;
    final outputCount = event.outputEPCList.length;
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(event.eventTime);
    
    return ListTile(
      onTap: () => _navigateToEventDetails(event),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.indigo.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.transform, color: Colors.indigo),
      ),
      title: Text(
        'ID: ${event.transformationID}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text('Date: $formattedDate'),
          Text('$inputCount input(s) → $outputCount output(s)'),
          if (event.businessStep != null)
            Text('Process: ${_getReadableBusinessStep(event.businessStep!)}'),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
  
  String _getReadableBusinessStep(String bizStep) {
    // Convert GS1 standard URN to readable text
    final parts = bizStep.split(':');
    if (parts.length > 4) {
      return _capitalizeFirstLetter(parts[4]);
    }
    return bizStep;
  }
  
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
