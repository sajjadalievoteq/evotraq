import 'package:flutter/material.dart';

class FacetedSearchWidget extends StatefulWidget {
  final Map<String, List<String>>? availableFacets;
  final Map<String, List<String>>? selectedFacets;
  final Function(Map<String, List<String>>)? onFacetsChanged;
  final bool isLoading;

  const FacetedSearchWidget({
    super.key,
    this.availableFacets,
    this.selectedFacets,
    this.onFacetsChanged,
    this.isLoading = false,
  });

  @override
  State<FacetedSearchWidget> createState() => _FacetedSearchWidgetState();
}

class _FacetedSearchWidgetState extends State<FacetedSearchWidget> {
  Map<String, List<String>> _selectedFacets = {};

  @override
  void initState() {
    super.initState();
    _selectedFacets = Map.from(widget.selectedFacets ?? {});
  }

  @override
  void didUpdateWidget(FacetedSearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedFacets != oldWidget.selectedFacets) {
      _selectedFacets = Map.from(widget.selectedFacets ?? {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const Divider(),
          Expanded(
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Faceted Search',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          if (_selectedFacets.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedFacets.clear();
                });
                widget.onFacetsChanged?.call(_selectedFacets);
              },
              child: const Text('Clear All'),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading facets...'),
            ],
          ),
        ),
      );
    }

    if (widget.availableFacets == null || widget.availableFacets!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.filter_list_off,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No facets available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Execute a query to see available facets for filtering.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_selectedFacets.isNotEmpty)
              _buildSelectedFacets(context),
            ..._buildFacetGroups(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFacets(BuildContext context) {
    final selectedCount = _selectedFacets.values
        .map((list) => list.length)
        .fold(0, (a, b) => a + b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Active Filters ($selectedCount)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _selectedFacets.entries
                .expand((facetGroup) => facetGroup.value.map((value) => 
                    _buildSelectedFacetChip(context, facetGroup.key, value)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFacetChip(BuildContext context, String facetKey, String value) {
    return Chip(
      label: Text('$facetKey: $value'),
      onDeleted: () {
        setState(() {
          _selectedFacets[facetKey]?.remove(value);
          if (_selectedFacets[facetKey]?.isEmpty == true) {
            _selectedFacets.remove(facetKey);
          }
        });
        widget.onFacetsChanged?.call(_selectedFacets);
      },
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      deleteIconColor: Theme.of(context).colorScheme.error,
    );
  }

  List<Widget> _buildFacetGroups(BuildContext context) {
    return widget.availableFacets!.entries.map((entry) {
      final facetKey = entry.key;
      final facetValues = entry.value;

      return ExpansionTile(
        title: Text(_formatFacetKey(facetKey)),
        leading: Icon(_getFacetIcon(facetKey)),
        subtitle: Text('${facetValues.length} options'),
        initiallyExpanded: _selectedFacets.containsKey(facetKey),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select ${_formatFacetKey(facetKey)}:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: facetValues.map((value) {
                    final isSelected = _selectedFacets[facetKey]?.contains(value) == true;
                    return FilterChip(
                      label: Text(value),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedFacets.putIfAbsent(facetKey, () => []);
                            _selectedFacets[facetKey]!.add(value);
                          } else {
                            _selectedFacets[facetKey]?.remove(value);
                            if (_selectedFacets[facetKey]?.isEmpty == true) {
                              _selectedFacets.remove(facetKey);
                            }
                          }
                        });
                        widget.onFacetsChanged?.call(_selectedFacets);
                      },
                      backgroundColor: isSelected 
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
                      checkmarkColor: Theme.of(context).colorScheme.primary,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  String _formatFacetKey(String facetKey) {
    switch (facetKey) {
      case 'eventType':
        return 'Event Type';
      case 'businessStep':
      case 'bizStep':
        return 'Business Step';
      case 'disposition':
        return 'Disposition';
      case 'readPoint':
        return 'Read Point';
      case 'businessLocation':
      case 'bizLocation':
        return 'Business Location';
      case 'source':
        return 'Source';
      case 'destination':
        return 'Destination';
      case 'transformationId':
        return 'Transformation ID';
      case 'parentId':
        return 'Parent ID';
      case 'childEpcs':
        return 'Child EPCs';
      default:
        return facetKey.split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  IconData _getFacetIcon(String facetKey) {
    switch (facetKey) {
      case 'eventType':
        return Icons.category;
      case 'businessStep':
      case 'bizStep':
        return Icons.business;
      case 'disposition':
        return Icons.label;
      case 'readPoint':
        return Icons.place;
      case 'businessLocation':
      case 'bizLocation':
        return Icons.location_on;
      case 'source':
        return Icons.input;
      case 'destination':
        return Icons.output;
      case 'transformationId':
        return Icons.transform;
      case 'parentId':
        return Icons.account_tree;
      case 'childEpcs':
        return Icons.subdirectory_arrow_right;
      default:
        return Icons.filter_alt;
    }
  }
}
