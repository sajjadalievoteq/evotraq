import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/epcis/geospatial_coordinates.dart';

class GeospatialCoordinatesInfo extends StatelessWidget {
  const GeospatialCoordinatesInfo({super.key, required this.coordinates});

  final GeospatialCoordinates coordinates;

  @override
  Widget build(BuildContext context) {
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
          if (coordinates.name != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                coordinates.name!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          Row(
            children: [
              TraqIcon(
                NavIcons.gln,
                size: 16,
                color: AppColorMapper.errorColor(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${coordinates.latitude.toStringAsFixed(6)}°, ${coordinates.longitude.toStringAsFixed(6)}°',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (coordinates.altitude != null ||
              coordinates.coordinateSystem != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  if (coordinates.altitude != null)
                    Expanded(
                      child: Row(
                        children: [
                          TraqIcon(
                            AppAssets.iconSwapVert,
                            color: AppColorMapper.infoColor(context),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text('${coordinates.altitude!.toStringAsFixed(1)} m'),
                        ],
                      ),
                    ),
                  if (coordinates.coordinateSystem != null)
                    Expanded(
                      child: Text('System: ${coordinates.coordinateSystem}'),
                    ),
                ],
              ),
            ),
          if (coordinates.horizontalAccuracy != null ||
              coordinates.verticalAccuracy != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  TraqIcon(
                    AppAssets.iconInfo,
                    size: 16,
                    color: AppColorMapper.warningColor(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Accuracy: ${coordinates.horizontalAccuracy != null ? '±${coordinates.horizontalAccuracy!.toStringAsFixed(1)}m horiz.' : ''}${coordinates.verticalAccuracy != null ? ' ±${coordinates.verticalAccuracy!.toStringAsFixed(1)}m vert.' : ''}',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
