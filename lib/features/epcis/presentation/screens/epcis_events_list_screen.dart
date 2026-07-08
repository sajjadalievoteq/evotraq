import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/features/epcis/cubit/epcis_events_cubit.dart';
import 'package:traqtrace_app/core/widgets/app_loading_indicator.dart';
import 'package:traqtrace_app/core/widgets/error_display.dart';
import 'package:traqtrace_app/core/utils/cbv_display_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class EPCISEventsListScreen extends StatefulWidget {
  const EPCISEventsListScreen({Key? key}) : super(key: key);

  @override
  State<EPCISEventsListScreen> createState() => _EPCISEventsListScreenState();
}

class _EPCISEventsListScreenState extends State<EPCISEventsListScreen> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  DateTime? _startDate;
  DateTime? _endDate;
  int _currentPage = 0;
  final int _pageSize = 20;
  
  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
    _startDate = _endDate!.subtract(const Duration(days: 30));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
    });
  }

  void _loadEvents() {
    final cubit = context.read<EPCISEventsCubit>();
    if (_startDate != null && _endDate != null) {
      cubit.loadEventsByTimeWindow(
        _startDate!, 
        _endDate!,
        page: _currentPage,
        pageSize: _pageSize,
      );
    } else {
      cubit.loadEvents(
        page: _currentPage,
        pageSize: _pageSize,
      );
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        end: _endDate ?? DateTime.now(),
      ),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end.add(const Duration(days: 1, seconds: -1));
        _currentPage = 0;
      });
      _loadEvents();
    }
  }
  void _navigateToEventDetails(EPCISEvent event) {
    context.go('/epcis/events/${event.id}', extra: event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EPCIS Events'),
        actions: [
          IconButton(
            icon: const TraqIcon(AppAssets.iconCalendar),
            onPressed: _selectDateRange,
            tooltip: 'Filter by date',
          ),
          IconButton(
            icon: const TraqIcon(AppAssets.iconFilter),
            onPressed: () {
              _showAdvancedFilterDialog();
            },
            tooltip: 'Advanced filters',
          ),
          IconButton(
            icon: TraqIcon(AppAssets.iconRefresh),
            onPressed: _loadEvents,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: TraqIcon(AppAssets.iconSearch),
            onPressed: _showEPCSearchDialog,
            tooltip: 'Search by EPC',          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: BlocBuilder<EPCISEventsCubit, EPCISEventsState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: AppLoadingIndicator());
          }
          
          if (state.error != null) {
            return ErrorDisplay(
              message: 'Failed to load events: ${state.error}',
              onRetry: _loadEvents,
            );
          }
          
          final events = state.events;
          
          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No events found for the selected criteria'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _selectDateRange,
                    child: const Text('Change Date Range'),
                  ),
                ],
              ),
            );
          }
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Showing events from ${_dateFormat.format(_startDate ?? DateTime.now().subtract(const Duration(days: 30)))} to ${_dateFormat.format(_endDate ?? DateTime.now())}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              
              Expanded(
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        title: Text(
                          'Event ID: ${event.eventId}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Time: ${_dateFormat.format(event.eventTime)}'),
                            if (event.businessStep != null)
                              Text(
                                'Step: ${CbvDisplayUtils.displayBizStep(event.businessStep)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (event.disposition != null)
                              Text(
                                'Disp: ${CbvDisplayUtils.displayDisposition(event.disposition)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: TraqIcon(AppAssets.iconChevronR),
                          onPressed: () => _navigateToEventDetails(event),
                        ),
                        onTap: () => _navigateToEventDetails(event),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
              
              if (state.totalPages > 1)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const TraqIcon(AppAssets.iconChevronL),
                        onPressed: _currentPage > 0
                            ? () {
                                setState(() {
                                  _currentPage--;
                                });
                                _loadEvents();
                              }
                            : null,
                      ),
                      Text(
                        'Page ${_currentPage + 1} of ${state.totalPages}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      IconButton(
                        icon: const TraqIcon(AppAssets.iconChevronR),
                        onPressed: _currentPage < state.totalPages - 1
                            ? () {
                                setState(() {
                                  _currentPage++;
                                });
                                _loadEvents();
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEventTypeSelectionDialog();
        },
        child: TraqIcon(AppAssets.iconPlus),
        tooltip: 'Create new event',
      ),
    );
  }

  void _showAdvancedFilterDialog() {
    String? selectedBusinessStep;
    String? selectedDisposition;
    String? selectedLocation;
    String? selectedEPC;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advanced Filters'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Business Step',
                  hintText: 'e.g., commissioning, shipping',
                ),
                onChanged: (value) => selectedBusinessStep = value.isEmpty ? null : value,
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Disposition',
                  hintText: 'e.g., active, inactive',
                ),
                onChanged: (value) => selectedDisposition = value.isEmpty ? null : value,
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Location GLN',
                  hintText: 'e.g., 1234567890123',
                ),
                onChanged: (value) => selectedLocation = value.isEmpty ? null : value,
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'EPC',
                  hintText: 'e.g., urn:epc:id:sgtin:...',
                ),
                onChanged: (value) => selectedEPC = value.isEmpty ? null : value,
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
              Navigator.pop(context);
              final cubit = context.read<EPCISEventsCubit>();
              
              if (selectedBusinessStep != null) {
                cubit.loadEventsByBusinessStep(selectedBusinessStep!);
              } else if (selectedDisposition != null) {
                cubit.loadEventsByDisposition(selectedDisposition!);
              } else if (selectedLocation != null) {
                cubit.loadEventsByLocation(selectedLocation!);
              } else if (selectedEPC != null) {
                cubit.loadEventsByEPC(selectedEPC!);
              }
            },
            child: const Text('Apply Filter'),
          ),
        ],
      ),
    );
  }

  void _showEPCSearchDialog() {
    String? epc;
    bool trackHistory = false;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('EPC Search'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'EPC',
                hintText: 'Enter EPC code',
              ),
              onChanged: (value) => epc = value,
            ),
            const SizedBox(height: 10),
            CheckboxListTile(
              title: const Text('Show Item History'),
              value: trackHistory,
              onChanged: (value) => trackHistory = value ?? false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (epc != null && epc!.isNotEmpty) {
                final cubit = context.read<EPCISEventsCubit>();
                if (trackHistory) {
                  cubit.loadItemHistory(epc!);
                } else {
                  cubit.loadEventsByEPC(epc!);
                }
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showEventTypeSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Event Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [            ListTile(
              title: const Text('Object Event'),
              onTap: () {
                Navigator.pop(context);
                context.go('/epcis/object-events/new');
              },
            ),
            ListTile(
              title: const Text('Aggregation Event'),
              onTap: () {
                Navigator.pop(context);
                context.go('/epcis/aggregation-events/new');
              },
            ),
            ListTile(
              title: const Text('Transaction Event'),
              onTap: () {
                Navigator.pop(context);
                context.go('/epcis/transaction-events/new');
              },
            ),
            ListTile(
              title: const Text('Transformation Event'),
              onTap: () {
                Navigator.pop(context);
                context.go('/epcis/transformation-events/new');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}