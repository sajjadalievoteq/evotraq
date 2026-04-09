import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/models/sensor_element.dart';

/// Widget for displaying and editing sensor data in EPCIS events
class SensorElementWidget extends StatefulWidget {
  /// List of sensor elements to display/edit
  final List<SensorElement> sensorElements;
  
  /// Callback when sensor elements are updated
  final void Function(List<SensorElement> sensorElements)? onSensorElementsChanged;
  
  /// Whether the widget is in view-only mode
  final bool isViewOnly;

  /// Constructor
  const SensorElementWidget({
    Key? key,
    required this.sensorElements,
    this.onSensorElementsChanged,
    this.isViewOnly = false,
  }) : super(key: key);

  @override
  State<SensorElementWidget> createState() => _SensorElementWidgetState();
}

class _SensorElementWidgetState extends State<SensorElementWidget> {
  late List<SensorElement> _sensorElements;
  
  @override
  void initState() {
    super.initState();
    
    try {
      // Create a clean copy of sensor elements
      _sensorElements = widget.sensorElements.map((sensorElement) {
        // Convert to and from JSON to ensure clean objects
        try {
          final Map<String, dynamic> json = sensorElement.toJson();
          return SensorElement.fromJson(json);
        } catch (e) {
          print("Error processing sensor element in widget: $e");
          // Return a default element if conversion fails
          return SensorElement(measurements: []);
        }
      }).toList();
    } catch (e) {
      print("Error initializing sensor elements in widget: $e");
      _sensorElements = [];
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Sensor Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (_sensorElements.isEmpty && widget.isViewOnly)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('No sensor data recorded for this event'),
          ),
        ..._sensorElements.map((sensorElement) => _buildSensorElementCard(sensorElement)),
        if (!widget.isViewOnly)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ElevatedButton.icon(
              onPressed: _addSensorElement,
              icon: const Icon(Icons.add),
              label: const Text('Add Sensor Data'),
            ),
          ),
      ],
    );
  }
  
  Widget _buildSensorElementCard(SensorElement sensorElement) {
    final index = _sensorElements.indexOf(sensorElement);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Device ID: ${sensorElement.deviceId ?? 'N/A'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (!widget.isViewOnly)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editSensorElement(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeSensorElement(index),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8.0),
            if (sensorElement.deviceMetadata != null && sensorElement.deviceMetadata!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('Device: ${sensorElement.deviceMetadata}'),
              ),
            if (sensorElement.time != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('Time: ${sensorElement.time!.toIso8601String()}'),
              ),
            const Divider(),
            const Text(
              'Measurements:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            ...sensorElement.measurements.map((measurement) => _buildMeasurementItem(measurement)),
            if (sensorElement.measurements.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Text('No measurements recorded'),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMeasurementItem(SensorMeasurement measurement) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${measurement.type}: ${measurement.value ?? 'N/A'} ${measurement.unitOfMeasure ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (measurement.measurementTime != null)
                  Text('Time: ${measurement.measurementTime!.toIso8601String()}'),
                if (measurement.minValue != null || measurement.maxValue != null)
                  Text(
                    'Range: ${measurement.minValue ?? 'N/A'} - ${measurement.maxValue ?? 'N/A'} ${measurement.unitOfMeasure ?? ''}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                if (measurement.meanValue != null)
                  Text(
                    'Mean: ${measurement.meanValue} ${measurement.unitOfMeasure ?? ''}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                if (measurement.perceptionAccuracy != null)
                  Text(
                    'Accuracy: ${measurement.perceptionAccuracy}%',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                if (measurement.standardDeviation != null)
                  Text(
                    'Standard Deviation: ${measurement.standardDeviation}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _addSensorElement() {
    if (widget.isViewOnly) return;
    
    // Show dialog to add a new sensor element
    showDialog(
      context: context,
      builder: (context) => SensorElementDialog(
        onSave: (sensorElement) {
          setState(() {
            _sensorElements.add(sensorElement);
          });
          widget.onSensorElementsChanged?.call(_sensorElements);
        },
      ),
    );
  }
  
  void _editSensorElement(int index) {
    if (widget.isViewOnly) return;
    
    showDialog(
      context: context,
      builder: (context) => SensorElementDialog(
        sensorElement: _sensorElements[index],
        onSave: (sensorElement) {
          setState(() {
            _sensorElements[index] = sensorElement;
          });
          widget.onSensorElementsChanged?.call(_sensorElements);
        },
      ),
    );
  }
  
  void _removeSensorElement(int index) {
    if (widget.isViewOnly) return;
    
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Sensor Data'),
        content: const Text('Are you sure you want to remove this sensor data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _sensorElements.removeAt(index);
              });
              widget.onSensorElementsChanged?.call(_sensorElements);
            },
            child: const Text('REMOVE'),
          ),
        ],
      ),
    );
  }
}

/// Dialog for adding/editing a sensor element
class SensorElementDialog extends StatefulWidget {
  /// Sensor element to edit, or null for a new one
  final SensorElement? sensorElement;
  
  /// Callback when the sensor element is saved
  final void Function(SensorElement sensorElement) onSave;

  /// Constructor
  const SensorElementDialog({
    Key? key,
    this.sensorElement,
    required this.onSave,
  }) : super(key: key);

  @override
  State<SensorElementDialog> createState() => _SensorElementDialogState();
}

class _SensorElementDialogState extends State<SensorElementDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _deviceIdController;
  late TextEditingController _deviceMetadataController;
  DateTime? _time;
  late TextEditingController _rawDataController;
  final List<SensorMeasurement> _measurements = [];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize with existing data if editing
    final sensorElement = widget.sensorElement;
    _deviceIdController = TextEditingController(text: sensorElement?.deviceId ?? '');
    _deviceMetadataController = TextEditingController(text: sensorElement?.deviceMetadata ?? '');
    _time = sensorElement?.time;
    _rawDataController = TextEditingController(text: sensorElement?.rawData ?? '');
    
    if (sensorElement != null) {
      _measurements.addAll(sensorElement.measurements);
    }
  }
  
  @override
  void dispose() {
    _deviceIdController.dispose();
    _deviceMetadataController.dispose();
    _rawDataController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.sensorElement == null ? 'Add Sensor Data' : 'Edit Sensor Data'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _deviceIdController,
                decoration: const InputDecoration(
                  labelText: 'Device ID',
                  hintText: 'Enter device identifier',
                ),
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _deviceMetadataController,
                decoration: const InputDecoration(
                  labelText: 'Device Metadata',
                  hintText: 'Enter device information',
                ),
              ),
              const SizedBox(height: 12.0),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Capture Time'),
                subtitle: Text(_time != null 
                  ? _time!.toIso8601String() 
                  : 'Select time'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _time ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_time ?? DateTime.now()),
                    );
                    
                    if (time != null) {
                      setState(() {
                        _time = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _rawDataController,
                decoration: const InputDecoration(
                  labelText: 'Raw Data',
                  hintText: 'Enter raw sensor data (optional)',
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Measurements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              ..._measurements.map((measurement) => _buildMeasurementItem(measurement)),
              const SizedBox(height: 12.0),
              ElevatedButton.icon(
                onPressed: _addMeasurement,
                icon: const Icon(Icons.add),
                label: const Text('Add Measurement'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: _saveSensorElement,
          child: const Text('SAVE'),
        ),
      ],
    );
  }
  
  Widget _buildMeasurementItem(SensorMeasurement measurement) {
    final index = _measurements.indexOf(measurement);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text('${measurement.type}: ${measurement.value ?? 'N/A'} ${measurement.unitOfMeasure ?? ''}'),
        subtitle: measurement.measurementTime != null
            ? Text('Time: ${measurement.measurementTime!.toIso8601String()}')
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editMeasurement(index),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeMeasurement(index),
            ),
          ],
        ),
      ),
    );
  }
  
  void _addMeasurement() {
    // Show dialog to add a new measurement
    showDialog(
      context: context,
      builder: (context) => MeasurementDialog(
        onSave: (measurement) {
          setState(() {
            _measurements.add(measurement);
          });
        },
      ),
    );
  }
  
  void _editMeasurement(int index) {
    showDialog(
      context: context,
      builder: (context) => MeasurementDialog(
        measurement: _measurements[index],
        onSave: (measurement) {
          setState(() {
            _measurements[index] = measurement;
          });
        },
      ),
    );
  }
  
  void _removeMeasurement(int index) {
    setState(() {
      _measurements.removeAt(index);
    });
  }
  
  void _saveSensorElement() {
    if (_formKey.currentState!.validate()) {
      final sensorElement = SensorElement(
        deviceId: _deviceIdController.text.isEmpty ? null : _deviceIdController.text,
        deviceMetadata: _deviceMetadataController.text.isEmpty ? null : _deviceMetadataController.text,
        time: _time,
        rawData: null, // Not using this field for now
        measurements: _measurements,
      );
      
      widget.onSave(sensorElement);
      Navigator.of(context).pop();
    }
  }
}

