import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/operation_palette.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/utils/display_date_utils.dart';

abstract final class ApiUiUtils {
  static Color methodColor(BuildContext context, String method) {
    final p = OperationPalette.of(context);
    switch (method.toUpperCase()) {
      case 'GET':
        return AppColorMapper.infoColor(context);
      case 'POST':
        return AppColorMapper.successColor(context);
      case 'PUT':
        return AppColorMapper.warningColor(context);
      case 'PATCH':
        return p.statusAccepted;
      case 'DELETE':
        return AppColorMapper.errorColor(context);
      default:
        return p.opUpdateStatus;
    }
  }

  static Color scopeColor(BuildContext context, String scope) {
    switch (scope.toLowerCase()) {
      case 'read':
        return AppColorMapper.infoColor(context);
      case 'write':
        return AppColorMapper.successColor(context);
      case 'admin':
        return AppColorMapper.warningColor(context);
      default:
        return AppColorMapper.neutralColor(context);
    }
  }

  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static String formatDisplayDateTime(DateTime dateTime) {
    return DisplayDateUtils.dmyHm(dateTime);
  }
}
