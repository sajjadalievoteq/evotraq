import 'package:flutter/material.dart';

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
    _showSnackBar(
      message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  /// Show error message
  void showError(String message) {
    _showSnackBar(
      message,
      backgroundColor: Colors.red,
      icon: Icons.error,
    );
  }

  /// Show info message
  void showInfo(String message) {
    _showSnackBar(
      message,
      backgroundColor: Colors.blue,
      icon: Icons.info,
    );
  }

  /// Show warning message
  void showWarning(String message) {
    _showSnackBar(
      message,
      backgroundColor: Colors.orange,
      icon: Icons.warning,
    );
  }

  void _showSnackBar(String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    if (_scaffoldMessengerKey?.currentState != null) {
      _scaffoldMessengerKey!.currentState!.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}