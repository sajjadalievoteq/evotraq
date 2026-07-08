import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';

abstract final class AdminEventVisualizationUtils {
  static Color eventTypeColor(String eventType) {
    return AppColorMapper.eventType(
      eventType,
      scheme: AppEventColorScheme.admin,
    );
  }

  static Color partitionColor(String partition) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[partition.hashCode % colors.length];
  }
}
