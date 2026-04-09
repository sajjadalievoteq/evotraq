import 'package:flutter/material.dart';

/// Widget to display validation errors from the backend
class ValidationErrorWidget extends StatelessWidget {
  /// List of validation errors
  final List<dynamic> validationErrors;
  
  /// Optional title
  final String? title;
  
  /// Optional callback when dismissed
  final VoidCallback? onDismiss;

  /// Constructor
  const ValidationErrorWidget({
    Key? key,
    required this.validationErrors,
    this.title,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (validationErrors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.red[50],
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8.0),
                Text(
                  title ?? 'Validation Errors',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                const Spacer(),
                if (onDismiss != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onDismiss,
                    tooltip: 'Dismiss',
                  ),
              ],
            ),
            const Divider(),
            ...validationErrors.map((error) {
              // Handle different error formats
              if (error is Map<String, dynamic>) {
                return _buildStructuredError(error);
              } else if (error is String) {
                return _buildSimpleError(error);
              } else {
                return _buildSimpleError(error.toString());
              }
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// Build a simple error message
  Widget _buildSimpleError(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right, color: Colors.red, size: 20),
          const SizedBox(width: 4.0),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a structured error with field and message
  Widget _buildStructuredError(Map<String, dynamic> error) {
    final field = error['field'] as String? ?? 'Unknown';
    final message = error['message'] as String? ?? 'Invalid value';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.arrow_right, color: Colors.red, size: 20),
              const SizedBox(width: 4.0),
              Text(
                field,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 28.0),
            child: Text(
              message,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
