import 'package:flutter/material.dart';

class SubscriptionDeliveryTestResultDialog extends StatelessWidget {
  const SubscriptionDeliveryTestResultDialog({
    super.key,
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(success ? 'Test Successful' : 'Test Failed'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
