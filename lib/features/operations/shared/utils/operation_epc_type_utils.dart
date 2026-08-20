import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_type.dart';

abstract final class OperationEpcTypeUtils {
  static String labelFromValue(String value) {
    return label(resolveOperationEpcType(value));
  }

  static String label(OperationScanItemType type) {
    return switch (type) {
      OperationScanItemType.sgtin => 'SGTIN',
      OperationScanItemType.sscc => 'SSCC',
      OperationScanItemType.gtin => 'GTIN',
      OperationScanItemType.invalid => 'EPC',
      OperationScanItemType.unknown => 'EPC',
    };
  }

  static Color colorFromValue(BuildContext context, String value) {
    return color(context, resolveOperationEpcType(value));
  }

  static Color color(BuildContext context, OperationScanItemType type) {
    return AppColorMapper.operationEpcTypeColor(context, type);
  }
}
