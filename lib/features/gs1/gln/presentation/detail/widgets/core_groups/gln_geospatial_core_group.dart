import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/models/geospatial_coordinates.dart';
import 'package:traqtrace_app/features/epcis/widgets/geospatial_coordinates_widget.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

class GlnGeospatialCoreGroup extends StatelessWidget {
  const GlnGeospatialCoreGroup({
    super.key,
    required this.displayCoordinates,
    required this.onCoordinatesChanged,
    required this.isEditing,
  });

  /// From persisted GLN until user edits (widget shows this baseline).
  final GeospatialCoordinates? displayCoordinates;
  final ValueChanged<GeospatialCoordinates?> onCoordinatesChanged;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Geospatial coordinates (EPCIS 2.0)'),
        GeospatialCoordinatesWidget(
          coordinates: displayCoordinates,
          onCoordinatesChanged: onCoordinatesChanged,
          isViewOnly: !isEditing,
        ),
      ],
    );
  }
}
