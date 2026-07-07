import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/display_date_utils.dart';

abstract final class ApiUiUtils {
  static Color methodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.blue;
      case 'POST':
        return Colors.green;
      case 'PUT':
        return Colors.orange;
      case 'PATCH':
        return Colors.teal;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.purple;
    }
  }

  static Color scopeColor(String scope) {
    switch (scope.toLowerCase()) {
      case 'read':
        return Colors.blue;
      case 'write':
        return Colors.green;
      case 'admin':
        return Colors.orange;
      default:
        return Colors.grey;
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
