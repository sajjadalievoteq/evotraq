import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/sensor_element.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_form_add_to_list_section.dart';

const _measurementTypes = [
  'Temperature',
  'Humidity',
  'Pressure',
  'Acceleration',
  'Voltage',
  'Current',
  'Power',
  'CO2',
  'pH',
  'Vibration',
  'Speed',
  'Illuminance',
  'Sound',
  'Weight',
  'Length',
  'Volume',
  'Other',
];

class ObjectEventFormSensorDataSection extends StatefulWidget {
  final List<SensorElement> sensorElements;
  final bool isViewOnly;
  final ValueChanged<List<SensorElement>> onChanged;

  const ObjectEventFormSensorDataSection({
    super.key,
    required this.sensorElements,
    required this.isViewOnly,
    required this.onChanged,
  });

  @override
  State<ObjectEventFormSensorDataSection> createState() =>
      _ObjectEventFormSensorDataSectionState();
}

class _ObjectEventFormSensorDataSectionState
    extends State<ObjectEventFormSensorDataSection> {
  final _deviceIdController = TextEditingController();
  final _deviceMetadataController = TextEditingController();
  final _measurementValueController = TextEditingController();
  final _measurementUomController = TextEditingController();
  String _measurementType = 'Temperature';
  DateTime? _captureTime;
  DateTime? _measurementTime;

  @override
  void dispose() {
    _deviceIdController.dispose();
    _deviceMetadataController.dispose();
    _measurementValueController.dispose();
    _measurementUomController.dispose();
    super.dispose();
  }

  String _defaultUom(String type) {
    switch (type) {
      case 'Temperature':
        return '°C';
      case 'Humidity':
        return '%';
      case 'Pressure':
        return 'hPa';
      case 'Weight':
        return 'kg';
      default:
        return '';
    }
  }

  Future<void> _selectDateTime({
    required bool forCaptureTime,
  }) async {
    final initial =
        (forCaptureTime ? _captureTime : _measurementTime) ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (forCaptureTime) {
        _captureTime = selected;
      } else {
        _measurementTime = selected;
      }
    });
  }

  void _clearInput() {
    _deviceIdController.clear();
    _deviceMetadataController.clear();
    _measurementValueController.clear();
    _measurementUomController.clear();
    setState(() {
      _measurementType = 'Temperature';
      _captureTime = null;
      _measurementTime = null;
    });
  }

  void _addSensor() {
    final deviceId = _deviceIdController.text.trim();
    final valueText = _measurementValueController.text.trim();
    if (deviceId.isEmpty && valueText.isEmpty) return;

    final measurements = <SensorMeasurement>[];
    if (_measurementType.isNotEmpty || valueText.isNotEmpty) {
      measurements.add(
        SensorMeasurement(
          type: _measurementType,
          value: valueText.isEmpty ? null : double.tryParse(valueText),
          unitOfMeasure: _measurementUomController.text.trim().isEmpty
              ? null
              : _measurementUomController.text.trim(),
          measurementTime: _measurementTime,
        ),
      );
    }

    widget.onChanged([
      ...widget.sensorElements,
      SensorElement(
        deviceId: deviceId.isEmpty ? null : deviceId,
        deviceMetadata: _deviceMetadataController.text.trim().isEmpty
            ? null
            : _deviceMetadataController.text.trim(),
        time: _captureTime,
        measurements: measurements,
      ),
    ]);
    _clearInput();
  }

  void _remove(int index) {
    final updated = List<SensorElement>.from(widget.sensorElements)
      ..removeAt(index);
    widget.onChanged(updated);
  }

  void _clearAll() => widget.onChanged([]);

  String _sensorSummary(SensorElement sensor) {
    if (sensor.measurements.isEmpty) return 'No measurements';
    final m = sensor.measurements.first;
    return '${m.type}: ${m.value ?? 'N/A'} ${m.unitOfMeasure ?? ''}'.trim();
  }

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormAddToListSection(
      title: 'Sensor Data',
      listLabel: 'Sensors',
      itemCount: widget.sensorElements.length,
      isViewOnly: widget.isViewOnly,
      emptyMessage: widget.isViewOnly
          ? 'No sensor data recorded.'
          : 'No sensor data added yet. Fill in the fields above and press Add.',
      inputArea: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _deviceIdController,
            decoration: const InputDecoration(
              labelText: 'Device ID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _deviceMetadataController,
            decoration: const InputDecoration(
              labelText: 'Device Metadata',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8.0),
          InkWell(
            onTap: () => _selectDateTime(forCaptureTime: true),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Capture Time',
                border: OutlineInputBorder(),
              ),
              child: Text(
                _captureTime != null
                    ? _captureTime!.toLocal().toString()
                    : 'Select date and time',
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          const Text(
            'Measurement',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8.0),
          DropdownButtonFormField<String>(
            value: _measurementTypes.contains(_measurementType)
                ? _measurementType
                : 'Temperature',
            decoration: const InputDecoration(
              labelText: 'Measurement Type',
              border: OutlineInputBorder(),
            ),
            items: _measurementTypes
                .map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _measurementType = value;
                if (_measurementUomController.text.isEmpty) {
                  _measurementUomController.text = _defaultUom(value);
                }
              });
            },
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _measurementValueController,
                  decoration: const InputDecoration(
                    labelText: 'Value',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: TextField(
                  controller: _measurementUomController,
                  decoration: const InputDecoration(
                    labelText: 'Unit of Measure',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          InkWell(
            onTap: () => _selectDateTime(forCaptureTime: false),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Measurement Time',
                border: OutlineInputBorder(),
              ),
              child: Text(
                _measurementTime != null
                    ? _measurementTime!.toLocal().toString()
                    : 'Select date and time',
              ),
            ),
          ),
        ],
      ),
      onAdd: _addSensor,
      onClearAll: _clearAll,
      items: List.generate(widget.sensorElements.length, (index) {
        final sensor = widget.sensorElements[index];
        return ObjectEventFormListItemData(
          title: sensor.deviceId ?? 'Sensor ${index + 1}',
          subtitle: _sensorSummary(sensor),
          onRemove: widget.isViewOnly ? null : () => _remove(index),
        );
      }),
    );
  }
}
