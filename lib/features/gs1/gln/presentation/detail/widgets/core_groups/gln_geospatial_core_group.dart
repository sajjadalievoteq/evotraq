import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/epcis/models/geospatial_coordinates.dart';
import 'package:traqtrace_app/features/epcis/widgets/geospatial_coordinates_widget.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class GlnGeospatialCoreGroup extends StatelessWidget {
  const GlnGeospatialCoreGroup({
    super.key,
    this.showFieldSkeleton = false,
    required this.displayCoordinates,
    required this.onCoordinatesChanged,
    required this.isEditing,
  });

  final bool showFieldSkeleton;

  final GeospatialCoordinates? displayCoordinates;
  final ValueChanged<GeospatialCoordinates?> onCoordinatesChanged;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GeospatialCoordinatesWidget(
          coordinates: displayCoordinates,
          onCoordinatesChanged: onCoordinatesChanged,
          isViewOnly: !isEditing,
        ),
      ],
    );

    return Gs1GroupCard(
      title: GlnUiConstants.sectionGeospatial,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      showFieldSkeleton: showFieldSkeleton,
      skeletonBuilder: (c) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 140,
          child: GtinSkeletonOutlineField(color: c, height: 140),
        ),
      ),
      child: body,
    );
  }
}
