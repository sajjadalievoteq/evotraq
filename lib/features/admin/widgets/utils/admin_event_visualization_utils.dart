import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/operation_palette.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';

abstract final class AdminEventVisualizationUtils {
  static Color eventTypeColor(
    String eventType, {
    BuildContext? context,
    Brightness? brightness,
  }) {
    return AppColorMapper.eventType(
      eventType,
      scheme: AppEventColorScheme.admin,
      context: context,
      brightness: brightness,
    );
  }

  static Color partitionColor(
    String partition, {
    BuildContext? context,
    Brightness? brightness,
  }) {
    assert(
      context != null || brightness != null,
      'AdminEventVisualizationUtils.partitionColor requires either context or brightness.',
    );
    final p = context != null
        ? OperationPalette.of(context)
        : (brightness == Brightness.dark
            ? OperationPalette.dark
            : OperationPalette.light);
    return p.chartSeries[partition.hashCode.abs() % p.chartSeries.length];
  }
}
