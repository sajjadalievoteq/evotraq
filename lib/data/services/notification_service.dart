import 'package:flutter/material.dart';
import 'package:traqtrace_app/shared/widgets/custom_snackbar_widget.dart';

/// Simple notification service using SnackBar for messages
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  GlobalKey<ScaffoldMessengerState>? _scaffoldMessengerKey;

  /// Set the scaffold messenger key for global access
  void setScaffoldMessengerKey(GlobalKey<ScaffoldMessengerState> key) {
    _scaffoldMessengerKey = key;
  }

  /// Show success message
  void showSuccess(String message) {
    _showCustom(message, variant: CustomSnackBarVariant.success);
  }

  /// Show error message
  void showError(String message) {
    _showCustom(message, variant: CustomSnackBarVariant.error);
  }

  /// Show info message
  void showInfo(String message) {
    _showCustom(message, variant: CustomSnackBarVariant.info);
  }

  /// Show warning message
  void showWarning(String message) {
    _showCustom(message, variant: CustomSnackBarVariant.warning);
  }

  void _showCustom(
    String message, {
    required CustomSnackBarVariant variant,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (_scaffoldMessengerKey?.currentState != null) {
      final messenger = _scaffoldMessengerKey!.currentState!;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: CustomSnackBarWidget(
            variant: variant,
            title: title,
            message: message,
            onClose: messenger.hideCurrentSnackBar,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          padding: EdgeInsets.zero,
          duration: duration,
        ),
      );
    }
  }
}