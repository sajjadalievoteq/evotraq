import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/features/epcis/models/transaction_event.dart';
import 'package:traqtrace_app/features/epcis/providers/transaction_events_provider.dart';
import 'package:traqtrace_app/features/epcis/screens/transaction_events_help_screen.dart';
import 'package:traqtrace_app/shared/widgets/app_loading_indicator.dart';
import 'package:intl/intl.dart';

/// Screen for displaying a list of Transaction Events
class TransactionEventsListScreen extends StatefulWidget {
  /// Constructor
  const TransactionEventsListScreen({Key? key}) : super(key: key);

  @override
  State<TransactionEventsListScreen> createState() =>
      _TransactionEventsListScreenState();
}

class _TransactionEventsListScreenState
    extends State<TransactionEventsListScreen> {
  int _currentPage = 0;
  final int _pageSize = 10;

  String? _filterBizStep;
  String? _filterDisposition;
  String? _filterLocationGLN;
  DateTimeRange? _filterDateRange;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Load initial data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactionEvents();
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
      final cubit = context.read<TransactionEventsCubit>();
      final currentState = cubit.state;

      // Check if we can load more pages
      if (_currentPage < currentState.totalPages - 1 && !currentState.loading) {
        _currentPage++;
        _loadTransactionEvents(isLoadMore: true);
      }
    }
  }

  Future<void> _loadTransactionEvents({bool isLoadMore = false}) async {
    if (!isLoadMore) {
      _currentPage = 0;
    }

    await context.read<TransactionEventsCubit>().loadTransactionEvents(
      page: _currentPage,
      size: _pageSize,
      bizStep: _filterBizStep,
      disposition: _filterDisposition,
      locationGLN: _filterLocationGLN,
      startTime: _filterDateRange?.start,
      endTime: _filterDateRange?.end,
      loadMore: isLoadMore,
    );
  }

  Future<void> _refreshData() async {
    await _loadTransactionEvents();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? bizStep = _filterBizStep;
        String? disposition = _filterDisposition;
        String? locationGLN = _filterLocationGLN;
        DateTimeRange? dateRange = _filterDateRange;

        return AlertDialog(
          title: const Text('Filter Transaction Events'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Business Step',
                    hintText: 'e.g. shipping, receiving',
                  ),
                  controller: TextEditingController(text: bizStep),
                  onChanged: (value) {
                    bizStep = value.isNotEmpty ? value : null;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Disposition',
                    hintText: 'e.g. in_transit, in_progress',
                  ),
                  controller: TextEditingController(text: disposition),
                  onChanged: (value) {
                    disposition = value.isNotEmpty ? value : null;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Location GLN',
                    hintText: 'Enter GLN code',
                  ),
                  controller: TextEditingController(text: locationGLN),
                  onChanged: (value) {
                    locationGLN = value.isNotEmpty ? value : null;
                  },
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dateRange != null
                            ? '${DateFormat.yMd().format(dateRange.start)} - ${DateFormat.yMd().format(dateRange.end)}'
                            : 'Select Date Range',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final result = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          initialDateRange:
                              dateRange ??
                              DateTimeRange(
                                start: DateTime.now().subtract(
                                  const Duration(days: 30),
                                ),
                                end: DateTime.now(),
                              ),
                        );
                        if (result != null) {
                          dateRange = result;
                        }
                      },
                    ),
                    if (dateRange != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          dateRange = null;
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _filterBizStep = bizStep;
                  _filterDisposition = disposition;
                  _filterLocationGLN = locationGLN;
                  _filterDateRange = dateRange;
                });
                Navigator.pop(context);
                _loadTransactionEvents();
              },
              child: const Text('Apply'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _filterBizStep = null;
                  _filterDisposition = null;
                  _filterLocationGLN = null;
                  _filterDateRange = null;
                });
                Navigator.pop(context);
                _loadTransactionEvents();
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToEventDetails(TransactionEvent event) {
    // Extract just the UUID part from the eventId
    // The eventId is typically in format 'urn:epcglobal:cbv:epcis:event:UUID'

    print('DEBUG: Event database id: ${event.id}');
    print('DEBUG: Event unique identifier (eventId): ${event.eventId}');

    // Determine which ID to use - preferring the database ID if available, otherwise extract UUID from eventId
    String idToUse;

    if (event.id != null && event.id!.isNotEmpty) {
      // If we have a database ID, use it as it's most reliable
      idToUse = event.id!;
      print('DEBUG: Using database ID: $idToUse');
    } else if (event.eventId.contains(':')) {
      // Extract just the UUID part from a URN format
      idToUse = event.eventId.split(':').last;
      print('DEBUG: Extracted UUID from eventId: $idToUse');
    } else {
      // Use the eventId as is (might already be just the UUID)
      idToUse = event.eventId;
      print('DEBUG: Using eventId as is: $idToUse');
    }

    context.push('/epcis/transaction-events/$idToUse', extra: event).then((
      result,
    ) {
      if (result == true) {
        _refreshData();
      }
    });
  }

  void _navigateToCreateEvent() {
    // Use GoRouter for consistent navigation across the app
    context.push('/epcis/transaction-events/new').then((result) {
      if (result == true) {
        _refreshData();
      }
    });
  }

  /// Show the help screen for Transaction Events
  void _showHelpScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TransactionEventsHelpScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpScreen(context),
            tooltip: 'Help',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateEvent,
        tooltip: 'Create Transaction Event',
        child: const Icon(Icons.add),
      ),
      drawer: const AppDrawer(),
      body: BlocBuilder<TransactionEventsCubit, TransactionEventsState>(
        builder: (context, state) {
          if (state.loading && state.transactionEvents.isEmpty) {
            return const Center(child: AppLoadingIndicator());
          }

          if (state.error != null && state.transactionEvents.isEmpty) {
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
                    'Error loading transaction events',
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

          if (state.transactionEvents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note, size: 48.0, color: Colors.grey[400]),
                  const SizedBox(height: 16.0),
                  Text(
                    'No Transaction Events Found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8.0),
                  if (_filterBizStep != null ||
                      _filterDisposition != null ||
                      _filterLocationGLN != null ||
                      _filterDateRange != null)
                    Text(
                      'Try adjusting your filters',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _navigateToCreateEvent,
                    child: const Text('Create Transaction Event'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.builder(
              controller: _scrollController,
              itemCount:
                  state.transactionEvents.length + (state.loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.transactionEvents.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: AppLoadingIndicator()),
                  );
                }

                final event = state.transactionEvents[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ListTile(
                    title: Text(
                      'Transaction: ${event.action}',
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
                        if (event.bizTransactionList.isNotEmpty)
                          Text(
                            'Transactions: ${event.bizTransactionList.entries.map((e) => "${e.key}: ${e.value}").join(", ")}',
                          ),
                        if (event.epcList != null && event.epcList!.isNotEmpty)
                          Text('EPCs: ${event.epcList!.length}'),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () => _navigateToEventDetails(event),
                    trailing: const Icon(Icons.chevron_right),
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
