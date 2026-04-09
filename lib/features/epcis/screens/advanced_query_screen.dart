import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import '../cubit/advanced_query_cubit.dart';
import '../widgets/query_parameter_widget.dart';
import '../widgets/query_results_widget.dart';
import '../widgets/faceted_search_widget.dart';

/// Screen for advanced EPCIS query interface with sophisticated filtering
/// and analytical capabilities.
class AdvancedQueryScreen extends StatefulWidget {
  const AdvancedQueryScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedQueryScreen> createState() => _AdvancedQueryScreenState();
}

class _AdvancedQueryScreenState extends State<AdvancedQueryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _queryFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdvancedQueryCubit>().loadAvailableFacets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        title: const Text('Advanced Query Interface'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Advanced Query', icon: Icon(Icons.search)),
            Tab(text: 'Faceted Search', icon: Icon(Icons.filter_list)),
            Tab(text: 'Full-Text Search', icon: Icon(Icons.text_fields)),
            Tab(text: 'Geospatial Query', icon: Icon(Icons.map)),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: BlocBuilder<AdvancedQueryCubit, AdvancedQueryState>(
        builder: (context, state) {
          final cubit = context.read<AdvancedQueryCubit>();
          return TabBarView(
            controller: _tabController,
            children: [
              _buildAdvancedQueryTab(cubit, state),
              _buildFacetedSearchTab(cubit, state),
              _buildFullTextSearchTab(cubit, state),
              _buildGeospatialQueryTab(cubit, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAdvancedQueryTab(
    AdvancedQueryCubit cubit,
    AdvancedQueryState state,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Left panel: Query parameters
          Expanded(
            flex: 1,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _queryFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Query Parameters',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: QueryParameterWidget(
                            initialParameters: state.queryParameters,
                            onParametersChanged: (params) {
                              cubit.updateQueryParameters(params);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: state.loading
                                  ? null
                                  : () => _executeAdvancedQuery(cubit),
                              child: state.loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Execute Query'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => _saveAsStoredQuery(cubit),
                            child: const Text('Save Query'),
                          ),
                        ],
                      ),
                      if (state.error != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade200),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            state.error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Right panel: Query results
          Expanded(
            flex: 2,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Query Results',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        if (state.queryResult != null)
                          Text(
                            '${state.queryResult!.returnedCount} of ${state.queryResult!.totalCount} results (${state.queryResult!.executionTimeMs}ms)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: state.queryResult != null
                          ? QueryResultsWidget(result: state.queryResult!)
                          : const Center(
                              child: Text(
                                'Execute a query to see results here',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacetedSearchTab(
    AdvancedQueryCubit cubit,
    AdvancedQueryState state,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Left panel: Faceted search parameters
          Expanded(
            flex: 1,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FacetedSearchWidget(
                  availableFacets: state.availableFacets,
                  selectedFacets: state.selectedFacets,
                  onFacetsChanged: (facets) {
                    cubit.updateSelectedFacets(facets);
                  },
                  isLoading: state.loading,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Right panel: Faceted results
          Expanded(
            flex: 2,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Faceted Search Results',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: state.facetedResults != null
                          ? _buildFacetedResults(state.facetedResults!)
                          : const Center(
                              child: Text(
                                'Execute a faceted search to see results here',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullTextSearchTab(
    AdvancedQueryCubit cubit,
    AdvancedQueryState state,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Full-Text Search',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Search Text',
                            hintText:
                                'Enter text to search across all event data',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            cubit.updateSearchText(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: state.selectedEventType,
                        hint: const Text('Event Type'),
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('All Event Types'),
                          ),
                          DropdownMenuItem(
                            value: 'ObjectEvent',
                            child: Text('Object Events'),
                          ),
                          DropdownMenuItem(
                            value: 'AggregationEvent',
                            child: Text('Aggregation Events'),
                          ),
                          DropdownMenuItem(
                            value: 'TransactionEvent',
                            child: Text('Transaction Events'),
                          ),
                          DropdownMenuItem(
                            value: 'TransformationEvent',
                            child: Text('Transformation Events'),
                          ),
                        ],
                        onChanged: (value) {
                          cubit.updateSelectedEventType(value);
                        },
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: state.loading
                            ? null
                            : () => cubit.executeFullTextSearch(),
                        child: state.loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Search'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: state.fullTextResults != null
                    ? _buildFullTextResults(state.fullTextResults!)
                    : const Center(
                        child: Text(
                          'Enter search text and click Search to see results',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeospatialQueryTab(
    AdvancedQueryCubit cubit,
    AdvancedQueryState state,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Geospatial Query',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Center Latitude',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            cubit.updateCenterLatitude(double.tryParse(value));
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Center Longitude',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            cubit.updateCenterLongitude(double.tryParse(value));
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Radius (km)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            cubit.updateRadius(double.tryParse(value));
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: state.loading
                            ? null
                            : () => cubit.executeGeospatialQuery(),
                        child: state.loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Search'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: state.geospatialResults != null
                    ? _buildGeospatialResults(state.geospatialResults!)
                    : const Center(
                        child: Text(
                          'Enter coordinates and radius to search for events in geographic area',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacetedResults(Map<String, dynamic> results) {
    final facets = results['facets'] as Map<String, dynamic>? ?? {};
    final events = results['events'] as List? ?? [];

    return Column(
      children: [
        // Facets
        if (facets.isNotEmpty) ...[
          Text('Facets', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: facets.keys.length,
              itemBuilder: (context, index) {
                final facetName = facets.keys.elementAt(index);
                final facetValues = facets[facetName] as Map<String, dynamic>;

                return Card(
                  margin: const EdgeInsets.only(right: 8),
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          facetName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: facetValues.keys.length,
                            itemBuilder: (context, valueIndex) {
                              final value = facetValues.keys.elementAt(
                                valueIndex,
                              );
                              final count = facetValues[value];
                              return ListTile(
                                dense: true,
                                title: Text(value),
                                trailing: Text('$count'),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Events
        Text(
          'Events (${events.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                title: Text(event['eventType'] ?? 'Unknown Event'),
                subtitle: Text(event['bizStep'] ?? ''),
                trailing: Text(event['eventTime'] ?? ''),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFullTextResults(Map<String, dynamic> results) {
    final events = results['content'] as List? ?? [];
    final totalElements = results['totalElements'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Results ($totalElements found)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                child: ListTile(
                  title: Text(event['eventType'] ?? 'Unknown Event'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Business Step: ${event['bizStep'] ?? 'N/A'}'),
                      Text('Disposition: ${event['disposition'] ?? 'N/A'}'),
                      Text('Location: ${event['readPoint'] ?? 'N/A'}'),
                    ],
                  ),
                  trailing: Text(event['eventTime'] ?? ''),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGeospatialResults(List<dynamic> results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Geospatial Results (${results.length} found)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final event = results[index];
              return Card(
                child: ListTile(
                  title: Text(event['eventType'] ?? 'Unknown Event'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Location: ${event['readPoint'] ?? 'N/A'}'),
                      Text('Business Step: ${event['bizStep'] ?? 'N/A'}'),
                      Text('Time: ${event['eventTime'] ?? 'N/A'}'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _executeAdvancedQuery(AdvancedQueryCubit cubit) async {
    if (_queryFormKey.currentState?.validate() ?? false) {
      await cubit.executeAdvancedQuery();
    }
  }

  void _saveAsStoredQuery(AdvancedQueryCubit cubit) {
    // Show dialog to save query
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Query'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Query Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                cubit.updateStoredQueryName(value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                cubit.updateStoredQueryDescription(value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await cubit.saveStoredQuery();
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Query saved successfully')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
