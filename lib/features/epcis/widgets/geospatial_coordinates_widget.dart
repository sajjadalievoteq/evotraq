import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:traqtrace_app/features/epcis/models/geospatial_coordinates.dart';

/// Widget for displaying and editing geospatial coordinates
class GeospatialCoordinatesWidget extends StatefulWidget {
  /// The coordinates to display or edit
  final GeospatialCoordinates? coordinates;
  
  /// Callback when coordinates are updated
  final void Function(GeospatialCoordinates? coordinates)? onCoordinatesChanged;
  
  /// Whether the widget is in view-only mode
  final bool isViewOnly;
  
  /// Whether to show the map preview
  final bool showMap;

  /// Constructor
  const GeospatialCoordinatesWidget({
    Key? key,
    this.coordinates,
    this.onCoordinatesChanged,
    this.isViewOnly = false,
    this.showMap = true,
  }) : super(key: key);

  @override
  State<GeospatialCoordinatesWidget> createState() => _GeospatialCoordinatesWidgetState();
}

class _GeospatialCoordinatesWidgetState extends State<GeospatialCoordinatesWidget> {
  GeospatialCoordinates? _coordinates;

  @override
  void initState() {
    super.initState();
    _coordinates = widget.coordinates;
  }

  @override
  Widget build(BuildContext context) {
    if (_coordinates == null && widget.isViewOnly) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No geospatial coordinates available'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Geospatial Coordinates',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!widget.isViewOnly && _coordinates != null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _editCoordinates,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_coordinates != null) ...[
              _buildCoordinatesInfo(),
              if (widget.showMap) ...[
                const SizedBox(height: 16),
                _buildMapPlaceholder(),
              ],
            ],
            if (!widget.isViewOnly && _coordinates == null)
              ElevatedButton.icon(
                onPressed: _addCoordinates,
                icon: const Icon(Icons.add_location),
                label: const Text('Add Coordinates'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinatesInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add name if available
          if (_coordinates!.name != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                _coordinates!.name!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            
          // Main coordinates display (always shown)
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_coordinates!.latitude.toStringAsFixed(6)}°, ${_coordinates!.longitude.toStringAsFixed(6)}°',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          // Additional details in a more compact form
          if (_coordinates!.altitude != null || _coordinates!.coordinateSystem != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  if (_coordinates!.altitude != null)
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.height, size: 16, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text('${_coordinates!.altitude!.toStringAsFixed(1)} m'),
                        ],
                      ),
                    ),
                  if (_coordinates!.coordinateSystem != null)
                    Expanded(
                      child: Text('System: ${_coordinates!.coordinateSystem}'),
                    ),
                ],
              ),
            ),
          
          // Accuracy information if available
          if (_coordinates!.horizontalAccuracy != null || _coordinates!.verticalAccuracy != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Accuracy: ' +
                      (_coordinates!.horizontalAccuracy != null ? '±${_coordinates!.horizontalAccuracy!.toStringAsFixed(1)}m horiz.' : '') +
                      (_coordinates!.verticalAccuracy != null ? ' ±${_coordinates!.verticalAccuracy!.toStringAsFixed(1)}m vert.' : '')
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    // We can use flutter_map on all platforms
    if (_coordinates != null) {
      // Create a LatLng object for flutter_map
      final LatLng position = LatLng(
        _coordinates!.latitude,
        _coordinates!.longitude,
      );
      
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: position,
                  initialZoom: 13.0,
                  // Enable interaction for better user experience
                  interactionOptions: const InteractionOptions(
                    enableMultiFingerGestureRace: true,
                  ),
                ),
                children: [
                  // Using standard OpenStreetMap tile layer (compatible with all platforms)
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.traqtrace.app',
                    // Add attribution required by OpenStreetMap
                    tileProvider: NetworkTileProvider(),
                    tileBuilder: (context, child, tile) {
                      return child;
                    },
                  ),
                  // Add a circle for accuracy indication if available
                  if (_coordinates!.horizontalAccuracy != null)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: position,
                          radius: _coordinates!.horizontalAccuracy!.toDouble(),
                          color: Colors.blue.withOpacity(0.2),
                          borderColor: Colors.blue.withOpacity(0.7),
                          borderStrokeWidth: 2,
                          useRadiusInMeter: true,
                        ),
                      ],
                    ),
                  // Add the main marker
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: position,
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_coordinates!.name != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _coordinates!.name!,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40.0,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 2,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Overlay information
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_coordinates!.name != null)
                        Text(
                          _coordinates!.name!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      Text(
                        'Lat: ${_coordinates!.latitude.toStringAsFixed(6)}°, Long: ${_coordinates!.longitude.toStringAsFixed(6)}°',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (_coordinates!.altitude != null)
                        Text(
                          'Alt: ${_coordinates!.altitude!.toStringAsFixed(1)} m',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ),
              // Add button to open in external map
              Positioned(
                top: 8,
                right: 8,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Open in Maps', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                  ),
                  onPressed: _openInExternalMap,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // If no coordinates are available
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          color: Colors.grey[200],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No coordinates available',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _addCoordinates() {
    showDialog(
      context: context,
      builder: (context) => _CoordinatesDialog(
        onSave: (coordinates) {
          setState(() {
            _coordinates = coordinates;
          });
          if (widget.onCoordinatesChanged != null) {
            widget.onCoordinatesChanged!(_coordinates);
          }
        },
      ),
    );
  }
  
  // Method to open the coordinates in an external map application
  void _openInExternalMap() async {
    if (_coordinates == null) return;
    
    final lat = _coordinates!.latitude;
    final lng = _coordinates!.longitude;
    final name = Uri.encodeComponent(_coordinates!.name ?? 'Location');
    
    // Use OpenStreetMap which works consistently across platforms
    String url = 'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng&zoom=15';
    
    try {
      // Use platform-specific apps when possible
      if (!kIsWeb) {
        try {
          if (Platform.isAndroid) {
            // Try Google Maps first on Android
            final googleUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
            final Uri googleUri = Uri.parse(googleUrl);
            if (await canLaunchUrl(googleUri)) {
              await launchUrl(googleUri);
              return;
            }
          } else if (Platform.isIOS) {
            // Try Apple Maps first on iOS
            final appleUrl = 'https://maps.apple.com/?q=$name&ll=$lat,$lng';
            final Uri appleUri = Uri.parse(appleUrl);
            if (await canLaunchUrl(appleUri)) {
              await launchUrl(appleUri);
              return;
            }
          }
        } catch (_) {
          // Ignore platform errors and fall back to web
        }
      }
      
      // Fallback to OpenStreetMap which works on all platforms including desktop
      final Uri osUri = Uri.parse(url);
      await launchUrl(
        osUri,
        mode: LaunchMode.platformDefault,  // Use external browser when possible
      );
    } catch (e) {
      // Show error in console
      debugPrint('Error opening map: $e');
      
      // Try one more fallback option - HERE Maps web
      try {
        final hereUrl = 'https://wego.here.com/directions/mix/mylocation/${lat},${lng}';
        final Uri hereUri = Uri.parse(hereUrl);
        await launchUrl(hereUri);
      } catch (e) {
        debugPrint('Failed to launch any map option: $e');
      }
    }
  }

  void _editCoordinates() {
    showDialog(
      context: context,
      builder: (context) => _CoordinatesDialog(
        coordinates: _coordinates,
        onSave: (coordinates) {
          setState(() {
            _coordinates = coordinates;
          });
          if (widget.onCoordinatesChanged != null) {
            widget.onCoordinatesChanged!(_coordinates);
          }
        },
      ),
    );
  }
}

/// Dialog for adding or editing geospatial coordinates
class _CoordinatesDialog extends StatefulWidget {
  /// Coordinates to edit (null for adding new)
  final GeospatialCoordinates? coordinates;
  
  /// Callback when coordinates are saved
  final void Function(GeospatialCoordinates coordinates) onSave;

  /// Constructor
  const _CoordinatesDialog({
    Key? key,
    this.coordinates,
    required this.onSave,
  }) : super(key: key);

  @override
  _CoordinatesDialogState createState() => _CoordinatesDialogState();
}

class _CoordinatesDialogState extends State<_CoordinatesDialog> {
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
    
    if (widget.coordinates != null) {
      _latitudeController.text = widget.coordinates!.latitude.toString();
      _longitudeController.text = widget.coordinates!.longitude.toString();
      if (widget.coordinates!.altitude != null) {
        _altitudeController.text = widget.coordinates!.altitude.toString();
      }
      if (widget.coordinates!.coordinateSystem != null) {
        _coordinateSystemController.text = widget.coordinates!.coordinateSystem!;
      }
      if (widget.coordinates!.horizontalAccuracy != null) {
        _horizontalAccuracyController.text = widget.coordinates!.horizontalAccuracy.toString();
      }
      if (widget.coordinates!.verticalAccuracy != null) {
        _verticalAccuracyController.text = widget.coordinates!.verticalAccuracy.toString();
      }
      if (widget.coordinates!.name != null) {
        _nameController.text = widget.coordinates!.name!;
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
      title: Text(widget.coordinates == null ? 'Add Coordinates' : 'Edit Coordinates'),
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter latitude';
                  }
                  double? latitude = double.tryParse(value);
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter longitude';
                  }
                  double? longitude = double.tryParse(value);
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    double? altitude = double.tryParse(value);
                    if (altitude == null) {
                      return 'Please enter a valid number';
                    }
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    double? accuracy = double.tryParse(value);
                    if (accuracy == null) {
                      return 'Please enter a valid number';
                    }
                    if (accuracy < 0) {
                      return 'Accuracy must be positive';
                    }
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _verticalAccuracyController,
                decoration: const InputDecoration(
                  labelText: 'Vertical Accuracy (meters, optional)',
                  hintText: 'e.g. 5',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    double? accuracy = double.tryParse(value);
                    if (accuracy == null) {
                      return 'Please enter a valid number';
                    }
                    if (accuracy < 0) {
                      return 'Accuracy must be positive';
                    }
                  }
                  return null;
                },
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
        ElevatedButton(
          onPressed: _saveCoordinates,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveCoordinates() {
    if (_formKey.currentState!.validate()) {
      final coordinates = GeospatialCoordinates(
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
        altitude: _altitudeController.text.isNotEmpty
            ? double.parse(_altitudeController.text)
            : null,
        coordinateSystem: _coordinateSystemController.text.isNotEmpty
            ? _coordinateSystemController.text
            : 'WGS84',
        horizontalAccuracy: _horizontalAccuracyController.text.isNotEmpty
            ? double.parse(_horizontalAccuracyController.text)
            : null,
        verticalAccuracy: _verticalAccuracyController.text.isNotEmpty
            ? double.parse(_verticalAccuracyController.text)
            : null,
        name: _nameController.text.isNotEmpty ? _nameController.text : null,
      );
      
      Navigator.of(context).pop();
      widget.onSave(coordinates);
    }
  }
}
