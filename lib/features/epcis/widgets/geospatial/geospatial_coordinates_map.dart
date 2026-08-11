import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/epcis/geospatial_coordinates.dart';

class GeospatialCoordinatesMap extends StatelessWidget {
  const GeospatialCoordinatesMap({
    super.key,
    required this.coordinates,
    required this.onOpenExternalMap,
  });

  final GeospatialCoordinates coordinates;
  final VoidCallback onOpenExternalMap;

  @override
  Widget build(BuildContext context) {
    final position = LatLng(coordinates.latitude, coordinates.longitude);
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
                interactionOptions: const InteractionOptions(
                  enableMultiFingerGestureRace: true,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  tileProvider: NetworkTileProvider(),
                  userAgentPackageName: 'com.traqtrace.app',
                ),
                if (coordinates.horizontalAccuracy != null)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: position,
                        radius: coordinates.horizontalAccuracy!.toDouble(),
                        color: AppColorMapper.infoColor(
                          context,
                        ).withValues(alpha: 0.2),
                        borderColor: AppColorMapper.infoColor(
                          context,
                        ).withValues(alpha: 0.7),
                        borderStrokeWidth: 2,
                        useRadiusInMeter: true,
                      ),
                    ],
                  ),
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
                          if (coordinates.name != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
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
                                coordinates.name!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          TraqIcon(
                            NavIcons.gln,
                            color: AppColorMapper.errorColor(context),
                            size: 40.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (coordinates.name != null)
                      Text(
                        coordinates.name!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    Text(
                      'Lat: ${coordinates.latitude.toStringAsFixed(6)}°, Long: ${coordinates.longitude.toStringAsFixed(6)}°',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (coordinates.altitude != null)
                      Text(
                        'Alt: ${coordinates.altitude!.toStringAsFixed(1)} m',
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: ElevatedButton.icon(
                icon: const TraqIcon(AppAssets.iconOpenNew, size: 16),
                label: const Text(
                  'Open in Maps',
                  style: TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: AppColorMapper.infoColor(context),
                ),
                onPressed: onOpenExternalMap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
