import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  GlobalKey<ScaffoldMessengerState>? _scaffoldMessengerKey;

  void setScaffoldMessengerKey(GlobalKey<ScaffoldMessengerState> key) {
    _scaffoldMessengerKey = key;
  }

  void showSuccess(String message) {
    _showCustom(message, variant: CustomSnackBarVariant.success);
  }

  void showError(String message) {
    _showCustom(message, variant: CustomSnackBarVariant.error);
  }

  void showInfo(String message) {
    _showCustom(message, variant: CustomSnackBarVariant.info);
  }

  void showWarning(String message) {
    _showCustom(message, variant: CustomSnackBarVariant.warning);
  }

  void _showCustom(
    String message, {
    required CustomSnackBarVariant variant,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    final context = _scaffoldMessengerKey?.currentContext;
    if (context == null) return;

    CustomSnackBarPresenter.show(
      context,
      variant: variant,
      message: message,
      title: title,
      duration: duration,
    );
  }
}