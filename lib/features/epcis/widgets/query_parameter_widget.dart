import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../models/epcis_query_parameters.dart';

class QueryParameterWidget extends StatefulWidget {
  final EPCISQueryParameters? initialParameters;
  final Function(EPCISQueryParameters) onParametersChanged;

  const QueryParameterWidget({
    super.key,
    this.initialParameters,
    required this.onParametersChanged,
  });

  @override
  State<QueryParameterWidget> createState() => _QueryParameterWidgetState();
}

class _QueryParameterWidgetState extends State<QueryParameterWidget> {
  final _formKey = GlobalKey<FormBuilderState>();
  late EPCISQueryParameters _parameters;

  @override
  void initState() {
    super.initState();
    _parameters = widget.initialParameters ?? EPCISQueryParameters();
  }

  void _updateParameters() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      
      // Properly handle eventTypes - ensure it's passed as a list when selected
      List<String>? eventTypes;
      if (values['eventTypes'] != null && values['eventTypes'].toString().trim().isNotEmpty) {
        eventTypes = [values['eventTypes'].toString()];
      }
      
      _parameters = _parameters.copyWith(
        eventTypes: eventTypes,
        startTime: values['startTime']?.toIso8601String(),
        endTime: values['endTime']?.toIso8601String(),
        epcs: values['epcs']?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        epcClass: values['epcClass']?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        businessSteps: values['businessSteps']?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        dispositions: values['dispositions']?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        readPoints: values['readPoints']?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        businessLocations: values['businessLocations']?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        orderBy: values['orderBy'],
        orderDirection: values['orderDirection'],
        limit: int.tryParse(values['limit'] ?? ''),
        offset: int.tryParse(values['offset'] ?? ''),
      );
      
      widget.onParametersChanged(_parameters);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          onChanged: _updateParameters,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Query Parameters',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildEventTypeSection(),
              const SizedBox(height: 16),
              _buildTimeSection(),
              const SizedBox(height: 16),
              _buildEpcSection(),
              const SizedBox(height: 16),
              _buildBusinessContextSection(),
              const SizedBox(height: 16),
              _buildPaginationSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventTypeSection() {
    return ExpansionTile(
      title: const Text('Event Type'),
      initiallyExpanded: true,
      children: [
        FormBuilderDropdown(
          name: 'eventTypes',
          decoration: const InputDecoration(
            labelText: 'Event Type',
            border: OutlineInputBorder(),
          ),
          initialValue: _parameters.eventTypes?.isNotEmpty == true ? _parameters.eventTypes!.first : null,
          items: [
            'ObjectEvent',
            'AggregationEvent',
            'TransactionEvent',
            'TransformationEvent',
            'AssociationEvent',
          ].map((type) => DropdownMenuItem(
            value: type,
            child: Text(type),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeSection() {
    return ExpansionTile(
      title: const Text('Time Range'),
      children: [
        Row(
          children: [
            Expanded(
              child: FormBuilderDateTimePicker(
                name: 'startTime',
                decoration: const InputDecoration(
                  labelText: 'Start Time',
                  border: OutlineInputBorder(),
                ),
                initialValue: _parameters.startTime != null ? DateTime.parse(_parameters.startTime!) : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FormBuilderDateTimePicker(
                name: 'endTime',
                decoration: const InputDecoration(
                  labelText: 'End Time',
                  border: OutlineInputBorder(),
                ),
                initialValue: _parameters.endTime != null ? DateTime.parse(_parameters.endTime!) : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEpcSection() {
    return ExpansionTile(
      title: const Text('EPC Identifiers'),
      children: [
        FormBuilderTextField(
          name: 'epcs',
          decoration: const InputDecoration(
            labelText: 'EPCs (comma-separated)',
            border: OutlineInputBorder(),
            helperText: 'Example: urn:epc:id:sgtin:0614141.812345.400,urn:epc:id:sgtin:0614141.812345.401',
          ),
          initialValue: _parameters.epcs?.join(', '),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'epcClass',
          decoration: const InputDecoration(
            labelText: 'EPC Class (comma-separated)',
            border: OutlineInputBorder(),
            helperText: 'Example: urn:epc:class:lgtin:4012345.012345.987',
          ),
          initialValue: _parameters.epcClass?.join(', '),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildBusinessContextSection() {
    return ExpansionTile(
      title: const Text('Business Context'),
      children: [
        FormBuilderTextField(
          name: 'businessSteps',
          decoration: const InputDecoration(
            labelText: 'Business Steps (comma-separated)',
            border: OutlineInputBorder(),
            helperText: 'Example: commissioning,packing,shipping',
          ),
          initialValue: _parameters.businessSteps?.join(', '),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'dispositions',
          decoration: const InputDecoration(
            labelText: 'Dispositions (comma-separated)',
            border: OutlineInputBorder(),
            helperText: 'Example: in_progress,active,inactive',
          ),
          initialValue: _parameters.dispositions?.join(', '),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'readPoints',
          decoration: const InputDecoration(
            labelText: 'Read Points (comma-separated)',
            border: OutlineInputBorder(),
            helperText: 'Example: urn:epc:id:sgln:0614141.00777.0',
          ),
          initialValue: _parameters.readPoints?.join(', '),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'businessLocations',
          decoration: const InputDecoration(
            labelText: 'Business Locations (comma-separated)',
            border: OutlineInputBorder(),
            helperText: 'Example: urn:epc:id:sgln:0614141.00888.0',
          ),
          initialValue: _parameters.businessLocations?.join(', '),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildPaginationSection() {
    return ExpansionTile(
      title: const Text('Pagination & Ordering'),
      children: [
        Row(
          children: [
            Expanded(
              child: FormBuilderDropdown(
                name: 'orderBy',
                decoration: const InputDecoration(
                  labelText: 'Order By',
                  border: OutlineInputBorder(),
                ),
                initialValue: _parameters.orderBy ?? 'eventTime',
                items: [
                  'eventTime',
                  'recordTime',
                  'epc',
                  'action',
                  'bizStep',
                  'disposition',
                ].map((field) => DropdownMenuItem(
                  value: field,
                  child: Text(field),
                )).toList(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FormBuilderDropdown(
                name: 'orderDirection',
                decoration: const InputDecoration(
                  labelText: 'Order Direction',
                  border: OutlineInputBorder(),
                ),
                initialValue: _parameters.orderDirection ?? 'ASC',
                items: [
                  'ASC',
                  'DESC',
                ].map((direction) => DropdownMenuItem(
                  value: direction,
                  child: Text(direction),
                )).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FormBuilderTextField(
                name: 'limit',
                decoration: const InputDecoration(
                  labelText: 'Limit',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                initialValue: _parameters.limit?.toString(),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.integer(),
                  FormBuilderValidators.min(1),
                ]),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FormBuilderTextField(
                name: 'offset',
                decoration: const InputDecoration(
                  labelText: 'Offset',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                initialValue: _parameters.offset?.toString(),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.integer(),
                  FormBuilderValidators.min(0),
                ]),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