/// Dialog for adding/editing a sensor measurement
class MeasurementDialog extends StatefulWidget {
  /// Measurement to edit, or null for a new one
  final SensorMeasurement? measurement;
  
  /// Callback when the measurement is saved
  final void Function(SensorMeasurement measurement) onSave;

  /// Constructor
  const MeasurementDialog({
    Key? key,
    this.measurement,
    required this.onSave,
  }) : super(key: key);

  @override
  State<MeasurementDialog> createState() => _MeasurementDialogState();
}

class _MeasurementDialogState extends State<MeasurementDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _typeController;
  late TextEditingController _valueController;
  late TextEditingController _uomController;
  DateTime? _time;
  late TextEditingController _minValueController;
  late TextEditingController _maxValueController;
  late TextEditingController _meanValueController;
  late TextEditingController _sDdevController;
  late TextEditingController _percRankController;

  final List<String> _measurementTypes = [
    'Temperature', 'Humidity', 'Pressure', 'Acceleration', 
    'Voltage', 'Current', 'Power', 'CO2', 'pH', 'Vibration', 'Speed',
    'Illuminance', 'Sound', 'Weight', 'Length', 'Volume',
    'Other'
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize with existing data if editing
    final measurement = widget.measurement;
    _typeController = TextEditingController(text: measurement?.type ?? '');
    _valueController = TextEditingController(text: measurement?.value?.toString() ?? '');
    _uomController = TextEditingController(text: measurement?.unitOfMeasure ?? '');
    _time = measurement?.measurementTime;
    _minValueController = TextEditingController(text: measurement?.minValue?.toString() ?? '');
    _maxValueController = TextEditingController(text: measurement?.maxValue?.toString() ?? '');
    _meanValueController = TextEditingController(text: measurement?.meanValue?.toString() ?? '');
    _sDdevController = TextEditingController(text: measurement?.standardDeviation?.toString() ?? '');
    _percRankController = TextEditingController(text: measurement?.perceptionAccuracy?.toString() ?? '');
  }
  
  @override
  void dispose() {
    _typeController.dispose();
    _valueController.dispose();
    _uomController.dispose();
    _minValueController.dispose();
    _maxValueController.dispose();
    _meanValueController.dispose();
    _sDdevController.dispose();
    _percRankController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.measurement == null ? 'Add Measurement' : 'Edit Measurement'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _measurementTypes.contains(_typeController.text) ? _typeController.text : null,
                decoration: const InputDecoration(
                  labelText: 'Measurement Type',
                  hintText: 'Select measurement type',
                ),
                items: _measurementTypes.map((type) => DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                )).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _typeController.text = value;
                    // Set some reasonable default UOM based on type
                    if (value == 'Temperature' && _uomController.text.isEmpty) {
                      _uomController.text = '°C';
                    } else if (value == 'Humidity' && _uomController.text.isEmpty) {
                      _uomController.text = '%';
                    } else if (value == 'Pressure' && _uomController.text.isEmpty) {
                      _uomController.text = 'hPa';
                    } else if (value == 'Weight' && _uomController.text.isEmpty) {
                      _uomController.text = 'kg';
                    }
                  }
                },
              ),
              if (_typeController.text == 'Other')
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Custom Type',
                    hintText: 'Enter measurement type',
                  ),
                  onChanged: (value) {
                    _typeController.text = value;
                  },
                  validator: (value) {
                    if (_typeController.text == 'Other' && (value == null || value.isEmpty)) {
                      return 'Please enter a measurement type';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: 'Value',
                  hintText: 'Enter measurement value',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _uomController,
                decoration: const InputDecoration(
                  labelText: 'Unit of Measure',
                  hintText: 'e.g., °C, %, kg',
                ),
              ),
              const SizedBox(height: 12.0),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Measurement Time'),
                subtitle: Text(_time != null 
                  ? _time!.toIso8601String() 
                  : 'Select time'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _time ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_time ?? DateTime.now()),
                    );
                    
                    if (time != null) {
                      setState(() {
                        _time = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 12.0),
              ExpansionTile(
                title: const Text('Statistical Values (Optional)'),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minValueController,
                          decoration: const InputDecoration(
                            labelText: 'Min Value',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: TextFormField(
                          controller: _maxValueController,
                          decoration: const InputDecoration(
                            labelText: 'Max Value',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  TextFormField(
                    controller: _meanValueController,
                    decoration: const InputDecoration(
                      labelText: 'Mean Value',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12.0),
                  TextFormField(
                    controller: _sDdevController,
                    decoration: const InputDecoration(
                      labelText: 'Standard Deviation',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12.0),
                  TextFormField(
                    controller: _percRankController,
                    decoration: const InputDecoration(
                      labelText: 'Percentile Rank',
                      hintText: 'Enter a value between 0 and 100',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final rank = double.tryParse(value);
                        if (rank == null) {
                          return 'Please enter a valid number';
                        }
                        if (rank < 0 || rank > 100) {
                          return 'Value must be between 0 and 100';
                        }
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: _saveMeasurement,
          child: const Text('SAVE'),
        ),
      ],
    );
  }
  
  void _saveMeasurement() {
    if (_formKey.currentState!.validate()) {
      final measurement = SensorMeasurement(
        type: _typeController.text,
        value: _valueController.text.isEmpty ? null : double.tryParse(_valueController.text),
        unitOfMeasure: _uomController.text.isEmpty ? null : _uomController.text,
        measurementTime: _time,
        minValue: _minValueController.text.isEmpty ? null : double.tryParse(_minValueController.text),
        maxValue: _maxValueController.text.isEmpty ? null : double.tryParse(_maxValueController.text),
        meanValue: _meanValueController.text.isEmpty ? null : double.tryParse(_meanValueController.text),
        standardDeviation: _sDdevController.text.isEmpty ? null : double.tryParse(_sDdevController.text),
        perceptionAccuracy: _percRankController.text.isEmpty ? null : double.tryParse(_percRankController.text),
      );
      
      widget.onSave(measurement);
      Navigator.of(context).pop();
    }
  }
}
