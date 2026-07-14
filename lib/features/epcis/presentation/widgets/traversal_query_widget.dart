import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class TraversalQueryWidget extends StatefulWidget {
  final Function(String queryType, Map<String, dynamic> parameters)? onQueryExecuted;
  final bool isLoading;

  const TraversalQueryWidget({
    super.key,
    this.onQueryExecuted,
    this.isLoading = false,
  });

  @override
  State<TraversalQueryWidget> createState() => _TraversalQueryWidgetState();
}

class _TraversalQueryWidgetState extends State<TraversalQueryWidget>
    with SingleTickerProviderStateMixin {
  final _supplyChainFormKey = GlobalKey<FormBuilderState>();
  final _itemHistoryFormKey = GlobalKey<FormBuilderState>();
  final _aggregationFormKey = GlobalKey<FormBuilderState>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(
              icon: TraqIcon(AppAssets.iconPin),
              text: 'Supply Chain Path',
            ),
            Tab(
              icon: TraqIcon(AppAssets.iconClock),
              text: 'Item History',
            ),
            Tab(
              icon: TraqIcon(AppAssets.iconAggregate),
              text: 'Aggregation',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSupplyChainPathTab(),
              _buildItemHistoryTab(),
              _buildAggregationTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupplyChainPathTab() {
    return FormBuilder(
      key: _supplyChainFormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Supply Chain Path Query',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Trace the complete path of a product through the supply chain.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'epc',
              decoration: const InputDecoration(
                labelText: 'Target EPC',
                hintText: 'https://id.gs1.org/01/10614141123459/21/400',
                prefixIcon: TraqIcon(AppAssets.iconQr),
                border: OutlineInputBorder(),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(10),
              ]),
            ),
            const SizedBox(height: 16),
            FormBuilderDropdown<String>(
              name: 'direction',
              decoration: const InputDecoration(
                labelText: 'Traversal Direction',
                prefixIcon: TraqIcon(AppAssets.iconTransform),
                border: OutlineInputBorder(),
              ),
              initialValue: 'both',
              items: const [
                DropdownMenuItem(value: 'upstream', child: Text('Upstream (Sources)')),
                DropdownMenuItem(value: 'downstream', child: Text('Downstream (Destinations)')),
                DropdownMenuItem(value: 'both', child: Text('Both Directions')),
              ],
            ),
            const SizedBox(height: 16),
            FormBuilderSlider(
              name: 'maxDepth',
              decoration: const InputDecoration(
                labelText: 'Maximum Depth',
                border: OutlineInputBorder(),
              ),
              initialValue: 5,
              min: 1,
              max: 20,
              divisions: 19,
              valueTransformer: (value) => value?.round(),
              displayValues: DisplayValues.current,
            ),
            const SizedBox(height: 16),
            _buildTimeRangeFields(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.isLoading ? null : () => _executeQuery('supplyChainPath'),
                icon: widget.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TraqIcon(AppAssets.iconSearch),
                label: Text(widget.isLoading ? 'Tracing...' : 'Trace Supply Chain'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemHistoryTab() {
    return FormBuilder(
      key: _itemHistoryFormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item History Query',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Get detailed history of events for a specific item.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'epc',
              decoration: const InputDecoration(
                labelText: 'Item EPC',
                hintText: 'https://id.gs1.org/01/10614141123459/21/400',
                prefixIcon: TraqIcon(AppAssets.iconSscc),
                border: OutlineInputBorder(),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(10),
              ]),
            ),
            const SizedBox(height: 16),
            FormBuilderCheckbox(
              name: 'includeTransformations',
              title: const Text('Include Transformation Events'),
              initialValue: true,
            ),
            FormBuilderCheckbox(
              name: 'includeAggregations',
              title: const Text('Include Aggregation Events'),
              initialValue: true,
            ),
            const SizedBox(height: 16),
            _buildTimeRangeFields(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.isLoading ? null : () => _executeQuery('itemHistory'),
                icon: widget.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TraqIcon(AppAssets.iconClock),
                label: Text(widget.isLoading ? 'Loading...' : 'Get Item History'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAggregationTab() {
    return FormBuilder(
      key: _aggregationFormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aggregation Hierarchy Query',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore the hierarchy of aggregated items and their relationships.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'parentEpc',
              decoration: const InputDecoration(
                labelText: 'Parent EPC',
                hintText: 'https://id.gs1.org/00/106141412345678908',
                prefixIcon: TraqIcon(AppAssets.iconPackage),
                border: OutlineInputBorder(),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(10),
              ]),
            ),
            const SizedBox(height: 16),
            FormBuilderDateTimePicker(
              name: 'timestamp',
              inputType: InputType.both,
              decoration: const InputDecoration(
                labelText: 'Query Timestamp (Optional)',
                hintText: 'Leave empty for current state',
                prefixIcon: TraqIcon(AppAssets.iconClock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FormBuilderCheckbox(
              name: 'includeHistory',
              title: const Text('Include Historical Changes'),
              initialValue: false,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.isLoading ? null : () => _executeQuery('aggregationHierarchy'),
                icon: widget.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TraqIcon(AppAssets.iconAggregate),
                label: Text(widget.isLoading ? 'Loading...' : 'Get Aggregation Hierarchy'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeFields() {
    return Column(
      children: [
        FormBuilderDateTimePicker(
          name: 'startTime',
          inputType: InputType.both,
          decoration: const InputDecoration(
            labelText: 'Start Time (Optional)',
            prefixIcon: TraqIcon(AppAssets.iconClock),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        FormBuilderDateTimePicker(
          name: 'endTime',
          inputType: InputType.both,
          decoration: const InputDecoration(
            labelText: 'End Time (Optional)',
            prefixIcon: TraqIcon(AppAssets.iconClock),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  void _executeQuery(String queryType) {
    GlobalKey<FormBuilderState> formKey;
    
    switch (queryType) {
      case 'supplyChainPath':
        formKey = _supplyChainFormKey;
        break;
      case 'itemHistory':
        formKey = _itemHistoryFormKey;
        break;
      case 'aggregationHierarchy':
        formKey = _aggregationFormKey;
        break;
      default:
        formKey = _supplyChainFormKey;
    }
    
    if (formKey.currentState?.saveAndValidate() ?? false) {
      final formData = formKey.currentState!.value;
      
      final parameters = <String, dynamic>{
        ...formData,
      };

      if (parameters['startTime'] is DateTime) {
        parameters['startTime'] = (parameters['startTime'] as DateTime);
      }
      if (parameters['endTime'] is DateTime) {
        parameters['endTime'] = (parameters['endTime'] as DateTime);
      }
      if (parameters['timestamp'] is DateTime) {
        parameters['timestamp'] = (parameters['timestamp'] as DateTime);
      }

      widget.onQueryExecuted?.call(queryType, parameters);
    }
  }
}
