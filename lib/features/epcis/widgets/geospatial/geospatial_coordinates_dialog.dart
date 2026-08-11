import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/geospatial_coordinates.dart';

class GeospatialCoordinatesDialog extends StatefulWidget {
  const GeospatialCoordinatesDialog({
    super.key,
    this.coordinates,
    required this.onSave,
  });

  final GeospatialCoordinates? coordinates;
  final ValueChanged<GeospatialCoordinates> onSave;

  @override
  State<GeospatialCoordinatesDialog> createState() =>
      _GeospatialCoordinatesDialogState();
}

class _GeospatialCoordinatesDialogState
    extends State<GeospatialCoordinatesDialog> {
  final _formKey = GlobalKey<FormState>();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _altitudeController = TextEditingController();
  final _coordinateSystemController = TextEditingController(text: 'WGS84');
  final _horizontalAccuracyController = TextEditingController();
  final _verticalAccuracyController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final coordinates = widget.coordinates;
    if (coordinates != null) {
      _latitudeController.text = coordinates.latitude.toString();
      _longitudeController.text = coordinates.longitude.toString();
      if (coordinates.altitude != null) {
        _altitudeController.text = coordinates.altitude.toString();
      }
      if (coordinates.coordinateSystem != null) {
        _coordinateSystemController.text = coordinates.coordinateSystem!;
      }
      if (coordinates.horizontalAccuracy != null) {
        _horizontalAccuracyController.text = coordinates.horizontalAccuracy
            .toString();
      }
      if (coordinates.verticalAccuracy != null) {
        _verticalAccuracyController.text = coordinates.verticalAccuracy
            .toString();
      }
      if (coordinates.name != null) {
        _nameController.text = coordinates.name!;
      }
    }
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _altitudeController.dispose();
    _coordinateSystemController.dispose();
    _horizontalAccuracyController.dispose();
    _verticalAccuracyController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.coordinates == null ? 'Add Coordinates' : 'Edit Coordinates',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _latitudeController,
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  hintText: 'e.g. 51.507351',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter latitude';
                  }
                  final latitude = double.tryParse(value);
                  if (latitude == null) {
                    return 'Please enter a valid number';
                  }
                  if (latitude < -90 || latitude > 90) {
                    return 'Latitude must be between -90 and 90';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _longitudeController,
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  hintText: 'e.g. -0.127758',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter longitude';
                  }
                  final longitude = double.tryParse(value);
                  if (longitude == null) {
                    return 'Please enter a valid number';
                  }
                  if (longitude < -180 || longitude > 180) {
                    return 'Longitude must be between -180 and 180';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _altitudeController,
                decoration: const InputDecoration(
                  labelText: 'Altitude (meters, optional)',
                  hintText: 'e.g. 100.5',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _coordinateSystemController,
                decoration: const InputDecoration(
                  labelText: 'Coordinate System',
                  hintText: 'e.g. WGS84',
                ),
              ),
              TextFormField(
                controller: _horizontalAccuracyController,
                decoration: const InputDecoration(
                  labelText: 'Horizontal Accuracy (meters, optional)',
                  hintText: 'e.g. 10',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _validateAccuracy,
              ),
              TextFormField(
                controller: _verticalAccuracyController,
                decoration: const InputDecoration(
                  labelText: 'Vertical Accuracy (meters, optional)',
                  hintText: 'e.g. 5',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _validateAccuracy,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Location Name (optional)',
                  hintText: 'e.g. Main Warehouse',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveCoordinates, child: const Text('Save')),
      ],
    );
  }

  String? _validateAccuracy(String? value) {
    if (value != null && value.isNotEmpty) {
      final accuracy = double.tryParse(value);
      if (accuracy == null) return 'Please enter a valid number';
      if (accuracy < 0) return 'Accuracy must be positive';
    }
    return null;
  }

  void _saveCoordinates() {
    if (!_formKey.currentState!.validate()) return;
    final coordinates = GeospatialCoordinates(
      latitude: double.parse(_latitudeController.text),
      longitude: double.parse(_longitudeController.text),
      altitude: _optionalDouble(_altitudeController),
      coordinateSystem: _coordinateSystemController.text.isNotEmpty
          ? _coordinateSystemController.text
          : 'WGS84',
      horizontalAccuracy: _optionalDouble(_horizontalAccuracyController),
      verticalAccuracy: _optionalDouble(_verticalAccuracyController),
      name: _nameController.text.isNotEmpty ? _nameController.text : null,
    );
    widget.onSave(coordinates);
    Navigator.of(context).pop();
  }

  double? _optionalDouble(TextEditingController controller) {
    return controller.text.isNotEmpty ? double.parse(controller.text) : null;
  }
}
