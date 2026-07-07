import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/features/operations/shared/operation_epc_scan_validator.dart';

/// Shared helpers for human-readable operation EPC type labels.
abstract final class OperationEpcTypeUtils {
  static String labelFromValue(String value) {
    return label(OperationEpcScanValidator.resolveEpcType(value));
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

  static Color colorFromValue(String value) {
    return color(OperationEpcScanValidator.resolveEpcType(value));
  }

  static Color color(OperationScanItemType type) {
    return AppColorMapper.operationEpcType(type);
  }
}
