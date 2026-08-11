import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:url_launcher/url_launcher.dart';
import 'package:traqtrace_app/data/models/epcis/geospatial_coordinates.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/epcis/widgets/geospatial/geospatial_coordinates_info.dart';
import 'package:traqtrace_app/features/epcis/widgets/geospatial/geospatial_coordinates_map.dart';
import 'package:traqtrace_app/features/epcis/widgets/geospatial/geospatial_coordinates_dialog.dart';

class GeospatialCoordinatesWidget extends StatefulWidget {
  final GeospatialCoordinates? coordinates;

  final void Function(GeospatialCoordinates? coordinates)? onCoordinatesChanged;

  final bool isViewOnly;

  final bool showMap;

  const GeospatialCoordinatesWidget({
    Key? key,
    this.coordinates,
    this.onCoordinatesChanged,
    this.isViewOnly = false,
    this.showMap = true,
  }) : super(key: key);

  @override
  State<GeospatialCoordinatesWidget> createState() =>
      _GeospatialCoordinatesWidgetState();
}

class _GeospatialCoordinatesWidgetState
    extends State<GeospatialCoordinatesWidget> {
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (!widget.isViewOnly && _coordinates != null)
                  IconButton(
                    icon: TraqIcon(AppAssets.iconEdit),
                    onPressed: _editCoordinates,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_coordinates != null) ...[
              GeospatialCoordinatesInfo(coordinates: _coordinates!),
              if (widget.showMap) ...[
                const SizedBox(height: 16),
                GeospatialCoordinatesMap(
                  coordinates: _coordinates!,
                  onOpenExternalMap: _openInExternalMap,
                ),
              ],
            ],
            if (!widget.isViewOnly && _coordinates == null)
              ElevatedButton.icon(
                onPressed: _addCoordinates,
                icon: TraqIcon(AppAssets.iconPin),
                label: const Text('Add Coordinates'),
              ),
          ],
        ),
      ),
    );
  }

  void _addCoordinates() {
    showDialog(
      context: context,
      builder: (context) => GeospatialCoordinatesDialog(
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

  void _openInExternalMap() async {
    if (_coordinates == null) return;

    final lat = _coordinates!.latitude;
    final lng = _coordinates!.longitude;
    final name = Uri.encodeComponent(_coordinates!.name ?? 'Location');

    String url = 'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng&zoom=15';

    try {
      if (!kIsWeb) {
        try {
          if (Platform.isAndroid) {
            final googleUrl =
                'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
            final Uri googleUri = Uri.parse(googleUrl);
            if (await canLaunchUrl(googleUri)) {
              await launchUrl(googleUri);
              return;
            }
          } else if (Platform.isIOS) {
            final appleUrl = 'https://maps.apple.com/?q=$name&ll=$lat,$lng';
            final Uri appleUri = Uri.parse(appleUrl);
            if (await canLaunchUrl(appleUri)) {
              await launchUrl(appleUri);
              return;
            }
          }
        } catch (_) {}
      }

      final Uri osUri = Uri.parse(url);
      await launchUrl(osUri, mode: LaunchMode.platformDefault);
    } catch (e) {
      debugPrint('Error opening map: $e');

      try {
        final hereUrl =
            'https://wego.here.com/directions/mix/mylocation/${lat},${lng}';
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
      builder: (context) => GeospatialCoordinatesDialog(
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
